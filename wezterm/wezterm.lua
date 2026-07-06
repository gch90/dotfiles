-- WezTerm config — the Windows/WSL terminal (macOS keeps ghostty/config).
-- Mirrors the Ghostty setup: JetBrains Mono Nerd Font, iTerm2 Default theme,
-- padding, translucency, and the same split keybindings.
-- Lives at C:\Users\<you>\.wezterm.lua (install.sh copies it there from WSL).
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Launch straight into WSL. Adjust if your distro isn't named "Ubuntu"
-- (run `wsl -l` on Windows to check; WezTerm also auto-discovers WSL domains).
config.default_domain = "WSL:Ubuntu"

-- Font — install "JetBrainsMono Nerd Font" on the Windows side (see README)
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0

-- Theme: iTerm2 Default — same as the Ghostty config, spelled out
-- explicitly so it doesn't depend on WezTerm's bundled scheme names.
config.colors = {
  foreground = "#C7C7C7",
  background = "#000000",
  cursor_bg = "#C7C7C7",
  cursor_border = "#C7C7C7",
  cursor_fg = "#000000",
  selection_bg = "#B5D5FF",
  selection_fg = "#000000",
  ansi = { "#000000", "#C91B00", "#00C200", "#C7C400", "#0225C7", "#CA30C7", "#00C5C7", "#C7C7C7" },
  brights = { "#686868", "#FF6E67", "#5FFA68", "#FFFC67", "#6871FF", "#FF77FF", "#60FDFF", "#FFFFFF" },
}

-- Window
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
config.window_background_opacity = 0.97
config.win32_system_backdrop = "Acrylic" -- translucency/blur on Windows 11
config.window_close_confirmation = "AlwaysPrompt"

-- Behaviour
config.scrollback_lines = 100000
config.default_cursor_style = "SteadyBlock"
config.hide_mouse_cursor_when_typing = true

-- Keybindings (CTRL+SHIFT — Windows-idiomatic; mirrors the Ghostty splits).
-- CTRL+SHIFT+C/V stay as WezTerm's default copy/paste.
config.keys = {
  { key = "Enter", mods = "CTRL|SHIFT", action = act.ToggleFullScreen },
  { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
}

return config
