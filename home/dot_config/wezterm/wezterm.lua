-- WezTerm: GUI terminal whose job is to reach the WSL cockpit (herdr) fast.
-- Multiplexing, tabs, and session restore all belong to herdr, not here.
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Windows: land directly in WSL. The domain name is "WSL:<registered
-- distro name>" and the name varies per machine, so never hardcode it.
if wezterm.target_triple:find("windows") then
  local wsl_domains = wezterm.default_wsl_domains()
  if #wsl_domains > 0 then
    config.default_domain = wsl_domains[1].name
  end
end

-- Japanese input via the OS IME
config.use_ime = true

-- Machine-specific settings (font, theme, ...) live in local.lua next to
-- this file (created once by chezmoi, then owned by the machine).
-- Anything returned there overrides the defaults above. Examples:
--
-- config.font = wezterm.font_with_fallback({ "UDEV Gothic 35NFLG" })
-- config.font_size = 12.0
-- config.color_scheme = "Tokyo Night"
-- config.hide_tab_bar_if_only_one_tab = true
local local_path = wezterm.config_dir .. "/local.lua"
local ok, overrides = pcall(dofile, local_path)
if ok and type(overrides) == "table" then
  for k, v in pairs(overrides) do
    config[k] = v
  end
end

return config
