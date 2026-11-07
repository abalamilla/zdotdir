# Pages

What every page in a course has. All of it comes from the kit; a new kit component must keep it working, and the smoke test checks it.

- **Player**: a Listen bar under the kicker and a floating mini player (previous, play/pause, next, stop, current section) once the bar scrolls away; speed, voice and example-wait menus.
- **Play from here**: a ▶ beside any paragraph on desktop; while listening, clicking a paragraph jumps there; clicking the one being read pauses or resumes (a double-click's second click is ignored).
- **Keys**: `k` play/pause, `j`/`l` previous/next paragraph, `Esc` stop, ignored while typing or with ⌘/Ctrl/Alt held; OS media keys too.
- **On this page**: a contents list from the h2s, pinned beside the text on wide screens, collapsible on narrow ones, highlighting the current section.
- **Indexes**: a catalogue of every course and a page per course, generated from the files (titles, ledes, lengths, exercise types, audio), never hand-edited.
- **Saved answers**: quiz picks, recall answers and grades, spot picks and order arrangements survive a reload, per page; dropped if the question's text changes; a reset link per score line for retaking.
- **Navigation**: crumbs that start with a link to the course page, a back button after any in-page jump, and back links from each source to its citation.
- **Works everywhere**: from disk without a server, by keyboard, at phone width, in print with answers shown, in light and dark.

## New components

- If a second topic could use it, it's a kit component: add a demo to the kit gallery and a check to the smoke test. Otherwise it's a topic component in the workspace.
- Plain JavaScript, no dependencies or build step, set up from HTML attributes documented in the file header. A vendored library is fine if pinned and checksum-verified.
- Interactive output is never read aloud. Storage access is wrapped so the page works without it.
- Pure logic apart from DOM code, so it can be verified ([GROUND-TRUTH.md](./GROUND-TRUTH.md)).

## Why a small kit

Pages must open from disk, print, and keep working for years without a toolchain. Revisit a framework only if components need shared state across pages or the kit grows past about ten components.
