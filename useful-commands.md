# Useful commands

## Remove all brew packages and cask packages

`brew remove --force $(brew list --formula)` `brew remove --force $(brew list)`

## Get directory content sorted by size

```bash
du -chs $HOME/{.,}* 2>/dev/null | sort -rh
```

## clean runtime dependencies

```bash
find ~/Documents/[dir] -type d \( -name node_modules -o -name __pycache__ \
  -o -name .terraform -o -name .venv -o -name venv -o -name build \
  -o -name dist -o -name .idea -o -name .pytest_cache \) -exec rm -rf {} + 2>/dev/null
```

## Safe to delete when space is needed

```bash
rm -rf ~/Library/Application\ Support/Google ~/Library/Caches/Google \
  ~/Library/Caches/Homebrew ~/Library/Caches/colima
```
