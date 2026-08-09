-- WezTerm: this GUI terminal reaches the WSL cockpit (herdr) fast.
-- Multiplexing and session restore belong to herdr. WezTerm's own tabs
-- exist only to cross the OS shell boundary between WSL and PowerShell.
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Windows: land directly in WSL. The domain name is "WSL:<registered
-- distro name>" and the name varies per machine, so never hardcode it.
if wezterm.target_triple:find("windows") then
  local wsl_domains = wezterm.default_wsl_domains()
  if #wsl_domains > 0 then
    config.default_domain = wsl_domains[1].name
  end

  -- New tabs still default to WSL above. This only adds an entry to the
  -- launcher and to the new-tab button's right-click menu. That entry
  -- starts PowerShell (winget: Microsoft.PowerShell). domain = "local"
  -- runs pwsh.exe on the Windows side directly, not through WSL interop.
  config.launch_menu = {
    { label = "PowerShell", args = { "pwsh.exe", "-NoLogo" }, domain = { DomainName = "local" } },
  }
end

-- Japanese input via the OS IME
config.use_ime = true

-- Leader for GUI-layer bindings. Ctrl+, has no terminal control code, so
-- claiming it does not conflict with bash, tmux, or nvim below.
config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 1000 }

-- Tracer palette (https://github.com/y4m3/tracer-color), auto-loaded from
-- colors/tracer.toml next to this file. local.lua can still override it.
config.color_scheme = "Tracer"

-- config.colors overlays specific keys onto color_scheme without replacing
-- it, so everything but the tab bar still comes from Tracer above.
-- colors/tracer.toml supplies the values below directly. If this grows
-- past the tab bar, it should move upstream into tracer-color's build.py
-- as [colors.tab_bar] instead of living here.
config.colors = {
  tab_bar = {
    background = "#111C18", -- background
    -- Active tab: green fill with the darkest text, the same chip
    -- pattern the tmux status line uses for the current window.
    active_tab = { bg_color = "#4FB87C", fg_color = "#06120C" }, -- ansi green / cursor_fg
    inactive_tab = { bg_color = "#14201C", fg_color = "#788880" }, -- ansi black / brights black
    inactive_tab_hover = { bg_color = "#2B4038", fg_color = "#6FE89B" }, -- selection_bg / cursor_bg
    new_tab = { bg_color = "#111C18", fg_color = "#4FB87C" },
    new_tab_hover = { bg_color = "#111C18", fg_color = "#6FE89B" },
  },
}

-- Tabs exist to cross the OS shell boundary (WSL vs PowerShell). herdr
-- multiplexes inside WSL. With a single tab the bar is just chrome, so
-- hide it until a second shell opens.
config.hide_tab_bar_if_only_one_tab = true

-- Drop the native title bar (no more "wslhost.exe" caption) and let the
-- tab bar carry the integrated buttons instead. With 2+ tabs, the tab bar
-- covers drag and min/max/close. With a single tab, there is zero chrome.
-- But CTRL+SHIFT+drag still moves the window, and Win-key shortcuts
-- still cover minimize, maximize, and close.
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Retro (non-fancy) tab bar: plain text chips instead of the fancy
-- rounded-corner renderer. This caps tab width so a long shell path
-- cannot take space from the other tabs.
config.use_fancy_tab_bar = false
config.tab_max_width = 28

-- The default tab title is the foreground process name, which on a WSL
-- pane is wslhost.exe. Show the distro instead. For anything else, strip
-- the path and the ".exe" so pwsh.exe reads as pwsh. Prefix the label
-- with a filled or hollow dot marking whether the tab is active.
wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  local pane = tab.active_pane
  local distro = (pane.domain_name or ""):match("^WSL:(.+)$")
  local label

  if distro then
    label = distro
  else
    local proc = pane.foreground_process_name
    if proc and proc ~= "" then
      label = proc:match("([^/\\]+)$") or proc
      label = label:gsub("%.exe$", "")
    else
      label = "shell"
    end
  end

  local icon = tab.is_active and "●" or "○"
  -- -6 is the exact chrome around the label: 4 padding chars, the icon,
  -- and its trailing space. format-tab-title runs twice. The second run
  -- gets the tab's allocated width as max_width. Extra slack here removes
  -- one label character.
  label = wezterm.truncate_right(label, math.max(1, max_width - 6))
  return string.format("  %s %s  ", icon, label)
end)

-- A beep is jarring in a WSL cockpit. Flash the cursor color instead.
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

-- The click that brings this window to the front shouldn't also reach
-- the TUI running inside it.
config.swallow_mouse_click_on_window_focus = true

-- Machine-specific settings (font, theme, ...) live in local.lua next to
-- this file (created once by chezmoi, then owned by the machine).
-- Anything returned there overrides the defaults above.
-- See local.lua itself for examples.
local local_path = wezterm.config_dir .. "/local.lua"
local ok, overrides = pcall(dofile, local_path)
if not ok then
  -- Without this, a broken local.lua fails closed and silently drops all
  -- machine-local settings. Visible in the debug overlay (Ctrl+Shift+L).
  wezterm.log_error("failed to load " .. local_path .. ": " .. tostring(overrides))
elseif type(overrides) == "table" then
  for k, v in pairs(overrides) do
    config[k] = v
  end
end

return config
