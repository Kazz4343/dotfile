-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	-- hl.exec_cmd("hyprpaper")
	hl.exec_cmd("quickshell")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("systemctl --user start xdg-desktop-portal")
	hl.exec_cmd("swaync")
	hl.exec_cmd("hyprctl setcursor Bibata-Material-Brown 47")
	-- hl.exec_cmd("qs -p ~/.config/quickshell/shell.qml")
end)
