"""Restore the session written by save_session.py.

Only runs in a fresh kitty: exactly one window, sitting at an empty shell
prompt. That window is closed once the saved tabs are open, so the restored
layout is all that is left. See ~/zdotdir/docs/kitty-sessions.md.
"""

import os
from typing import Any

from kittens.tui.handler import result_handler

SESSION_FILE = os.path.expanduser('~/.local/share/kitty/sessions/current.kitty-session')


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Any) -> None:
    if not os.path.exists(SESSION_FILE):
        boss.show_error('No saved session', f'{SESSION_FILE} does not exist. Save one with kitty_mod+alt+s.')
        return
    windows = list(boss.all_windows)
    fresh = len(windows) == 1 and windows[0].as_dict().get('at_prompt')
    if not fresh:
        boss.show_error(
            'Restore needs a fresh kitty',
            f'Found {len(windows)} windows. Restore only runs when kitty has a single window at an empty prompt, '
            'so saved Claude sessions are not resumed twice. Close the other windows or open a new kitty instance.',
        )
        return
    original = windows[0]
    boss.goto_session(SESSION_FILE)
    boss.mark_window_for_close(original)
