#!/usr/bin/env python3
"""Strava OAuth flow without PKCE. Writes tokens to ~/.strava-mcp/tokens.json.

Requires ~/.strava-mcp/config.json with STRAVA_CLIENT_ID and STRAVA_CLIENT_SECRET
(optionally STRAVA_REDIRECT_URI, default http://127.0.0.1:3000/callback).
"""
import json
import os
import secrets
import sys
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.error import HTTPError
from urllib.parse import parse_qs, urlencode, urlparse
from urllib.request import Request, urlopen

CONFIG_PATH = os.path.expanduser("~/.strava-mcp/config.json")
TOKEN_PATH = os.path.expanduser("~/.strava-mcp/tokens.json")
SCOPES = "read,activity:read_all,profile:read_all"
CALLBACK_TIMEOUT_SECONDS = 180


def load_config():
    try:
        with open(CONFIG_PATH) as f:
            cfg = json.load(f)
        return (
            cfg["STRAVA_CLIENT_ID"],
            cfg["STRAVA_CLIENT_SECRET"],
            cfg.get("STRAVA_REDIRECT_URI", "http://127.0.0.1:3000/callback"),
        )
    except (OSError, KeyError, json.JSONDecodeError) as e:
        sys.exit(f"ERROR: cannot read {CONFIG_PATH}: {e!r}")


def wait_for_code(redirect_uri, expected_state):
    captured = {}

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, format, *args):  # noqa: A002
            del format, args

        def do_GET(self):
            qs = parse_qs(urlparse(self.path).query)
            ok = "code" in qs and qs.get("state", [None])[0] == expected_state
            if ok:
                captured["code"] = qs["code"][0]
            self.send_response(200 if ok else 400)
            self.end_headers()
            msg = "Authorized. Return to the terminal." if ok else "Invalid callback."
            self.wfile.write(f"<h2>{msg}</h2>".encode())

    server = HTTPServer(("127.0.0.1", urlparse(redirect_uri).port), Handler)
    server.timeout = CALLBACK_TIMEOUT_SECONDS
    server.handle_request()
    server.server_close()
    return captured.get("code")


def exchange_code(client_id, client_secret, code):
    data = urlencode(
        {
            "client_id": client_id,
            "client_secret": client_secret,
            "code": code,
            "grant_type": "authorization_code",
        }
    ).encode()
    try:
        with urlopen(Request("https://www.strava.com/oauth/token", data=data)) as resp:
            return json.loads(resp.read())
    except HTTPError as e:
        sys.exit(f"ERROR {e.code}: {e.read().decode()}")


def save_tokens(tokens):
    os.makedirs(os.path.dirname(TOKEN_PATH), mode=0o700, exist_ok=True)
    fd = os.open(TOKEN_PATH, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump(tokens, f, indent=2)


def main():
    client_id, client_secret, redirect_uri = load_config()
    state = secrets.token_urlsafe(16)
    auth_url = "https://www.strava.com/oauth/authorize?" + urlencode(
        {
            "client_id": client_id,
            "redirect_uri": redirect_uri,
            "response_type": "code",
            "approval_prompt": "force",
            "scope": SCOPES,
            "state": state,
        }
    )

    print("Opening browser for Strava authorization...")
    webbrowser.open(auth_url)
    print("Waiting for callback...")
    code = wait_for_code(redirect_uri, state)
    if not code:
        sys.exit("ERROR: no valid authorization code received.")

    print("Code received, exchanging for tokens...")
    tokens = exchange_code(client_id, client_secret, code)
    save_tokens(tokens)

    print(f"\nTokens saved to {TOKEN_PATH}")
    print(f"Scope:      {tokens.get('scope', 'n/a')}")
    print(f"Expires at: {tokens.get('expires_at', 'n/a')}")


if __name__ == "__main__":
    main()
