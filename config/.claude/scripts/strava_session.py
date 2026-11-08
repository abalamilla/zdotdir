#!/usr/bin/env python3
"""Reduce a Strava ride to warmup/work/cooldown stats using the workout config.

Usage: strava_session.py [--activity ID] [--workouts PATH] [--no-previous]
Prints one compact JSON object: the ride and the previous ride of the same type.
Cadence averages use samples above zero (same basis as Strava's average).
Tokens come from ~/.strava-mcp (shared with the Strava MCP server).
"""
import argparse
import bisect
import json
import os
import re
import sys
import time
from datetime import datetime
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

API = "https://www.strava.com/api/v3"
TOKEN_URL = "https://www.strava.com/oauth/token"
STRAVA_DIR = os.path.expanduser("~/.strava-mcp")
DEFAULT_WORKOUTS = os.path.expanduser("~/Documents/coaching/workouts.json")
SMOOTH_WINDOW = 30
MAX_SAMPLE_GAP_S = 5
PART_RE = re.compile(r"\s*part\s*\d+\s*$", re.I)
END = float("inf")


# --- pure logic -------------------------------------------------------------


def start_epoch(activity):
    return datetime.fromisoformat(activity["start_date"].replace("Z", "+00:00")).timestamp()


def base_name(name):
    return PART_RE.sub("", name).strip()


def match_workout(name, workouts):
    low = name.lower()
    for key, workout in workouts.items():
        if any(m in low for m in workout["match"]):
            return key
    return None


def group_parts(activities, anchor, gap_s):
    if not PART_RE.search(anchor["name"]):
        return [anchor]
    base = base_name(anchor["name"])
    candidates = sorted(
        (a for a in activities if PART_RE.search(a["name"]) and base_name(a["name"]) == base),
        key=start_epoch,
    )
    chains, prev_end = [], None
    for a in candidates:
        start = start_epoch(a)
        if prev_end is None or start - prev_end > gap_s:
            chains.append([])
        chains[-1].append(a)
        prev_end = start + a["elapsed_time"]
    return next(c for c in chains if any(a["id"] == anchor["id"] for a in c))


def previous_same_type(activities, group, key, workouts):
    first_start = start_epoch(group[0])
    ids = {a["id"] for a in group}
    older = [
        a
        for a in activities
        if a["id"] not in ids
        and start_epoch(a) < first_start
        and match_workout(base_name(a["name"]), workouts) == key
    ]
    return max(older, key=start_epoch) if older else None


def combine_streams(parts):
    """parts: [(start_epoch, streams)] oldest first -> time, hr, cadence, watts, later part start offsets."""
    t, hr, cad, watts, part_starts = [], [], [], [], []
    base = parts[0][0]
    for k, (epoch, streams) in enumerate(parts):
        offset = epoch - base
        times = streams["time"]
        n = len(times)
        h = streams.get("heartrate") or [0] * n
        c = streams.get("cadence") or [0] * n
        w = streams.get("watts") or [0] * n
        n = min(n, len(h), len(c), len(w))
        if k:
            part_starts.append(offset)
        t += [offset + x for x in times[:n]]
        hr += h[:n]
        cad += c[:n]
        watts += w[:n]
    return t, hr, cad, watts, part_starts


def in_deload(date, cfg):
    return any(start <= date <= end for start, end in cfg.get("deload_weeks", []))


def effective_workout(workout, date, cfg):
    override = workout.get("deload")
    if not override or not in_deload(date, cfg):
        return workout, False
    merged = {**workout, **{k: v for k, v in override.items() if k != "reps"}}
    if "reps" in override:
        merged["reps"] = {**workout["reps"], **override["reps"]}
    return merged, True


