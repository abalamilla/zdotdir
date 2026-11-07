---
name: teach-kit
description: Teach a topic with the full lesson method - the base teach workspace plus interactive cases, verified simulators, recordings and the done checklist. Manual only.
disable-model-invocation: true
argument-hint: "What to learn, or which lesson to build next"
---

Build or continue a course the way it's done here. This adds a method on top of the base `teach` skill; it doesn't replace it.

## Steps

1. **Load the base skill.** Invoke the `teach` skill with the same arguments, and follow its workspace rules: mission, resources, learning records, lessons, reference pages, notes.
2. **Read the house rules of the learning root:** its `LESSON-GUIDE.md` (paths, machine setup, preferences), its `GLOSSARY.md` (the words for every part of a course), the kit gallery `_kit/index.html`, and the workspace's `NOTES.md` and latest learning records. If the learning root has no `_kit/`, ask before creating one.
3. **Decide the lesson from the evidence**, not the outline: the latest learning record says what wasn't stored and how. Read [PRACTICE.md](./PRACTICE.md) "After a score" before planning anything after a quiz result.
4. **Gather ground truth** for every claim, per [GROUND-TRUTH.md](./GROUND-TRUTH.md): the live system and pinned source first, internal docs last.
5. **Write the lesson** per [LESSONS.md](./LESSONS.md): one new idea, real examples with file and line references, a transformation figure for every change one thing makes to another.
6. **Build the practice** per [PRACTICE.md](./PRACTICE.md): cases when a wrong mental model has to go, recall cards for spacing, a quiz that tests skills on situations.
7. **Check every simulator against the real tool** and save the verify script ([GROUND-TRUTH.md](./GROUND-TRUTH.md)).
8. **Record it** per [AUDIO.md](./AUDIO.md), and keep the page features in [PAGES.md](./PAGES.md) working.
9. **Finish with the done checklist** below, then give the user a short summary: what the lesson does, what was verified and how, and anything found in the real system along the way.

## Done checklist

A lesson isn't done until all of these hold:

1. The smoke test passes: every page at phone and desktop width, no JS errors, no missing files, no sideways scroll, every kit component driven.
2. A screenshot of each new interactive part has been looked at.
3. Each simulator in the lesson has a passing verify script, and the lesson says what it was checked against.
4. The recording is rendered after the last edit (the smoke test fails on a stale one).
5. The indexes are regenerated (the smoke test fails on stale ones).
6. Neighbouring lessons link to it; new terms are in the topic glossary.
7. It's opened locally for the user. Never published.
8. Facts worth keeping beyond the course go to memory as small specific notes.
9. Anything learned about the method itself is folded into this skill (see below).

When the user reports a score, follow "After a score" in [PRACTICE.md](./PRACTICE.md) before building anything new.

## Keep this skill current

Update this skill yourself, without waiting to be asked, whenever a session teaches something about **how to teach** that a future lesson would get wrong without it. Worth adding:

- a change in practice that moved a result (a format that turned 1 of 6 into 4 of 6);
- a mistake a verify script or the smoke test caught, generalised into a rule;
- a correction or request from the user about the method (pacing, audio, page behaviour, quiz style);
- a new kit component, or a new check in the done checklist.

Not worth adding: topic facts (they go to the course or memory), paths and machine setup (the learning root's `LESSON-GUIDE.md`), one-off preferences for a single course (its `NOTES.md`), or anything the base `teach` skill already says.

How:

1. Put it in the file it belongs to, as a rule with its reason and, where there is one, the evidence that earned it. Edit or replace an existing rule rather than appending a near-duplicate; keep each file short.
2. Use the learning root's glossary terms; add a term there first if the rule needs a new one.
3. Commit the change on its own in the repo that holds this skill, staging only these files, with a message saying what changed and why.
4. Tell the user in the lesson summary: one line per change, and the commit.
