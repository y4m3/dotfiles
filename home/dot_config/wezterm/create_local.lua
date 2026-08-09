-- Machine-local WezTerm overrides. Created once by chezmoi, then yours.
-- Return a table. Any config.* key works. WezTerm applies it last, so
-- anything here wins over the shared defaults in wezterm.lua.
return {
  -- Font.
  -- font = require("wezterm").font_with_fallback({ "UDEV Gothic 35NFLG" }),
  -- font_size = 12.0,

  -- Color scheme (overrides the shared Tracer default).
  -- color_scheme = "Tokyo Night",

  -- Pin the default WSL distro instead of "whichever comes first". Get
  -- the exact name from `wsl -l -v` on Windows, not wezterm's own
  -- `wezterm cli list-clients` (that lists panes, not distros).
  -- default_domain = "WSL:Ubuntu-24.04",

  -- Land on Windows itself instead of WSL: skip the WSL domain and hand
  -- the default program straight to PowerShell.
  -- default_domain = "local",
  -- default_prog = { "pwsh.exe", "-NoLogo" },

  -- Replace the shared launch_menu entirely. Tables merge shallowly, so
  -- returning launch_menu here drops the WSL config's PowerShell entry
  -- unless you repeat it below.
  -- launch_menu = {
  --   { label = "PowerShell", args = { "pwsh.exe", "-NoLogo" }, domain = { DomainName = "local" } },
  --   { label = "cmd", args = { "cmd.exe" }, domain = { DomainName = "local" } },
  -- },

  -- Extra key bindings. The shared config defines the leader Ctrl+, but
  -- no LEADER bindings. WezTerm adopts keys returned here wholesale.
  -- keys = {
  --   { key = "p", mods = "LEADER", action = require("wezterm").action.SpawnCommandInNewTab({ args = { "pwsh.exe", "-NoLogo" }, domain = { DomainName = "local" } }) },
  -- },

  -- Keep the tab bar visible even with a single tab.
  -- hide_tab_bar_if_only_one_tab = false,
}