def best_window(t, hr, cad, watts, window_min, ftp_factor):
    """Hardest window of window_min minutes: by watts when the stream has them, else by HR."""
    use_watts = any(watts)
    series = watts if use_watts else hr
    prefix = [0.0]
    for v in series:
        prefix.append(prefix[-1] + v)
    window_s = window_min * 60
    best = None
    for i in range(len(t)):
        if t[i] + window_s > t[-1] + 1:
            break
        j = bisect.bisect_left(t, t[i] + window_s)
        avg = (prefix[j] - prefix[i]) / (j - i)
        if best is None or avg > best[0]:
            best = (avg, i)
    if best is None:
        return None
    avg, i = best
    out = {"metric": "watts" if use_watts else "hr", "window_min": window_min, "start_min": round(t[i] / 60, 1)}
    out.update({k: v for k, v in stats(t, hr, cad, t[i], t[i] + window_s).items() if k != "min"})
    if use_watts:
        out["avg_watts"] = round(avg)
        out["est_ftp_w"] = round(avg * ftp_factor)
    return out


def smooth(values, window):
    half = window // 2
    prefix = [0.0]
    for v in values:
        prefix.append(prefix[-1] + v)
    n = len(values)
    out = []
    for i in range(n):
        lo, hi = max(0, i - half), min(n, i + half + 1)
        out.append((prefix[hi] - prefix[lo]) / (hi - lo))
    return out


def median(values):
    s = sorted(values)
    mid = len(s) // 2
    return s[mid] if len(s) % 2 else (s[mid - 1] + s[mid]) / 2


def cooldown_start_from_hr(t, hr, warmup_end, planned_start):
    s = smooth(hr, SMOOTH_WINDOW)
    ref_lo = bisect.bisect_left(t, warmup_end + 60)
    search_from = bisect.bisect_left(t, max(warmup_end + 120, planned_start - 300))
    if search_from - ref_lo < 60:
        return planned_start
    ref = median(s[ref_lo:search_from])
    first_low = None
    for i in range(len(s) - 1, search_from - 1, -1):
        if s[i] >= ref - 10:
            break
        first_low = i
    if first_low is None:
        return planned_start
    onset = first_low
    while onset > search_from and s[onset - 1] < ref - 3:
        onset -= 1
    return t[onset]


def detect_boundaries(t, hr, workout, laps, part_starts):
    total = t[-1]
    if laps and len(laps) == 3:
        last = len(t) - 1
        w_end = t[min(laps[1]["start_index"], last)]
        c_start = t[min(laps[2]["start_index"], last)]
        return w_end, c_start, {"warmup": "laps", "cooldown": "laps"}
    warmup_s = workout["warmup_min"] * 60
    cooldown_s = workout["cooldown_min"] * 60
    sources = {"warmup": "plan", "cooldown": "plan"}
    w_end = min(warmup_s, total / 2)
    if part_starts and 0.5 * warmup_s <= part_starts[0] <= 2 * warmup_s:
        w_end, sources["warmup"] = part_starts[0], "parts"
    planned = min(max(total - cooldown_s, w_end + 60), total)
    c_start = planned
    if workout.get("detect") == "hr":
        c_start = cooldown_start_from_hr(t, hr, w_end, planned)
        if c_start != planned:
            sources["cooldown"] = "hr"
    return w_end, c_start, sources


def _mean(values, digits):
    if not values:
        return None
    m = sum(values) / len(values)
    return round(m, digits) if digits else int(round(m))


def stats(t, hr, cad, start_s, end_s):
    i0, i1 = bisect.bisect_left(t, start_s), bisect.bisect_left(t, end_s)
    hrs = [h for h in hr[i0:i1] if h > 0]
    cads = [c for c in cad[i0:i1] if c > 0]
    return {
        "min": round((min(end_s, t[-1]) - start_s) / 60, 1),
        "avg_hr": _mean(hrs, 1),
        "max_hr": max(hrs) if hrs else None,
        "avg_cad": _mean(cads, 0),
    }


def _weighted_samples(t, hr, start_s, end_s):
    i0, i1 = bisect.bisect_left(t, start_s), bisect.bisect_left(t, end_s)
    for i in range(i0, i1):
        dt = min(t[i + 1] - t[i], MAX_SAMPLE_GAP_S) if i + 1 < len(t) else 1
        yield hr[i], dt


