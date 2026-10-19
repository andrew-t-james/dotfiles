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
        with patch.object(session.threading, 'Event', side_effect=[stopping, shutdown]), patch.object(session.threading, 'Thread') as thread, patch.object(session.subprocess, 'Popen') as monitor, patch.object(session, 'restore_once'), patch.object(session, 'login_marker') as marker, patch.object(session, 'Placements') as placements, patch.object(session, 'save') as save:
            marker.return_value.exists.return_value = False
            monitor.return_value.stdout = ['signal member=PrepareForShutdown\n', '   boolean true\n']
            # Deliver the actual D-Bus monitor output before the capture loop.
            thread.return_value.start.side_effect = lambda: thread.call_args.kwargs['target']()
            session.watch()
            save.assert_not_called()
            placements.return_value.update.assert_not_called()
            monitor.return_value.terminate.assert_called_once()

    def test_restore_skips_already_open_apps(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / 'apps.json'
            state.write_text('[{"class":"Slack","kind":"desktop","target":"/apps/slack.desktop"}]')
            with patch.object(session, 'STATE', state), patch.object(session, 'clients', return_value=[{'class': 'Slack'}]), patch.object(session.subprocess, 'Popen') as launch:
                session.restore()
                launch.assert_not_called()


class PlacementTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        state = patch.object(session, 'STATE', Path(self.directory.name) / 'apps.json')
        state.start()
        self.addCleanup(state.stop)

    def window(self, address='0x1', wmclass='editor', workspace=3, floating=False):
        return {'address': address, 'class': wmclass, 'initialClass': wmclass,
                'workspace': {'id': workspace, 'name': str(workspace)},
                'mapped': True, 'floating': floating, 'at': [100, 200], 'size': [800, 600]}

    def test_closed_app_location_survives_empty_session_and_next_login(self):
        tracker = session.Placements()
        tracker.update([self.window()], restore=False)
        tracker.update([])
        restored = session.Placements()
        with patch.object(session, 'apply_placement') as move:
            restored.update([self.window('0x2', workspace=9)])
        self.assertEqual(move.call_args.args[1]['workspace'], '3')
        self.assertEqual(restored.saved['editor'][0]['workspace'], '3')
        self.assertEqual(session.json.loads(restored.path.read_text())['editor'][0]['workspace'], '3')
        self.assertEqual(restored.path.stat().st_mode & 0o777, 0o600)

    def test_user_moves_are_learned_without_repeatedly_forcing_old_location(self):
        tracker = session.Placements()
        tracker.update([self.window()], restore=False)
        with patch.object(session, 'apply_placement') as move:
            tracker.update([self.window(workspace=8)])
            tracker.update([])
            tracker.update([self.window('0x2', workspace=1)])
        move.assert_called_once()
        self.assertEqual(move.call_args.args[1]['workspace'], '8')

    def test_multiple_windows_keep_separate_location_slots(self):
        windows = [self.window('0x1', workspace=3), self.window('0x2', workspace=4)]
        session.Placements().update(windows, restore=False)
        tracker = session.Placements()
        with patch.object(session, 'apply_placement') as move:
            tracker.update([self.window('0xa', workspace=1), self.window('0xb', workspace=1)])
        self.assertEqual([call.args[1]['workspace'] for call in move.call_args_list], ['3', '4'])

    def test_native_and_browser_webapps_keep_independent_locations(self):
        windows = [self.window(wmclass='chromium', workspace=4),
                   self.window('0x2', wmclass='chrome-app.slack.com__-Default', workspace=2)]
        tracker = session.Placements()
        tracker.update(windows, restore=False)
        self.assertEqual(tracker.saved['chromium'][0]['workspace'], '4')
        self.assertEqual(tracker.saved['chrome-app.slack.com__-Default'][0]['workspace'], '2')

    def test_restart_learns_current_locations_without_moving_live_windows(self):
        session.Placements().update([self.window()], restore=False)
        with patch.object(session, 'apply_placement') as move:
            tracker = session.Placements()
            tracker.update([self.window(workspace=4)], restore=False)
            tracker.update([self.window(workspace=4)])
        move.assert_not_called()
        self.assertEqual(tracker.saved['editor'][0]['workspace'], '4')

    def test_failed_move_retries_without_overwriting_saved_location(self):
        session.Placements().update([self.window()], restore=False)
        tracker = session.Placements()
        with patch.object(session, 'apply_placement', side_effect=session.subprocess.TimeoutExpired('hyprctl', 5)):
            with self.assertRaises(session.subprocess.TimeoutExpired):
                tracker.update([self.window('0x2', workspace=9)])
        self.assertNotIn('0x2', tracker.slots)
        self.assertEqual(tracker.saved['editor'][0]['workspace'], '3')
        with patch.object(session, 'apply_placement') as move:
            tracker.update([self.window('0x2', workspace=9)])
        move.assert_called_once()

    def test_named_and_special_workspaces(self):
        window = self.window()
        for name, expected in [('development', 'name:development'), ('special:notes', 'special:notes')]:
            window['workspace']['name'] = name
            self.assertEqual(session.placement(window)['workspace'], expected)

    def test_failed_write_is_retried_even_if_no_window_has_changed(self):
        tracker = session.Placements()
        with patch.object(session, 'write_state', side_effect=OSError('temporarily unavailable')):
            with self.assertRaises(OSError):
                tracker.update([self.window()], restore=False)
        self.assertTrue(tracker.dirty)
        tracker.update([self.window()])
        self.assertFalse(tracker.dirty)
        self.assertEqual(session.json.loads(tracker.path.read_text())['editor'][0]['workspace'], '3')

    def test_pinned_and_unmapped_windows_do_not_replace_main_app_locations(self):
        tracker = session.Placements()
        tracker.update([self.window()], restore=False)
        for flag, value in [('pinned', True), ('mapped', False)]:
            window = self.window(workspace=9)
            window[flag] = value
            tracker.update([window])
        self.assertEqual(tracker.saved['editor'][0]['workspace'], '3')

    def test_floating_window_restores_size_position_and_uses_silent_lua_dispatch(self):
        window = self.window(floating=True)
        saved = session.placement(window)
        window['floating'] = False
        with patch.object(session.subprocess, 'run') as run:
            session.apply_placement(window, saved)
        command = run.call_args.args[0]
        self.assertEqual(command[:2], ['hyprctl', 'eval'])
        self.assertIn('follow=false', command[2])
        self.assertIn('action="set"', command[2])
        self.assertIn('x=800, y=600, relative=false', command[2])
        self.assertIn('x=100, y=200, relative=false', command[2])

    def test_lua_strings_escape_quotes_backslashes_newlines_and_unicode(self):
        self.assertEqual(session.lua_string('"\\\n😀'), '"\\034\\092\\010\\240\\159\\152\\128"')


if __name__ == '__main__':
    unittest.main()
