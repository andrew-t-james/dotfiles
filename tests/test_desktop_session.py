import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

loader = importlib.machinery.SourceFileLoader('desktop_session', str(Path(__file__).parents[1] / 'dot_local/bin/executable_desktop-session'))
spec = importlib.util.spec_from_loader(loader.name, loader)
session = importlib.util.module_from_spec(spec)
loader.exec_module(session)


class SessionTests(unittest.TestCase):
    def test_any_native_desktop_class(self):
        entries = [(Path('/apps/slack.desktop'), 'Slack', ['slack']), (Path('/apps/editor.desktop'), 'Editor', ['editor'])]
        for name in ['Slack', 'Editor']:
            app = session.launcher({'class': name}, entries, '/usr/bin/irrelevant')
            self.assertEqual(app['kind'], 'desktop')
            self.assertEqual(app['target'], f'/apps/{name.lower()}.desktop')

    def test_webapps_with_same_browser_pid_are_distinct(self):
        entries = [(Path('/apps/mail.desktop'), '', ['omarchy-launch-webapp', 'https://mail.example.com']), (Path('/apps/chat.desktop'), '', ['omarchy-launch-webapp', 'https://chat.example.com/'])]
        targets = [session.launcher({'class': f'chrome-{host}.example.com__-Default'}, entries, '/usr/lib/chromium/chromium')['target'] for host in ['mail', 'chat']]
        self.assertEqual(targets, ['/apps/mail.desktop', '/apps/chat.desktop'])

    def test_unknown_webapp_is_not_replaced_by_browser(self):
        self.assertIsNone(session.launcher({'class': 'chrome-missing.example__-Default'}, [], '/usr/lib/chromium/chromium'))

    def test_generic_fallback_does_not_replay_process_arguments(self):
        self.assertEqual(session.launcher({'class': 'new-gui'}, [], '/opt/new-gui')['target'], '/opt/new-gui')
        self.assertIsNone(session.launcher({'class': 'unknown'}, [], '/usr/bin/python3'))

    def test_closed_app_disappears_and_ipc_failure_preserves_state(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / 'apps.json'
            with patch.object(session, 'STATE', state):
                with patch.object(session, 'snapshot', return_value=[{'class': 'Slack'}]):
                    session.save()
                with patch.object(session, 'snapshot', side_effect=RuntimeError('IPC unavailable')):
                    with self.assertRaises(RuntimeError):
                        session.save()
                self.assertIn('Slack', state.read_text())
                with patch.object(session, 'snapshot', return_value=[]):
                    session.save()
                self.assertEqual(state.read_text(), '[]\n')

    def test_browser_restore_precedes_webapps(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            browser, desktop = root / 'chromium', root / 'chat.desktop'
            browser.touch()
            desktop.touch()
            state = root / 'apps.json'
            state.write_text(session.json.dumps([
                {'class': 'chrome-chat__-Default', 'kind': 'desktop', 'target': str(desktop)},
                {'class': 'chromium', 'kind': 'browser', 'target': str(browser)},
            ]))
            with patch.object(session, 'STATE', state), patch.object(session, 'clients', side_effect=[[], [{'class': 'chromium'}]]), patch.object(session.time, 'sleep'), patch.object(session.subprocess, 'Popen') as launch:
                session.restore()
                self.assertEqual(launch.call_args_list[0].args[0], ['uwsm-app', '--', str(browser), '--restore-last-session'])
                self.assertEqual(launch.call_args_list[1].args[0], ['uwsm-app', '--', 'gio', 'launch', str(desktop)])

    def test_watcher_restart_does_not_reopen_closed_apps(self):
        with tempfile.TemporaryDirectory() as directory:
            env = {'XDG_RUNTIME_DIR': directory, 'HYPRLAND_INSTANCE_SIGNATURE': 'one-login'}
            with patch.dict(session.os.environ, env), patch.object(session, 'restore') as restore:
                session.restore_once()
                session.restore_once()
                self.assertEqual(restore.call_count, 1)
                session.os.environ['HYPRLAND_INSTANCE_SIGNATURE'] = 'next-login'
                session.restore_once()
                self.assertEqual(restore.call_count, 2)

    def test_transient_capture_failure_keeps_watcher_alive(self):
        with patch.object(session, 'save', side_effect=[session.subprocess.TimeoutExpired('hyprctl', 5), []]) as save:
            session.try_save()
            session.try_save()
            self.assertEqual(save.call_count, 2)

    def test_shutdown_freezes_snapshot_through_watcher_stop(self):
        real_event = session.threading.Event
        stopping, shutdown = real_event(), real_event()
        waits = []
        def wait(seconds):
            waits.append(seconds)
            if len(waits) == 2:
                stopping.set()
        stopping.wait = wait
        with patch.object(session.threading, 'Event', side_effect=[stopping, shutdown]), patch.object(session.threading, 'Thread') as thread, patch.object(session.subprocess, 'Popen') as monitor, patch.object(session, 'restore_once'), patch.object(session, 'save') as save:
            monitor.return_value.stdout = ['signal member=PrepareForShutdown\n', '   boolean true\n']
            # Deliver the actual D-Bus monitor output before the capture loop.
            thread.return_value.start.side_effect = lambda: thread.call_args.kwargs['target']()
            session.watch()
            save.assert_not_called()
            monitor.return_value.terminate.assert_called_once()

    def test_restore_skips_already_open_apps(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / 'apps.json'
            state.write_text('[{"class":"Slack","kind":"desktop","target":"/apps/slack.desktop"}]')
            with patch.object(session, 'STATE', state), patch.object(session, 'clients', return_value=[{'class': 'Slack'}]), patch.object(session.subprocess, 'Popen') as launch:
                session.restore()
                launch.assert_not_called()


if __name__ == '__main__':
    unittest.main()