def zone_minutes(t, hr, start_s, end_s, zones):
    out = {name: 0.0 for name, _, _ in zones}
    for h, dt in _weighted_samples(t, hr, start_s, end_s):
        for name, lo, hi in zones:
            if lo <= h <= hi:
                out[name] += dt
                break
    return {name: round(v / 60, 1) for name, v in out.items()}


def target_split(t, hr, start_s, end_s, lo, hi):
    below = inside = above = 0.0
    for h, dt in _weighted_samples(t, hr, start_s, end_s):
        if h < lo:
            below += dt
        elif h > hi:
            above += dt
        else:
            inside += dt
    total = below + inside + above
    if not total:
        return {}
    pct = lambda v: round(100 * v / total)  # noqa: E731
    return {"pct_in_target": pct(inside), "pct_above": pct(above), "pct_below": pct(below)}


def rep_stats(t, hr, cad, work_start, work_end, reps):
    per_rep, work_hrs, rec_hrs = [], [], []
    for k in range(reps["count"]):
        a = work_start + k * (reps["work_s"] + reps["recovery_s"])
        b = a + reps["work_s"]
        c = min(b + reps["recovery_s"], work_end)
        if a >= work_end:
            break
        work = stats(t, hr, cad, a, min(b, work_end))
        rec = stats(t, hr, cad, b, c) if c > b else None
        work_hrs.append(work["avg_hr"])
        if rec:
            rec_hrs.append(rec["avg_hr"])
        per_rep.append([work["avg_hr"], rec["avg_hr"] if rec else None, work["avg_cad"]])
    return {
        "work_avg_hr": _mean([h for h in work_hrs if h], 1),
        "recovery_avg_hr": _mean([h for h in rec_hrs if h], 1),
        "per_rep_work_rec_cad": per_rep,
    }


def analyze_ride(group, t, hr, cad, laps, part_starts, key, cfg, watts=None):
    workout = cfg["workouts"].get(key)
    first = group[0]
    session = {
        "name": base_name(first["name"]),
        "date": first["start_date_local"][:10],
        "weekday": datetime.strptime(first["start_date_local"][:10], "%Y-%m-%d").strftime("%a"),
        "activities": [a["id"] for a in group],
        "distance_km": round(sum(a["distance"] for a in group) / 1000, 1),
        "moving_min": round(sum(a["moving_time"] for a in group) / 60, 1),
        "device": first.get("device_name"),
        **{k: v for k, v in stats(t, hr, cad, 0, END).items() if k != "min"},
    }
    if workout is None:
        return {"type": None, "session": session, "note": "no workout config matches the activity name"}
    if workout.get("detect") == "best_window":
        window = best_window(t, hr, cad, watts or [0] * len(t), workout["window_min"], workout["ftp_factor"])
        return {"type": key, "session": session, "best_window": window}
    workout, deload = effective_workout(workout, session["date"], cfg)
    w_end, c_start, sources = detect_boundaries(t, hr, workout, laps, part_starts)
    work = stats(t, hr, cad, w_end, c_start)
    work["zone_min"] = zone_minutes(t, hr, w_end, c_start, cfg["zones"])
    work.update(target_split(t, hr, w_end, c_start, *workout["hr"]))
    report = {
        "type": key,
        "target_hr": workout["hr"],
        "session": session,
        "phase_source": sources,
        "warmup": stats(t, hr, cad, 0, w_end),
        "work": work,
        "cooldown": stats(t, hr, cad, c_start, END),
    }
    if deload:
        report["deload"] = True
    if "reps" in workout:
        report["reps"] = rep_stats(t, hr, cad, w_end, c_start, workout["reps"])
        report["reps"]["recovery_hr_max"] = workout["reps"]["recovery_hr_max"]
    return report


def analyze(api, activities, anchor, cfg):
    group = group_parts(activities, anchor, cfg["group_gap_minutes"] * 60)
    key = match_workout(base_name(anchor["name"]), cfg["workouts"])
    parts = [(start_epoch(a), api.streams(a["id"])) for a in group]
    t, hr, cad, watts, part_starts = combine_streams(parts)
    laps = api.laps(group[0]["id"]) if len(group) == 1 else None
    return analyze_ride(group, t, hr, cad, laps, part_starts, key, cfg, watts), group, key


