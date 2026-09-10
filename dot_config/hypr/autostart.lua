-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Keep the native ChatGPT app ready on the dedicated AI workspace.
o.launch_on_start("chatgpt")

-- Keep Chromium Shortwave ready on the Email workspace.
o.exec_on_start(o.launch_webapp_sole("shortwave", "https://app.shortwave.com"))
