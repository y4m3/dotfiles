-- =========================================================
-- Key Bindings Cheat Sheet
-- =========================================================
--
-- LEADER = Ctrl + \
--
-- ┌─────────────────────────────────────────────────────────
-- │ PANE
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + -           Split down
-- │ LEADER + \           Split right
-- │ LEADER + CTRL + d    Close pane
-- │ LEADER + hjkl        Move focus
-- │ LEADER + SHIFT + hjkl  Resize
-- │ LEADER + z           Toggle zoom
-- │ LEADER + s           Swap panes
-- │
-- ├─────────────────────────────────────────────────────────
-- │ TAB
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + t           Tab list
-- │ LEADER + CTRL + t    New tab
-- │ LEADER + SHIFT + t   Close tab
-- │ LEADER + n           Next tab
-- │ LEADER + SHIFT + n   Previous tab
-- │
-- ├─────────────────────────────────────────────────────────
-- │ WORKSPACE
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + w           Workspace list
-- │ LEADER + CTRL + w    New workspace
-- │ LEADER + [ / ]       Previous / Next workspace
-- │ LEADER + 1-9         Quick switch (defined in local.lua)
-- │
-- ├─────────────────────────────────────────────────────────
-- │ UTILITY
-- ├─────────────────────────────────────────────────────────
-- │ LEADER + Space       Launcher
-- │ LEADER + d           Domain list
-- │ LEADER + c           Copy mode
-- │ LEADER + f           Quick select
-- │ LEADER + r           Reload config
-- │ CTRL + SHIFT + v     Paste from clipboard
-- │
-- ├─────────────────────────────────────────────────────────
-- │ COPY MODE (after LEADER + c)
-- ├─────────────────────────────────────────────────────────
-- │ hjkl                 Move cursor
-- │ w / b                Forward / Backward word
-- │ 0 / $                Start / End of line
-- │ g / G                Top / Bottom of scrollback
-- │ v / V                Select char / line
-- │ y                    Yank and exit
-- │ /                    Search
-- │ q / Escape           Exit copy mode
-- └─────────────────────────────────────────────────────────

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- =========================================================
-- Local Configuration
-- =========================================================
local local_config = {
    ssh_domains = {},
    default_startup = nil,
    launch_menu = {},
    workspaces = {},
}

local local_config_path = wezterm.config_dir .. "/wezterm.local.lua"
local ok, result = pcall(dofile, local_config_path)
if ok and result then
    local_config = result
    wezterm.log_info("Loaded local config from " .. local_config_path)
else
    wezterm.log_warn("Local config not found or error: " .. local_config_path)
end

-- =========================================================
-- Appearance
-- =========================================================

-- Scrollback
config.scrollback_lines = 50000

-- Window
config.window_decorations = "RESIZE"
config.window_padding = { left = 10, right = 0, top = 10, bottom = 0 }
config.window_background_gradient = {
    colors = { "#14141a", "#1a1b26", "#1c1c24" },
    orientation = { Linear = { angle = -15.0 } },
}
config.macos_window_background_blur = 20
config.win32_system_backdrop = "Acrylic"

-- Font (configurable via local_config.font)
-- If not configured, WezTerm uses its built-in default font
if local_config.font and local_config.font.family then
    config.font = wezterm.font(local_config.font.family, {
        weight = local_config.font.weight or "Regular",
        stretch = local_config.font.stretch or "Normal",
        style = local_config.font.style or "Normal",
    })
    if local_config.font.size then
        config.font_size = local_config.font.size
    end
end
config.adjust_window_size_when_changing_font_size = true

