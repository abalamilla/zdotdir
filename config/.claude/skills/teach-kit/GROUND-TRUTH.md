# Ground truth

## Sources, in order of trust

1. **The live system**: its loaded config, API, metrics. Read-only, and with care for anything sensitive (prefer endpoints that redact secrets).
2. **Source code at the exact version in use.** Find the running version first (image tag, `/status`), then read the code at that tag. Docs can lag or contradict the code; when they do, the code wins and the lesson says so.
3. **Official docs at that version.**
4. **Internal docs and runbooks: last.** They drift. When one is wrong, note it as a finding for the user; don't fix it unless asked.

Every claim gets a citation to one of these, with versions and dates. "Not documented" is a valid finding: say so instead of guessing.

## Simulators

A simulator models a real algorithm so the learner can explore it. It's only allowed in a lesson once it's been checked:

- Keep the pure logic separate from the DOM code, so a script can run it without a browser.
- Check it against the **real tool** on real inputs: the system's own CLI, a local copy of the real binary with scaled-down timers, or every real object on a live cluster compared with what the system loaded.
- When they disagree, believe the real tool. Read the source to understand why, fix the model, and teach the surprise if it matters.
- Save the check as a **verify script** in the workspace with its last result, and say in the lesson what the simulator was checked against.

This catches the author's mistakes too: comparisons like these found a repeat-timing race, a lingering-group rule, a matcher sort order and a broken query in a reference page, all before the learner saw them.

## Experiments

When a behaviour can't be read from a live system safely (what breaks if replicas can't talk, what a restart loses), run it: two local instances of the real binary, clustered and not, with scripted inputs and a recorded result. Clean up processes and data afterwards, and save the scripts with a short README of the results.

## Findings outside the course

Problems found in the real system while building a lesson (a misrouted receiver, a dead setting, a stale doc) are reported to the user in the summary and saved to memory. They're not fixed as part of the lesson.
