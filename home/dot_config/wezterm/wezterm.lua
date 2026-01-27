-- ============================================================
-- WezTerm Configuration
-- ============================================================
--
-- KEY BINDINGS CHEAT SHEET
-- ============================================================
--
-- LEADER = Ctrl + \  (timeout: 1000ms)
--
-- ┌─────────────────────────────────────────────────────────
-- │ PANE NAVIGATION
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + h/j/k/l       Move focus (left/down/up/right)
-- │ LEADER + SHIFT + HJKL  Resize pane
-- │ LEADER + f             Toggle pane zoom
-- │
-- ├─────────────────────────────────────────────────────────
-- │ PANE SPLIT
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + v             Split right (horizontal layout)
-- │ LEADER + s             Split down (vertical layout)
-- │ LEADER + x             Close pane
-- │
-- ├─────────────────────────────────────────────────────────
-- │ TAB NAVIGATION
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + i             Previous tab
-- │ LEADER + o             Next tab
-- │ LEADER + SHIFT + I     Move tab left
-- │ LEADER + SHIFT + O     Move tab right
-- │ LEADER + 1-9           Activate tab by number
-- │
-- ├─────────────────────────────────────────────────────────
-- │ TAB MANAGEMENT
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + c             New tab
-- │ LEADER + X             Close tab
-- │
-- ├─────────────────────────────────────────────────────────
-- │ SCROLL / COPY MODE
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + [             Enter copy mode
-- │ LEADER + /             Search
-- │
-- ├─────────────────────────────────────────────────────────
-- │ UTILITY
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + Space         Quick select
-- │ LEADER + :             Command palette
-- │ LEADER + ?             Debug overlay
-- │ LEADER + N             New window
-- │ CTRL + SHIFT + C/V     Copy / Paste
-- │ CTRL + -/=/0           Font size (decrease/increase/reset)
-- │
-- ├─────────────────────────────────────────────────────────
-- │ WORKSPACE (from local.lua)
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + w             Workspace list
-- │ LEADER + CTRL + w      New workspace
-- │ LEADER + ALT + [ / ]   Previous / Next workspace
-- │ LEADER + d             Domain list
-- │ LEADER + r             Reload config
-- │
-- │ NOTE: Workspace quick switch (LEADER + 1/2/...) defined
-- │       in local.lua will OVERRIDE tab number bindings.
-- │
-- ├─────────────────────────────────────────────────────────
-- │ COPY MODE (after LEADER + [)
-- ├─────────────────────────────────────────────────────────
-- │ hjkl                   Move cursor
-- │ w / b / e              Word movement
-- │ 0 / ^ / $              Line start / content start / end
-- │ g / G                  Top / Bottom of scrollback
-- │ Ctrl+f / Ctrl+b        Page down / up
-- │ Ctrl+d / Ctrl+u        Half page down / up
-- │ v / V / Ctrl+v         Select char / line / block
-- │ y                      Yank and exit
-- │ /                      Search
-- │ n / N                  Next / Previous match
-- │ q / Escape             Exit copy mode
-- └─────────────────────────────────────────────────────────

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- ============================================================
-- Local Configuration
-- ============================================================
local local_config = {
  environments = {},
  font = nil,
}

local local_config_path = wezterm.config_dir .. "/wezterm.local.lua"
local ok, result = pcall(dofile, local_config_path)
if ok and result then
  local_config = result
  wezterm.log_info("Loaded local config from " .. local_config_path)
else
  wezterm.log_warn("Local config not found or error: " .. local_config_path)
end

-- ============================================================
-- Environment Variables
-- ============================================================
-- Set LANG for UTF-8 support (required for proper Unicode display)
-- See: https://wezterm.org/faq.html
config.set_environment_variables = {
  LANG = "en_US.UTF-8",
}

-- ============================================================
-- Appearance
-- ============================================================

-- Scrollback
config.scrollback_lines = 50000

-- Window
config.window_decorations = "RESIZE"
config.window_padding = { left = 10, right = 0, top = 10, bottom = 0 }
config.macos_window_background_blur = 20
config.win32_system_backdrop = "Acrylic"

-- Font (configurable via local_config.font)
-- Fallback fonts for symbols (Windows built-in)
local symbol_fallbacks = {
  "Segoe UI Symbol",
  "Segoe UI Emoji",
}

if local_config.font and local_config.font.family then
  local font_list = {
    {
      family = local_config.font.family,
      weight = local_config.font.weight or "Regular",
      stretch = local_config.font.stretch or "Normal",
      style = local_config.font.style or "Normal",
    },
  }
  for _, fallback in ipairs(symbol_fallbacks) do
    table.insert(font_list, fallback)
  end
  config.font = wezterm.font_with_fallback(font_list)
  if local_config.font.size then
    config.font_size = local_config.font.size
  end
end
config.adjust_window_size_when_changing_font_size = true
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"

-- Colors (Tokyo Night from tokyonight.nvim extras)
config.colors = {
  foreground = "#c0caf5",
  background = "#1a1b26",
  cursor_bg = "#c0caf5",
  cursor_border = "#c0caf5",
  cursor_fg = "#1a1b26",
  selection_bg = "#283457",
  selection_fg = "#c0caf5",
  split = "#7aa2f7",
  compose_cursor = "#ff9e64",
  scrollbar_thumb = "#292e42",
  ansi = { "#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
  brights = { "#414868", "#ff899d", "#9fe044", "#faba4a", "#8db0ff", "#c7a9ff", "#a4daff", "#c0caf5" },
  tab_bar = {
    inactive_tab_edge = "#16161e",
    background = "#1a1b26",
    active_tab = { bg_color = "#7aa2f7", fg_color = "#16161e" },
    inactive_tab = { bg_color = "#292e42", fg_color = "#545c7e" },
    inactive_tab_hover = { bg_color = "#292e42", fg_color = "#7aa2f7" },
    new_tab = { bg_color = "#1a1b26", fg_color = "#7aa2f7" },
    new_tab_hover = { bg_color = "#1a1b26", fg_color = "#7aa2f7" },
  },
}

-- Pane
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.5 }
config.pane_focus_follows_mouse = true

-- Mouse
config.hide_mouse_cursor_when_typing = true
config.swallow_mouse_click_on_pane_focus = true
config.swallow_mouse_click_on_window_focus = true

-- Visual Bell
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

-- Performance
config.max_fps = 60
config.animation_fps = 60

-- Tab Bar
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 28

wezterm.on("format-tab-title", function(tab)
  local idx = tab.tab_index + 1
  local icon = tab.is_active and "●" or "○"
  return { { Text = string.format("    %s %d    ", icon, idx) } }
end)

-- Status Bar
-- Find default workspace from environments
local function find_default_workspace()
  for _, env in ipairs(local_config.environments or {}) do
    if env.is_default then
      return env.workspace_name
    end
  end
  -- Fallback to first environment
  if local_config.environments and #local_config.environments > 0 then
    return local_config.environments[1].workspace_name
  end
  return nil
end

local default_ws = find_default_workspace()
if default_ws then
  config.default_workspace = default_ws
end

-- Helper: get OS label
local function get_os_label()
  if wezterm.target_triple:match("windows") then
    return "Win"
  elseif wezterm.target_triple:match("darwin") then
    return "Mac"
  else
    return "Local"
  end
end

-- Helper: find environment config by workspace name
-- Returns the environment table or nil if not found
local function find_env_by_workspace(workspace_name)
  for _, env in ipairs(local_config.environments or {}) do
    if env.workspace_name == workspace_name then
      return env
    end
  end
  return nil
end

-- ============================================================
-- Dynamic default_prog based on active workspace
-- ============================================================
-- This mechanism ensures that new panes/tabs spawn the correct shell
-- for "local" connection workspaces (e.g., powershell.exe instead of cmd.exe).
--
-- How it works:
--   1. update-status event fires frequently (on focus, resize, etc.)
--   2. We track the last workspace per window to avoid redundant updates
--   3. When workspace changes, we call window:set_config_overrides()
--      to set default_prog for "local" connections or clear it otherwise
--
-- DEBUG: Enable logging to see when overrides are applied
-- Set to true and check logs with CTRL+SHIFT+L (or LEADER + ?)
local DEBUG_DEFAULT_PROG = false

-- Cache to track last workspace per window (keyed by window object id)
local last_workspace_cache = {}

wezterm.on("update-status", function(window, pane)
  local workspace = window:active_workspace()
  local window_id = tostring(window:window_id())

  -- Find environment config for current workspace
  local env = find_env_by_workspace(workspace)

  -- Determine domain_label for status bar
  local domain_label = nil
  if env then
    if env.connection == "connect" or env.connection == "ssh" then
      if env.remote_address == "127.0.0.1" then
        domain_label = "WSL"
      else
        domain_label = "SSH"
      end
    end
  end

  -- Fallback to OS label if not found or local connection
  if not domain_label then
    domain_label = get_os_label()
  end

  -- Update status bar
  window:set_left_status(wezterm.format({
    { Foreground = { Color = "#7aa2f7" } },
    { Text = string.format("  %s ", workspace) },
    { Foreground = { Color = "#565f89" } },
    { Text = string.format("[%s] ", domain_label) },
  }))

  -- ------------------------------------------------------------
  -- Dynamic default_prog update
  -- ------------------------------------------------------------
  if last_workspace_cache[window_id] == workspace then
    return
  end
  last_workspace_cache[window_id] = workspace

  local new_default_prog = nil
  if env and env.connection == "local" and env.args then
    new_default_prog = env.args
  end

  local overrides = window:get_config_overrides() or {}
  overrides.default_prog = new_default_prog
  window:set_config_overrides(overrides)

  if DEBUG_DEFAULT_PROG then
    local prog_str = new_default_prog and table.concat(new_default_prog, " ") or "nil"
    wezterm.log_info(string.format(
      "[default_prog] window=%s workspace=%s -> default_prog=%s",
      window_id, workspace, prog_str
    ))
  end
end)

-- ============================================================
-- Protocols
-- ============================================================
config.enable_kitty_keyboard = false
config.enable_kitty_graphics = true
config.enable_wayland = false

-- ============================================================
-- Key Bindings-- ============================================================

-- Disable all default key bindings
config.disable_default_key_bindings = true

-- Leader Key: Ctrl+\ with 1000ms timeout
-- After timeout, key input passes through to the terminal
config.leader = {
  key = "\\",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

-- ============================================================
-- Helper: Create split action with workspace-aware args
-- ============================================================
-- Problem: "CurrentPaneDomain" ignores config.default_prog and uses
--          the domain's default shell (cmd.exe for local domain).
-- Solution: Use action_callback to dynamically set args based on
--           the current workspace's environment configuration.
--
-- @param direction "Vertical" or "Horizontal"
local function create_split_action(direction)
  return wezterm.action_callback(function(window, pane)
    local workspace = window:active_workspace()
    local env = find_env_by_workspace(workspace)

    local spawn_cmd = {}

    if env and env.connection == "local" and env.args then
      spawn_cmd.args = env.args
      spawn_cmd.domain = { DomainName = "local" }
      if DEBUG_DEFAULT_PROG then
        wezterm.log_info(string.format(
          "[split] workspace=%s direction=%s args=%s domain=local",
          workspace, direction, table.concat(env.args, " ")
        ))
      end
    else
      spawn_cmd.domain = "CurrentPaneDomain"
      if DEBUG_DEFAULT_PROG then
        wezterm.log_info(string.format(
          "[split] workspace=%s direction=%s domain=CurrentPaneDomain",
          workspace, direction
        ))
      end
    end

    local action = direction == "Vertical"
        and act.SplitVertical(spawn_cmd)
        or act.SplitHorizontal(spawn_cmd)
    window:perform_action(action, pane)
  end)
end

-- ============================================================
-- Helper: Create spawn tab action with workspace-aware args
-- ============================================================
-- Same pattern as create_split_action above.
-- Ensures new tabs spawn with the correct shell for the current workspace.
local function create_spawn_tab_action()
  return wezterm.action_callback(function(window, pane)
    local workspace = window:active_workspace()
    local env = find_env_by_workspace(workspace)

    local spawn_cmd = {}

    if env and env.connection == "local" and env.args then
      spawn_cmd.args = env.args
      spawn_cmd.domain = { DomainName = "local" }
      if DEBUG_DEFAULT_PROG then
        wezterm.log_info(string.format(
          "[spawn_tab] workspace=%s args=%s domain=local",
          workspace, table.concat(env.args, " ")
        ))
      end
    else
      spawn_cmd.domain = "CurrentPaneDomain"
      if DEBUG_DEFAULT_PROG then
        wezterm.log_info(string.format(
          "[spawn_tab] workspace=%s domain=CurrentPaneDomain",
          workspace
        ))
      end
    end

    window:perform_action(act.SpawnCommandInNewTab(spawn_cmd), pane)
  end)
end

-- ============================================================
-- Keys-- ============================================================
config.keys = {
  -- ------------------------------------------------------------
  -- Direct Keys (no leader required)
  -- ------------------------------------------------------------

  -- Send S-Space to terminal (for skkeleton henkanBackward)
  { key = "Space", mods = "SHIFT",        action = act.SendKey({ key = "Space", mods = "SHIFT" }) },

  -- Clipboard operations
  { key = "C",     mods = "CTRL|SHIFT",   action = act.CopyTo("Clipboard") },
  { key = "V",     mods = "CTRL|SHIFT",   action = act.PasteFrom("Clipboard") },

  -- Font size controls
  { key = "-",     mods = "CTRL",         action = act.DecreaseFontSize },
  { key = "=",     mods = "CTRL",         action = act.IncreaseFontSize },
  { key = "0",     mods = "CTRL",         action = act.ResetFontSize },

  -- ------------------------------------------------------------
  -- Pane Navigation: LEADER + h/j/k/l
  -- ------------------------------------------------------------
  { key = "h",     mods = "LEADER",       action = act.ActivatePaneDirection("Left") },
  { key = "j",     mods = "LEADER",       action = act.ActivatePaneDirection("Down") },
  { key = "k",     mods = "LEADER",       action = act.ActivatePaneDirection("Up") },
  { key = "l",     mods = "LEADER",       action = act.ActivatePaneDirection("Right") },

  -- ------------------------------------------------------------
  -- Pane Resize: LEADER + SHIFT + H/J/K/L
  -- ------------------------------------------------------------
  { key = "H",     mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J",     mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K",     mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L",     mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- ------------------------------------------------------------
  -- Pane Split    -- v: SplitHorizontal (left|right layout) - new pane on right
  -- s: SplitVertical (top/bottom layout) - new pane on bottom
  -- ------------------------------------------------------------
  { key = "v",     mods = "LEADER",       action = create_split_action("Horizontal") },
  { key = "s",     mods = "LEADER",       action = create_split_action("Vertical") },

  -- ------------------------------------------------------------
  -- Pane Management
  -- ------------------------------------------------------------
  -- Close pane (with confirmation)
  { key = "x",     mods = "LEADER",       action = act.CloseCurrentPane({ confirm = true }) },

  -- Pane zoom (toggle fullscreen for current pane)
  { key = "f",     mods = "LEADER",       action = act.TogglePaneZoomState },

  -- ------------------------------------------------------------
  -- Tab Navigation: LEADER + i/o (previous/next)
  -- ------------------------------------------------------------
  { key = "i",     mods = "LEADER",       action = act.ActivateTabRelative(-1) },
  { key = "o",     mods = "LEADER",       action = act.ActivateTabRelative(1) },

  -- ------------------------------------------------------------
  -- Tab Reorder: LEADER + SHIFT + I/O
  -- ------------------------------------------------------------
  { key = "I",     mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
  { key = "O",     mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

  -- ------------------------------------------------------------
  -- Tab Selection by Number: LEADER + 1-9
  -- Note: WezTerm is 0-indexed, so key "1" maps to ActivateTab=0
  -- WARNING: These may be overridden by workspace quick switch from local.lua
  -- ------------------------------------------------------------
  { key = "1",     mods = "LEADER",       action = act.ActivateTab(0) },
  { key = "2",     mods = "LEADER",       action = act.ActivateTab(1) },
  { key = "3",     mods = "LEADER",       action = act.ActivateTab(2) },
  { key = "4",     mods = "LEADER",       action = act.ActivateTab(3) },
  { key = "5",     mods = "LEADER",       action = act.ActivateTab(4) },
  { key = "6",     mods = "LEADER",       action = act.ActivateTab(5) },
  { key = "7",     mods = "LEADER",       action = act.ActivateTab(6) },
  { key = "8",     mods = "LEADER",       action = act.ActivateTab(7) },
  { key = "9",     mods = "LEADER",       action = act.ActivateTab(8) },

  -- ------------------------------------------------------------
  -- Tab Management
  -- ------------------------------------------------------------
  -- New tab (workspace-aware: spawns correct shell for current workspace)
  { key = "c",     mods = "LEADER",       action = create_spawn_tab_action() },

  -- Close tab (with confirmation)
  { key = "X",     mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

  -- ------------------------------------------------------------
  -- Scroll/Copy Mode
  -- ------------------------------------------------------------
  { key = "[",     mods = "LEADER",       action = act.ActivateCopyMode },

  -- ------------------------------------------------------------
  -- Search
  -- ------------------------------------------------------------
  { key = "/",     mods = "LEADER",       action = act.Search({ CaseSensitiveString = "" }) },

  -- ------------------------------------------------------------
  -- Utility
  -- ------------------------------------------------------------
  -- Quick select mode
  { key = "Space", mods = "LEADER",       action = act.QuickSelect },

  -- Command palette
  { key = ":",     mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },

  -- Debug overlay (help/troubleshooting)
  { key = "?",     mods = "LEADER|SHIFT", action = act.ShowDebugOverlay },

  -- New window
  { key = "N",     mods = "LEADER|SHIFT", action = act.SpawnWindow },

  -- ------------------------------------------------------------
  -- Workspace Management (preserved from original config)
  -- ------------------------------------------------------------
  { key = "w",     mods = "LEADER",       action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },
  {
    key = "w",
    mods = "LEADER|CTRL",
    action = act.PromptInputLine({
      description = "New workspace name:",
      action = wezterm.action_callback(function(window, pane, name)
        if name and #name > 0 then
          window:perform_action(act.SwitchToWorkspace({ name = name }), pane)
        end
      end),
    }),
  },

  -- Workspace navigation (uses ALT to avoid conflict with copy mode '[')
  { key = "[", mods = "LEADER|ALT", action = act.SwitchWorkspaceRelative(-1) },
  { key = "]", mods = "LEADER|ALT", action = act.SwitchWorkspaceRelative(1) },

  -- Domain list
  { key = "d", mods = "LEADER",     action = act.ShowLauncherArgs({ flags = "DOMAINS" }) },

  -- Reload configuration
  { key = "r", mods = "LEADER",     action = act.ReloadConfiguration },
}

-- ============================================================
-- Copy Mode (vim-like navigation)
-- ============================================================
config.key_tables = {
  copy_mode = {
    -- Exit copy mode
    { key = "Escape", mods = "NONE",  action = act.CopyMode("Close") },
    { key = "q",      mods = "NONE",  action = act.CopyMode("Close") },

    -- Movement
    { key = "h",      mods = "NONE",  action = act.CopyMode("MoveLeft") },
    { key = "j",      mods = "NONE",  action = act.CopyMode("MoveDown") },
    { key = "k",      mods = "NONE",  action = act.CopyMode("MoveUp") },
    { key = "l",      mods = "NONE",  action = act.CopyMode("MoveRight") },

    -- Word movement
    { key = "w",      mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
    { key = "b",      mods = "NONE",  action = act.CopyMode("MoveBackwardWord") },
    { key = "e",      mods = "NONE",  action = act.CopyMode("MoveForwardWordEnd") },

    -- Line movement
    { key = "0",      mods = "NONE",  action = act.CopyMode("MoveToStartOfLine") },
    { key = "^",      mods = "NONE",  action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "$",      mods = "NONE",  action = act.CopyMode("MoveToEndOfLineContent") },

    -- Page movement
    { key = "g",      mods = "NONE",  action = act.CopyMode("MoveToScrollbackTop") },
    { key = "G",      mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "f",      mods = "CTRL",  action = act.CopyMode({ MoveByPage = 1 }) },
    { key = "b",      mods = "CTRL",  action = act.CopyMode({ MoveByPage = -1 }) },
    { key = "d",      mods = "CTRL",  action = act.CopyMode({ MoveByPage = 0.5 }) },
    { key = "u",      mods = "CTRL",  action = act.CopyMode({ MoveByPage = -0.5 }) },

    -- Selection
    { key = "v",      mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "V",      mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "v",      mods = "CTRL",  action = act.CopyMode({ SetSelectionMode = "Block" }) },

    -- Copy and exit
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({
        act.CopyTo("Clipboard"),
        act.CopyMode("Close"),
      }),
    },

    -- Search in copy mode
    { key = "/", mods = "NONE",  action = act.CopyMode("EditPattern") },
    { key = "n", mods = "NONE",  action = act.CopyMode("NextMatch") },
    { key = "N", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
  },

  search_mode = {
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "Enter",  mods = "NONE", action = act.CopyMode("AcceptPattern") },
    { key = "n",      mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p",      mods = "CTRL", action = act.CopyMode("PriorMatch") },
  },
}

-- ============================================================
-- Quick Select Patterns
-- ============================================================
config.quick_select_patterns = {
  -- URL
  "https?://[^\\s\"'<>]+",
  -- File path (Unix)
  "[\\w./~-]+/[\\w./-]+",
  -- File path (Windows)
  "[A-Za-z]:\\\\[\\w\\\\.-]+",
  -- UUID
  "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
  -- IP address
  "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}",
  -- Git commit hash (7+ chars)
  "[0-9a-f]{7,40}",
}

-- ============================================================
-- Hyperlink Rules
-- ============================================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- ============================================================
-- Apply Local Configuration
-- ============================================================

-- 1. Generate ssh_domains from environments (connection == "connect" uses WezTerm's mux protocol)
local ssh_domains = {}
for _, env in ipairs(local_config.environments or {}) do
  if env.connection == "connect" then
    table.insert(ssh_domains, {
      name = env.workspace_name,
      remote_address = env.remote_address,
      username = env.username,
      default_prog = env.default_prog,
    })
  end
end
config.ssh_domains = ssh_domains

-- 2. Generate launch_menu from environments
local launch_menu = {}
for _, env in ipairs(local_config.environments or {}) do
  local entry = { label = env.workspace_name }
  if env.connection == "connect" then
    entry.domain = { DomainName = env.workspace_name }
  elseif env.connection == "ssh" then
    entry.args = { "ssh", env.username .. "@" .. env.remote_address }
    entry.domain = { DomainName = "local" }
  else -- local
    entry.args = env.args
    entry.domain = { DomainName = "local" }
  end
  table.insert(launch_menu, entry)
end
config.launch_menu = launch_menu

-- 3. Set default_startup from is_default environment
for _, env in ipairs(local_config.environments or {}) do
  if env.is_default then
    if env.connection == "connect" then
      config.default_gui_startup_args = { "connect", env.workspace_name }
    elseif env.connection == "ssh" then
      config.default_gui_startup_args = { "ssh", env.username .. "@" .. env.remote_address }
    elseif env.args then
      config.default_prog = env.args
    end
    break
  end
end

-- 4. Workspace Quick Switch: LEADER + key (from local.lua)
-- NOTE: These bindings are added AFTER the default tab number bindings,
--       so they will OVERRIDE LEADER+1-9 for tab selection if keys overlap.
for _, env in ipairs(local_config.environments or {}) do
  if env.key then
    local spawn_config = {}
    if env.connection == "connect" then
      spawn_config.domain = { DomainName = env.workspace_name }
    elseif env.connection == "ssh" then
      spawn_config.args = { "ssh", env.username .. "@" .. env.remote_address }
      spawn_config.domain = { DomainName = "local" }
    else -- local
      spawn_config.args = env.args
      spawn_config.domain = { DomainName = "local" }
    end

    table.insert(config.keys, {
      key = env.key,
      mods = "LEADER",
      action = act.SwitchToWorkspace({
        name = env.workspace_name,
        spawn = spawn_config,
      }),
    })
  end
end

-- ============================================================
-- Apply Local Overrides (highest priority)
-- ============================================================
-- Allows wezterm.local.lua to override any config setting via config_overrides.
-- This is applied last, so local settings always take precedence.
-- Example in wezterm.local.lua:
--   config_overrides = {
--     leader = { key = "w", mods = "CTRL", timeout_milliseconds = 1000 },
--     front_end = "OpenGL",
--   },
if local_config.config_overrides then
  for key, value in pairs(local_config.config_overrides) do
    config[key] = value
  end
end

return config
