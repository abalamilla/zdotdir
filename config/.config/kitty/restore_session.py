"""Restore the session written by save_session.py.

Only runs in a fresh kitty: exactly one window, sitting at an empty shell
prompt. That window is closed once the saved tabs are open, so the restored
layout is all that is left. See ~/zdotdir/docs/kitty-sessions.md.
"""

import os
import subprocess
from typing import Any

from kittens.tui.handler import result_handler
from kitty.constants import config_dir

SESSION_FILE = os.path.expanduser('~/.local/share/kitty/sessions/current.kitty-session')
# nvim servers left behind by the kitty that saved the session; see the script.
ORPHAN_CLEANUP = os.path.join(os.path.realpath(config_dir), 'orphan_nvim_cleanup.sh')


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
    if os.access(ORPHAN_CLEANUP, os.X_OK):
        subprocess.Popen([ORPHAN_CLEANUP], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                         start_new_session=True)
