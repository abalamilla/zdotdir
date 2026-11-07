# Audio

The learner listens as well as reads, so every lesson is spoken.

## Recordings

- Render each lesson with the local neural voice once its text is final (the guide names the tool, voice and setup). A recording stores each paragraph's start time.
- The player uses a recording only while every paragraph's text and spoken form still match the page; any edit makes it stale and falls back to browser voices. Re-render after every edit, and after any change to the speech rules, which makes **all** recordings stale.
- Browser voices are the fallback; the best installed one is listed first.

## Spoken form

What's read is not the page text. One spoken form serves both engines:

- **Code**: camelCase split into words, `a="b"` read as "a is b", path separators as pauses, quotes and brackets dropped.
- **Numbers that introduce a topic** get a full stop: "Section one. Title", "One. …"; otherwise "1 · Title" is read as "one title".
- **Topic words** (units, acronyms, product names) go in the workspace's pronunciation rules, because they differ per topic: "5m" is minutes in one course and millicores in another.
- One-offs: give an element its own spoken text.
- Never read: code blocks, figures, tables, exercises and their output, score lines.

Check the spoken form of any code-heavy paragraph before recording.

## Example waits

Code, figures, tables and exercises aren't read, so the player gives time to look at them: after the paragraph before an example, it highlights the example, scrolls to it, and either waits (about 3s plus a little per line, capped), pauses until continued, or skips, per the learner's choice. Write a sentence introducing each example, since that's what plays just before the wait.
