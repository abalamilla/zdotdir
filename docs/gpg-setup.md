# GPG Setup

Instructions for setting up GPG on new computers.

## Export Keys (Backup)

Before switching computers, export your keys:

```bash
# Export private key (keep secure!)
gpg --export-secret-keys --armor YOUR_KEY_ID > private-key.asc

# Export public key
gpg --export --armor YOUR_KEY_ID > public-key.asc

# Export trust database (optional but helpful)
gpg --export-ownertrust > ownertrust.txt
```

**Store these files securely** (password manager, encrypted backup, etc.)

## Initial Setup

### 1. Import Your Key

```bash
# Import private key from backup
gpg --import /path/to/private-key.asc

# Import public key (if needed)
gpg --import /path/to/public-key.asc

# Verify import
gpg --list-secret-keys
```

### 2. Trust Your Key

This prevents the "key's User ID is not certified" warning:

```bash
# Edit your key
gpg --edit-key YOUR_KEY_ID

# In the GPG prompt:
trust
5  # Select "5 = I trust ultimately"
y  # Confirm
quit
```

**One-line alternative:**

```bash
echo "YOUR_KEY_ID:6:" | gpg --import-ownertrust

# Or restore from backup:
gpg --import-ownertrust < ownertrust.txt
```

### 3. Fix Permissions

This prevents the "unsafe permissions on homedir" warning:

```bash
# Fix directory permissions
chmod 700 ~/.gnupg

# Fix file permissions
chmod 600 ~/.gnupg/*

# If issues persist, fix recursively:
find ~/.gnupg -type d -exec chmod 700 {} \;
find ~/.gnupg -type f -exec chmod 600 {} \;
```

### 4. Verify Setup

```bash
# Check permissions
ls -la ~/.gnupg

# Should show:
# drwx------  .gnupg/
# -rw-------  (all files)

# Test signing
echo "test" | gpg --clearsign
```

## Configuration

GPG configuration in this repo is in `config/.gitconfig`:

```gitconfig
[user]
signingkey = YOUR_KEY_ID

[commit]
gpgsign = true

[gpg]
program = gpg
```

For Jujutsu, signing is configured in `config/.jjconfig.toml`:

```toml
[signing]
sign-all = true
backend = "gpg"
key = "YOUR_KEY_ID"
```

## When to Run This

- New work laptop
- Personal computer rebuild
- New development environment
- After restoring from backup

## Troubleshooting

### "No secret key" error

Your private key isn't imported. Go back to step 1.

### Still seeing trust warnings

Run step 2 again. Trust is machine-local and doesn't transfer with the key.

### Permissions reset after macOS update

macOS updates sometimes reset permissions. Re-run step 3.

### "Failed to sign" error

Check that GPG agent is running:

```bash
gpg-agent --daemon
```