def build_report(api, activities, anchor, cfg, with_previous=True):
    current, group, key = analyze(api, activities, anchor, cfg)
    report: dict = {"current": current}
    if with_previous and key:
        prev = previous_same_type(activities, group, key, cfg["workouts"])
        report["previous"] = analyze(api, activities, prev, cfg)[0] if prev else None
    return report


def pick_anchor(activities, activity_id):
    if activity_id is None:
        return activities[0]
    for a in activities:
        if a["id"] == activity_id:
            return a
    sys.exit(f"ERROR: activity {activity_id} is not among the latest {len(activities)} activities")


# --- Strava connector -------------------------------------------------------


class StravaApi:
    def __init__(self, strava_dir=STRAVA_DIR, clock=time.time):
        self._token_path = os.path.join(strava_dir, "tokens.json")
        self._config_path = os.path.join(strava_dir, "config.json")
        self._clock = clock

    def _load(self, path):
        try:
            with open(path) as f:
                return json.load(f)
        except (OSError, json.JSONDecodeError) as e:
            sys.exit(f"ERROR: cannot read {path}: {e!r}")

    def _access_token(self):
        tokens = self._load(self._token_path)
        if tokens["expires_at"] - 60 > self._clock():
            return tokens["access_token"]
        cfg = self._load(self._config_path)
        body = urlencode(
            {
                "client_id": cfg["STRAVA_CLIENT_ID"],
                "client_secret": cfg["STRAVA_CLIENT_SECRET"],
                "grant_type": "refresh_token",
                "refresh_token": tokens["refresh_token"],
            }
        ).encode()
        fresh = {**tokens, **self._request(Request(TOKEN_URL, data=body))}
        fd = os.open(self._token_path + ".tmp", os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
        with os.fdopen(fd, "w") as f:
            json.dump(fresh, f, indent=2)
        os.replace(self._token_path + ".tmp", self._token_path)
        return fresh["access_token"]

    def _request(self, request):
        try:
            with urlopen(request, timeout=30) as resp:
                return json.loads(resp.read())
        except HTTPError as e:
            hint = " (run strava-auth.py to re-authorize)" if e.code == 401 else ""
            sys.exit(f"ERROR: Strava {e.code} for {request.full_url.split('?')[0]}{hint}")

    def _get(self, path, params=None):
        url = API + path + ("?" + urlencode(params) if params else "")
        return self._request(Request(url, headers={"Authorization": f"Bearer {self._access_token()}"}))

    def list_activities(self, per_page=30):
        return self._get("/athlete/activities", {"per_page": per_page})

    def streams(self, activity_id):
        raw = self._get(
            f"/activities/{activity_id}/streams",
            {"keys": "time,heartrate,cadence,watts", "key_by_type": "true"},
        )
        return {k: v["data"] for k, v in raw.items()}

    def laps(self, activity_id):
        return self._get(f"/activities/{activity_id}/laps")


# --- entry point ------------------------------------------------------------


def load_workouts(path):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        sys.exit(f"ERROR: cannot read workout config {path}: {e!r}")


def main(argv=None):
    parser = argparse.ArgumentParser(description="Reduce a Strava ride to warmup/work/cooldown stats.")
    parser.add_argument("--activity", type=int, help="Strava activity id (default: latest)")
    parser.add_argument("--workouts", default=DEFAULT_WORKOUTS)
    parser.add_argument("--no-previous", action="store_true")
    args = parser.parse_args(argv)

    cfg = load_workouts(args.workouts)
    api = StravaApi()
    activities = api.list_activities()
    anchor = pick_anchor(activities, args.activity)
    report = build_report(api, activities, anchor, cfg, with_previous=not args.no_previous)
    print(json.dumps(report, separators=(",", ":")))


if __name__ == "__main__":
    main()
