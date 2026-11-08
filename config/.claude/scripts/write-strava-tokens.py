#!/usr/bin/env python3
"""Write Strava tokens (entered via hidden prompt) to ~/.strava-mcp/tokens.json."""
import getpass
import json
import os
import time

TOKEN_DIR = os.path.expanduser("~/.strava-mcp")
TOKEN_PATH = os.path.join(TOKEN_DIR, "tokens.json")


def main():
    print("Strava token setup - values are not echoed to the terminal\n")
    access = getpass.getpass("Access token:  ").strip()
    refresh = getpass.getpass("Refresh token: ").strip()

    payload = {
        "token_type": "Bearer",
        "access_token": access,
        "refresh_token": refresh,
        # Already expired so the MCP package refreshes it on first use.
        "expires_at": int(time.time()) - 1,
        "scope": "read,activity:read_all,profile:read_all",
    }

    os.makedirs(TOKEN_DIR, mode=0o700, exist_ok=True)
    fd = os.open(TOKEN_PATH, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump(payload, f, indent=2)

    print(f"\nWritten to {TOKEN_PATH}")


if __name__ == "__main__":
    main()
