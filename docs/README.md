# Jujutsu (jj) Documentation

## Quick Start

**[jj-start-here.md](jj-start-here.md)** — The 10 commands you need for daily
work (5 minutes).

That's it for most days.

## Beyond Daily Work

For advanced workflows, features, or edge cases:

- **Official Docs**: https://docs.jj-vcs.dev/latest/
- **Tutorial**: https://docs.jj-vcs.dev/latest/tutorial
- **FAQ**: https://docs.jj-vcs.dev/latest/faq
- **For Git Users**: https://docs.jj-vcs.dev/latest/git-experts

## Setup

Your `zdotdir` includes two convenient functions:

```bash
jj-init       # Initialize jj in existing git repo (colocated mode)
jj-setup      # Auto-configure based on git remote
```

**Environment Variables** (for office repos):

```bash
JJ_OFFICE_EMAIL="email@work.com"      # Required for office setup
JJ_OFFICE_GPG_KEY="KEYID"             # Optional GPG key ID
```

## Key Concepts (TL;DR)

- **No `git add`** — all changes auto-tracked
- **`jj commit -m`** — saves your current state (replaces `git add` +
  `git commit`)
- **Every commit is saved** — hard to lose work
- **Colocated mode** — `.git` and `.jj` coexist, IDEs work normally
