-- WezTerm config — the Windows/WSL terminal (macOS keeps ghostty/config).
-- Mirrors the Ghostty setup: JetBrains Mono Nerd Font, Catppuccin auto
-- light/dark, padding, translucency, and the same split keybindings.
-- Lives at C:\Users\<you>\.wezterm.lua (install.sh copies it there from WSL).
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Launch straight into WSL. Adjust if your distro isn't named "Ubuntu"
-- (run `wsl -l` on Windows to check; WezTerm also auto-discovers WSL domains).
config.default_domain = "WSL:Ubuntu"

-- Font — install "JetBrainsMono Nerd Font" on the Windows side (see README)
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14.0

-- Theme: follow the Windows light/dark appearance (Catppuccin Latte / Mocha)
local function scheme_for(appearance)
  if appearance:find("Dark") then
    return "Catppuccin Mocha"
  end
  return "Catppuccin Latte"
end
config.color_scheme = scheme_for(wezterm.gui.get_appearance())

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
