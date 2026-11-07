# Practice

## Cases: predict, then reveal

Re-reading feels like learning but doesn't stick: a learner who re-read a lesson several times still scored 1 of 6. When a lesson must replace a **wrong mental model**, build it from **cases**:

- One quiz question per case, describing a concrete situation.
- The live simulator for exactly that situation sits inside the answer, so it stays hidden until a prediction is made.
- The answer says why, then invites one "what if" edit in the simulator ("delete the second Secret too, and watch both go red").
- Order the cases so an early reveal never gives away a later answer.

Each case targets one belief the learner showed. Map them explicitly when planning: "your pick on Q1 → case 1".

## Quiz rules

- All options the same word count, characters as close as possible; vary the correct position; no formatting hints.
- Start every prompt with its label ("1.", "R1.", "S1.", "O1.") so the score line can name misses.
- Test a skill on a situation, never recall of one sentence stated once in the prose.
- Avoid distractors that are partly true, and questions whose answer contradicts a source the learner is likely to trust, unless the lesson names that source and says why it's wrong.
- The explanation after an answer says why, not just what.

## Recall cards

Two or three at a lesson's start, from the learning records: missed items and anything due for spacing, worded as a new case, not the original question. An item missed twice is not a recall card any more; it becomes a case.

## Other exercises

| The skill | Exercise |
|---|---|
| Predict what a system does with an input | a simulator of the real algorithm |
| Find what's wrong in a file | spot the bug (click the bad lines) |
| Know a procedure or a pipeline's order | put the steps in order |
| Remember facts over time | recall cards |
| Do it for real | a numbered list of real commands with the expected output |

## After a score

When the user reports a quiz result:

1. **Ask which options they picked, and why**, unless they already said. The picks are the evidence; the score isn't.
2. **Look for one wrong picture behind several misses** (e.g. "the operator is a strict, silent, all-or-nothing gate" explained three misses). Note which misses repeat across lessons.
3. **Check the questions too.** A question that tested one sentence, or contradicted a trusted internal doc, is the quiz's fault; say so plainly.
4. **Write the learning record**: score, each miss with its pick, the shared wrong picture, and what the next lesson must do.
5. **Re-plan.** If the lesson didn't land, don't move on: rebuild that material as cases before the next new idea. Tell the user the plan and the reason in a few lines.
6. Next lesson: recall cards for single misses, cases for repeated ones.
