-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "60")
hl.env("HYPRCURSOR_SIZE", "47")
hl.env("HYPRCURSOR_THEME", "MyCursor")

--Nvidia
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GBM_BACKEND", "nvidia-drm")

-- Toolkit backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env(
	"XDG_DATA_DIRS",
	"$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
)

-- Steam
-- Fix Steam context menus and tooltips flickering/crashing in Hyprland
hl.window_rule({
	match = { class = "^(steam)$", title = "^()$" },
	stay_focused = true,
	min_size = { 1, 1 },
})

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
	render = {
		direct_scanout = 0, -- or false depending on your wrapper version
	},
})
