from pathlib import Path
import os
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).parents[1] / 'dot_local/bin/executable_desktop-display-watch'


class DisplayTests(unittest.TestCase):
    def run_check(self, active='yes', modeless=0, paused=1, owner=None, twice=False, switch_away=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / 'reloads'
            commands = {
                'loginctl': f'if [[ "$*" == *"-p User"* ]]; then printf "%s\\n" {os.getuid() if owner is None else owner}; else printf "%s\\n" {active}; fi',
                'omarchy-hyprland-reload-guard': f'exit {paused}',
                'omarchy-hyprland-monitor-modeless': f'exit {modeless}',
                'hyprctl': 'printf "%s\\n" "$*" >> "$DISPLAY_TEST_LOG"',
            }
            for name, body in commands.items():
                tool = root / name
                tool.write_text('#!/bin/bash\n' + body + '\n')
                tool.chmod(0o755)
            if switch_away:
                tool = root / 'loginctl'
                tool.write_text('#!/bin/bash\nif [[ "$*" == *"-p User"* ]]; then echo ' + str(os.getuid()) + '; elif [[ -e "$DISPLAY_TEST_LOG.active" ]]; then echo no; else touch "$DISPLAY_TEST_LOG.active"; echo yes; fi\n')
            env = dict(os.environ, PATH=str(root) + ':' + os.environ['PATH'], XDG_SESSION_ID='3', DISPLAY_TEST_LOG=str(log))
            command = ['bash', '-c', 'source "$1"; recover_display; recover_display', 'test', str(SCRIPT)] if twice else ['bash', str(SCRIPT), '--once']
            result = subprocess.run(command, env=env, capture_output=True, text=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)
            return log.read_text().splitlines() if log.exists() else []

    def test_active_modeless_display_recovers(self):
        self.assertEqual(self.run_check(), ['reload'])

    def test_inactive_session_is_never_reloaded(self):
        self.assertEqual(self.run_check(active='no'), [])

    def test_healthy_display_is_not_reloaded(self):
        self.assertEqual(self.run_check(modeless=1), [])

    def test_ipc_failure_is_not_treated_as_modeless(self):
        self.assertEqual(self.run_check(modeless=2), [])

    def test_stale_session_from_other_user_is_not_reloaded(self):
        self.assertEqual(self.run_check(owner=os.getuid() + 1), [])

    def test_persistent_mode_failure_is_rate_limited(self):
        self.assertEqual(self.run_check(twice=True), ['reload'])

    def test_switching_away_during_query_prevents_reload(self):
        self.assertEqual(self.run_check(switch_away=True), [])

    def test_package_transaction_pause_is_respected(self):
        self.assertEqual(self.run_check(paused=0), [])


if __name__ == '__main__':
    unittest.main()