-- Colors
config.color_scheme = "Tokyo Night (Gogh)"
config.colors = {
    split = "#2a2b3d",
    cursor_bg = "#a9b1d6",
    cursor_border = "#a9b1d6",
    tab_bar = {
        background = "#16161e",
        active_tab = { bg_color = "#1a1b26", fg_color = "#a9b1d6", intensity = "Normal" },
        inactive_tab = { bg_color = "#16161e", fg_color = "#565f89" },
        inactive_tab_hover = { bg_color = "#1a1b26", fg_color = "#787c99" },
        new_tab = { bg_color = "#16161e", fg_color = "#565f89" },
        new_tab_hover = { bg_color = "#1a1b26", fg_color = "#787c99" },
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
config.max_fps = 30
config.animation_fps = 30

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
-- Find default workspace from environments or workspaces
local function find_default_workspace()
    if local_config.default_workspace then
        return local_config.default_workspace
    end
    -- Check environments for is_default
    for _, env in ipairs(local_config.environments or {}) do
        if env.is_default then
            return env.name
        end
    end
    -- Fallback to first environment or workspace
    if local_config.environments and #local_config.environments > 0 then
        return local_config.environments[1].name
    elseif local_config.workspaces and #local_config.workspaces > 0 then
        return local_config.workspaces[1].name
    end
    return nil
end

local default_ws = find_default_workspace()
if default_ws then
    config.default_workspace = default_ws
end

wezterm.on("update-status", function(window, pane)
    local domain = pane:get_domain_name()
    local workspace = window:active_workspace()

    local domain_label
    if domain == "local" then
        if wezterm.target_triple:match("windows") then
            domain_label = "Win"
        elseif wezterm.target_triple:match("darwin") then
            domain_label = "Mac"
        else
            domain_label = "Local"
        end
    elseif domain:match("^WSL:") then
        domain_label = "WSL"
    else
        local is_local_ssh = false
        for _, ssh in ipairs(local_config.ssh_domains or {}) do
            if ssh.name == domain and ssh.remote_address == "127.0.0.1" then
                is_local_ssh = true
                break
            end
        end
        if is_local_ssh then
            if wezterm.target_triple:match("windows") then
                domain_label = "WSL"
            else
                domain_label = "Local"
            end
        else
            domain_label = "SSH"
        end
    end

    window:set_left_status(wezterm.format({
        { Foreground = { Color = "#7aa2f7" } },
        { Text = string.format("  %s ", workspace) },
        { Foreground = { Color = "#565f89" } },
        { Text = string.format("[%s] ", domain_label) },
    }))
end)

-- =========================================================
-- Protocols
-- =========================================================
config.enable_kitty_keyboard = true
config.enable_kitty_graphics = true
config.enable_wayland = false

-- =========================================================
-- Key Bindings
-- =========================================================

-- Leader Key
config.leader = {
    key = "\\",
    mods = "CTRL",
    timeout_milliseconds = 1000,
}

-- Keys
config.keys = {
    -- Pane
    { key = "-",          mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "\\",         mods = "LEADER",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d",          mods = "LEADER|CTRL",  action = act.CloseCurrentPane({ confirm = true }) },
    { key = "h",          mods = "LEADER",       action = act.ActivatePaneDirection("Left") },
    { key = "l",          mods = "LEADER",       action = act.ActivatePaneDirection("Right") },
    { key = "k",          mods = "LEADER",       action = act.ActivatePaneDirection("Up") },
    { key = "j",          mods = "LEADER",       action = act.ActivatePaneDirection("Down") },
    { key = "z",          mods = "LEADER",       action = act.TogglePaneZoomState },
    { key = "s",          mods = "LEADER",       action = act.PaneSelect({ mode = "SwapWithActive" }) },

    { key = "h",          mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "l",          mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "k",          mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
    { key = "j",          mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },

    -- Tab
    { key = "t",          mods = "LEADER",       action = act.ShowTabNavigator },
    { key = "t",          mods = "LEADER|CTRL",  action = act.SpawnTab("CurrentPaneDomain") },
    { key = "t",          mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
    { key = "n",          mods = "LEADER",       action = act.ActivateTabRelative(1) },
    { key = "n",          mods = "LEADER|SHIFT", action = act.ActivateTabRelative(-1) },

    -- Workspace
    { key = "w",          mods = "LEADER",       action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },
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
    { key = "[",     mods = "LEADER",     action = act.SwitchWorkspaceRelative(-1) },
    { key = "]",     mods = "LEADER",     action = act.SwitchWorkspaceRelative(1) },

    -- Utility
    { key = "Space", mods = "LEADER",     action = act.ShowLauncher },
    { key = "d",     mods = "LEADER",     action = act.ShowLauncherArgs({ flags = "DOMAINS" }) },
    { key = "v",     mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    { key = "c",     mods = "LEADER",     action = act.ActivateCopyMode },
    { key = "f",     mods = "LEADER",     action = act.QuickSelect },
    { key = "r",     mods = "LEADER",     action = act.ReloadConfiguration },
}

-- Copy Mode
config.key_tables = {
    copy_mode = {
        { key = "Escape", action = act.CopyMode("Close") },
        { key = "q",      action = act.CopyMode("Close") },
        { key = "y",      action = act.Multiple({ act.CopyTo("Clipboard"), act.CopyMode("Close") }) },
        { key = "v",      action = act.CopyMode({ SetSelectionMode = "Cell" }) },
        { key = "V",      action = act.CopyMode({ SetSelectionMode = "Line" }) },
        { key = "/",      action = act.Search({ CaseInSensitiveString = "" }) },
        { key = "h",      action = act.CopyMode("MoveLeft") },
        { key = "l",      action = act.CopyMode("MoveRight") },
        { key = "k",      action = act.CopyMode("MoveUp") },
        { key = "j",      action = act.CopyMode("MoveDown") },
        { key = "w",      action = act.CopyMode("MoveForwardWord") },
        { key = "b",      action = act.CopyMode("MoveBackwardWord") },
        { key = "0",      action = act.CopyMode("MoveToStartOfLine") },
        { key = "$",      action = act.CopyMode("MoveToEndOfLineContent") },
        { key = "g",      action = act.CopyMode("MoveToScrollbackTop") },
        { key = "G",      action = act.CopyMode("MoveToScrollbackBottom") },
    },
}

-- =========================================================
-- Quick Select Patterns
-- =========================================================
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

-- =========================================================
-- Hyperlink Rules
-- =========================================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- =========================================================
-- Apply Local Configuration
-- =========================================================
config.ssh_domains = local_config.ssh_domains

-- Process environments: generate launch_menu and workspace keybindings
local generated_launch_menu = {}
local generated_workspaces = {}
local default_env = nil

for _, env in ipairs(local_config.environments or {}) do
    -- Add to launch_menu
    table.insert(generated_launch_menu, {
        label = env.label or env.name,
        args = env.args,
        domain = { DomainName = env.domain },
    })

    -- If key is specified, add to workspaces
    if env.key then
        table.insert(generated_workspaces, {
            key = env.key,
            name = env.name,
            domain = env.domain,
            args = env.args,
        })
    end

    -- Track default environment
    if env.is_default then
        default_env = env
    end
end

-- Use generated or fallback to legacy config
local launch_menu = #generated_launch_menu > 0 and generated_launch_menu or local_config.launch_menu or {}
local workspaces = #generated_workspaces > 0 and generated_workspaces or local_config.workspaces or {}

config.launch_menu = launch_menu

-- Set default startup from is_default environment or legacy config
if default_env then
    -- Check if domain is in ssh_domains (use connect method) or local (use args)
    local is_ssh_domain = false
    for _, ssh in ipairs(local_config.ssh_domains or {}) do
        if ssh.name == default_env.domain then
            is_ssh_domain = true
            break
        end
    end

    if is_ssh_domain then
        config.default_gui_startup_args = { "connect", default_env.domain }
    elseif default_env.args then
        config.default_gui_startup_args = default_env.args
    end
elseif local_config.default_startup then
    config.default_gui_startup_args = local_config.default_startup
end

-- Workspace Quick Switch: LEADER + 1-9
for _, ws in ipairs(workspaces) do
    local spawn_config = { domain = { DomainName = ws.domain } }
    if ws.args then
        spawn_config.args = ws.args
    end

    table.insert(config.keys, {
        key = ws.key,
        mods = "LEADER",
        action = act.SwitchToWorkspace({
            name = ws.name,
            spawn = spawn_config,
        }),
    })
end

return config

