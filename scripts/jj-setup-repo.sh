#!/usr/bin/env bash
# Auto-configure jj repo based on git remote URL
# Usage: jj-setup-repo.sh [repo-path]
#
# Environment variables:
#   JJ_OFFICE_EMAIL - Email to use for office repos (required for office setup)
#   JJ_OFFICE_GPG_KEY - GPG key ID for office repos (optional)

set -euo pipefail

REPO_PATH="${1:-.}"
cd "$REPO_PATH"

# Check if this is a jj repo
if [[ ! -d ".jj" ]]; then
  echo "Error: Not a jj repository"
  exit 1
fi

# Get the actual repo config path from jj
REPO_CONFIG_PATH=$(jj config path --repo 2>/dev/null || echo "")
if [[ -z "$REPO_CONFIG_PATH" ]]; then
  echo "Error: Could not determine repo config path"
  exit 1
fi

# Get git remotes
REMOTES=$(git remote -v 2>/dev/null | grep "git@gitlab" || true)

if [[ -n "$REMOTES" ]]; then
  if [[ -z "${JJ_OFFICE_EMAIL:-}" ]]; then
    echo "Error: Office repo detected but JJ_OFFICE_EMAIL not set"
    echo "Set it in your shell config: export JJ_OFFICE_EMAIL='your.email@work.com'"
    exit 1
  fi

  echo "Detected office GitLab remote, configuring for work..."

  # Create repo-specific config at the correct location
  cat >"$REPO_CONFIG_PATH" <<EOF
# Office repository configuration
# This file is repo-specific and should not be committed

[user]
name = "Abraham Alamilla"
email = "$JJ_OFFICE_EMAIL"

[signing]
sign-all = true
backend = "gpg"
${JJ_OFFICE_GPG_KEY:+key = \"$JJ_OFFICE_GPG_KEY\"}

# Revset aliases
[revset-aliases]
'mine()' = 'author(exact:"$JJ_OFFICE_EMAIL")'
EOF

  echo "✓ Configured for office email"
  echo "  Email: $JJ_OFFICE_EMAIL"
  [[ -n "${JJ_OFFICE_GPG_KEY:-}" ]] && echo "  GPG Key: $JJ_OFFICE_GPG_KEY"
  echo "  Config: $REPO_CONFIG_PATH"
else
  echo "Personal repository detected"
  echo "Using default configuration from ~/.jjconfig.toml"
  echo ""
  echo "Note: If you want to override settings for this repo, edit:"
  echo "  $REPO_CONFIG_PATH"
fi
