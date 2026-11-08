import unittest

import strava_session as ss

CFG = {
    "group_gap_minutes": 30,
    "zones": [["Z1", 0, 107], ["Z2", 108, 141], ["Z3", 142, 158], ["Z4-Z5", 159, 250]],
    "workouts": {
        "z2_long": {
            "match": ["z2 long"], "detect": "hr", "warmup_min": 10, "work_min": 70,
            "cooldown_min": 10, "hr": [110, 140],
        },
        "tempo": {
            "match": ["tempo"], "detect": "hr", "warmup_min": 10, "work_min": 45,
            "cooldown_min": 8, "hr": [142, 158],
        },
        "intervals": {
            "match": ["intervals"], "detect": "plan", "warmup_min": 10, "work_min": 45.5,
            "cooldown_min": 10, "hr": [160, 185],
            "reps": {"count": 7, "work_s": 210, "recovery_s": 180, "recovery_hr_max": 135},
        },
    },
}


def ramp(start, end, seconds):
    return [round(start + (end - start) * i / seconds) for i in range(seconds)]


def stream(hr, cadence=90):
    return {"time": list(range(len(hr))), "heartrate": hr, "cadence": [cadence] * len(hr)}


def z2_ride(warm=600, work=3000, cool=600, work_hr=134):
    return ramp(90, work_hr, warm) + [work_hr] * work + ramp(work_hr, 105, cool)


def activity(aid, name, start, elapsed):
    return {
        "id": aid, "name": name, "start_date": start, "start_date_local": start,
        "elapsed_time": elapsed, "moving_time": elapsed, "distance": elapsed * 5.0,
        "device_name": "bike computer",
    }


class FakeApi:
    def __init__(self, streams, laps=None):
        self._streams, self._laps = streams, laps or {}

    def streams(self, activity_id):
        return self._streams[activity_id]

    def laps(self, activity_id):
        return self._laps.get(activity_id, [])


class GroupingTest(unittest.TestCase):
    part1 = activity(1, "Z2 Long Part 1", "2026-11-07T12:07:55Z", 706)
    part2 = activity(2, "Z2 Long Part 2", "2026-11-07T12:19:54Z", 5031)

    def test_parts_started_close_together_are_one_ride(self):
        group = ss.group_parts([self.part2, self.part1], self.part2, 1800)
        self.assertEqual([a["id"] for a in group], [1, 2])

    def test_parts_far_apart_are_separate_rides(self):
        late = activity(3, "Z2 Long Part 2", "2026-11-07T18:00:00Z", 600)
        group = ss.group_parts([late, self.part1], late, 1800)
        self.assertEqual([a["id"] for a in group], [3])

    def test_activity_without_part_suffix_stands_alone(self):
        tempo = activity(4, "Tempo/Strength Z3", "2026-11-06T11:15:30Z", 4097)
        self.assertEqual(ss.group_parts([tempo, self.part1], tempo, 1800), [tempo])

    def test_previous_is_latest_older_ride_of_same_type(self):
        older_long = activity(0, "Z2 Long", "2026-11-01T12:00:00Z", 5580)
        older_tempo = activity(5, "Tempo/Strength Z3", "2026-11-03T12:00:00Z", 4000)
        acts = [self.part2, self.part1, older_tempo, older_long]
        prev = ss.previous_same_type(acts, [self.part1, self.part2], "z2_long", CFG["workouts"])
        self.assertEqual(prev["id"], 0)


class BoundaryTest(unittest.TestCase):
    def setUp(self):
        self.hr = z2_ride()
        self.t = list(range(len(self.hr)))

    def test_hr_drop_sets_cooldown_start_near_the_true_onset(self):
        w_end, c_start, sources = ss.detect_boundaries(self.t, self.hr, CFG["workouts"]["z2_long"], None, [])
        self.assertEqual(w_end, 600)
        self.assertAlmostEqual(c_start, 3600, delta=90)
        self.assertEqual(sources, {"warmup": "plan", "cooldown": "hr"})

    def test_part_boundary_marks_warmup_end(self):
        w_end, _, sources = ss.detect_boundaries(self.t, self.hr, CFG["workouts"]["z2_long"], None, [719])
        self.assertEqual((w_end, sources["warmup"]), (719, "parts"))

    def test_three_laps_override_detection(self):
        laps = [{"start_index": 0}, {"start_index": 700}, {"start_index": 3500}]
        self.assertEqual(
            ss.detect_boundaries(self.t, self.hr, CFG["workouts"]["z2_long"], laps, []),
            (700, 3500, {"warmup": "laps", "cooldown": "laps"}),
        )

    def test_flat_hr_without_a_drop_falls_back_to_the_plan(self):
        flat = [130] * 3000
        _, c_start, sources = ss.detect_boundaries(list(range(3000)), flat, CFG["workouts"]["z2_long"], None, [])
        self.assertAlmostEqual(c_start, 2400, delta=1)
        self.assertEqual(sources["cooldown"], "plan")


class IntervalsTest(unittest.TestCase):
    def test_reps_split_by_the_configured_structure(self):
        hr = ramp(90, 140, 600)
        cad = [90] * 600
        for _ in range(7):
            hr += [170] * 210 + [139] * 180
            cad += [99] * 210 + [70] * 180
        hr += [110] * 600
        cad += [80] * 600
        t = list(range(len(hr)))
        group = [activity(7, "Intervals Z4-Z5", "2026-11-04T11:14:11Z", len(hr))]
        report = ss.analyze_ride(group, t, hr, cad, None, [], "intervals", CFG)
        self.assertEqual(report["reps"]["work_avg_hr"], 170.0)
        self.assertEqual(report["reps"]["recovery_avg_hr"], 139.0)
        self.assertEqual(len(report["reps"]["per_rep_work_rec_cad"]), 7)
        self.assertEqual(report["phase_source"], {"warmup": "plan", "cooldown": "plan"})


class ReportTest(unittest.TestCase):
    def test_split_ride_is_one_session_with_previous_for_comparison(self):
        part1 = activity(1, "Z2 Long Part 1", "2026-11-07T12:07:55Z", 706)
        part2 = activity(2, "Z2 Long Part 2", "2026-11-07T12:19:54Z", 5000)
        older = activity(0, "Z2 Long", "2026-11-01T12:00:00Z", 4200)
        api = FakeApi(
            {
                1: stream(ramp(90, 134, 706)),
                2: stream([134] * 4400 + ramp(134, 105, 600)),
                0: stream(z2_ride(work=3000)),
            }
        )
        report = ss.build_report(api, [part2, part1, older], part2, CFG)
        current, previous = report["current"], report["previous"]
        self.assertEqual(current["session"]["activities"], [1, 2])
        self.assertEqual(current["phase_source"]["warmup"], "parts")
        self.assertAlmostEqual(current["work"]["avg_hr"], 134, delta=1)
        self.assertEqual(current["work"]["pct_above"], 0)
        self.assertEqual(previous["session"]["date"], "2026-11-01")

    def test_unmatched_activity_name_is_reported_not_guessed(self):
        ride = activity(9, "Morning ride", "2026-11-08T11:00:00Z", 3000)
        report = ss.build_report(FakeApi({9: stream([130] * 3000)}), [ride], ride, CFG)
        self.assertIsNone(report["current"]["type"])
        self.assertNotIn("previous", report)


if __name__ == "__main__":
    unittest.main()
