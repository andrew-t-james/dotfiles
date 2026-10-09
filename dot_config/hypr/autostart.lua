-- Restore the applications this account had open, then track session changes.
-- The service stops before the compositor and saves state per user.
o.exec_on_start("systemctl --user start desktop-session.service")
