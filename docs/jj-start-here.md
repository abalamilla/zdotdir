# Jujutsu: Start Here

The essential commands for daily work.

## Setup (One Time)

```bash
# Clone a repo
jj git clone https://github.com/user/repo
cd repo

# Auto-configure
jj-setup
```

## Daily Workflow

### 1. Start new work

```bash
# Create bookmark (branch)
jj-start my-feature

# In colocated repos (git+jj), also sync git
git checkout my-feature
```

### 2. Make changes and commit

```bash
# Edit files normally
echo "my work" > file.txt

# Commit (creates new empty @ on top)
jj commit -m "what I did"

# Your work is now at @- (parent)
```

### 3. Get latest from remote

```bash
# Fetch updates
jj git fetch --remote origin

# Rebase your bookmark onto latest main
jj rebase -b my-feature -d main@origin
```

### 4. Push your work

```bash
# Push bookmark
jj git push --remote origin --bookmark my-feature

# In colocated repos, sync git if needed
git checkout my-feature
```

### 5. Update existing work

```bash
# Edit commit message
jj describe -m "new message"

# Abandon unwanted commits
jj abandon <commit-id>

# Edit specific commit
jj edit <commit-id>
```

## Common Operations

### Revert pushed commits

```bash
# Create commit that undoes changes
jj new main
jj restore --from <commit-before-bad-changes> .
jj commit -m "Revert bad changes"

# Move bookmark and push
jj bookmark set main -r @- --allow-backwards
jj git push --remote origin --bookmark main
```

### Fix detached branch (colocated repos)

```bash
# Sync git to match jj
git checkout <branch-name>
jj git import

# Or move bookmark to current commit
jj bookmark set <branch> -r @-
jj git export
git checkout <branch>
```

### Undo operations

```bash
# View recent operations
jj op log

# Undo last operation
jj op undo

# Restore to specific operation
jj op restore <operation-id>
```

### Clean up empty commits

```bash
# Remove empty working copy
jj abandon @

# Create new working copy
jj new <bookmark>
```

---

## That's It

Really. Those commands handle 95% of daily work.

## Key Concepts

**Working copy is always a commit (`@`):**
- After `jj commit`, your work is at `@-` (parent)
- `@` becomes new empty working copy
- This is normal, not an error

**Colocated repos (git + jj):**
- `jj` and `git` have separate state
- Use `git checkout` to sync git to jj bookmarks
- Use `jj git export/import` to sync manually
- Detached HEAD is common - just `git checkout <branch>`

**Bookmarks (branches):**
- Required for pushing to Git remotes
- Use `jj-start` to create and setup
- Move with `jj bookmark set <name> -r <commit>`

**Everything is recoverable:**
- `jj op log` shows all operations
- `jj op undo` reverses mistakes
- Abandoned commits stay in history

## When You Need More

- **Understand colocated mode**: [jj-colocated.md](jj-colocated.md)
- **Multiple commits in one PR**:
  [jj-quickstart.md](jj-quickstart.md#stack-multiple-changes)
- **Full reference**: [jj-quickstart.md](jj-quickstart.md)
- **Git comparison**: [jj-git-equivalents.md](jj-git-equivalents.md)

## Quick Reference

```bash
# View state
jj status              # Working copy changes
jj log                 # Commit history
jj bookmark list       # List bookmarks

# Make changes
jj commit -m "msg"     # Save current work
jj describe -m "msg"   # Edit commit message
jj abandon <commit>    # Remove commit

# Sync with remote
jj git fetch --remote origin
jj rebase -b <branch> -d main@origin
jj git push --remote origin --bookmark <branch>

# Fix issues
jj op log              # View operations
jj op undo             # Undo last operation
git checkout <branch>  # Fix detached (colocated)
```

## Real Example

```bash
# Start work
jj-start add-feature
git checkout add-feature

# Make changes
echo "code" > file.txt
jj commit -m "feat: add feature"

# Get latest and rebase
jj git fetch --remote origin
jj rebase -b add-feature -d main@origin

# Push
jj git push --remote origin --bookmark add-feature
git checkout add-feature  # Sync git

# Merge to main
jj bookmark set main -r add-feature --allow-backwards
jj git push --remote origin --bookmark main
jj bookmark delete add-feature
```
