-- =========================================================
-- Local Configuration Template
-- =========================================================
--
-- This file contains machine-specific settings.
-- It is loaded by .wezterm.lua and should NOT be tracked by git.
--
-- Setup:
--   1. Copy this template: cp .wezterm.local.template.lua .wezterm.local.lua
--   2. Edit .wezterm.local.lua for your environment
--   3. Add .wezterm.local.lua to .gitignore
--
-- =========================================================
-- Configuration Options
-- =========================================================
--
-- ssh_domains: List of SSH connections
--   {
--     name = "server1",           -- Domain name (used in workspace)
--     remote_address = "1.2.3.4", -- Host address (IP or hostname)
--     username = "user",          -- SSH username
--   }
--
-- default_startup: Auto-connect on launch
--   { "connect", "domain_name" }  -- Connect to SSH domain
--   nil                           -- Start locally (no auto-connect)
--
-- launch_menu: Items shown in launcher (LEADER + Space)
--   {
--     label = "Display Name",
--     args = { "command", "arg1" },
--     domain = { DomainName = "local" },  -- "local" for Windows/host
--   }
--
-- workspaces: Quick switch targets (LEADER + 1-9)
--   {
--     key = "1",                  -- Key to press (with LEADER)
--     name = "workspace_name",    -- Workspace display name
--     domain = "domain_name",     -- Domain to spawn in
--     args = { "cmd", "arg" },    -- Optional: command to run
--   }
--
-- =========================================================

return {
    ssh_domains = {
        -- {
        --     name = "dev",
        --     remote_address = "127.0.0.1",
        --     username = "dev",
        -- },
        -- {
        --     name = "prod",
        --     remote_address = "192.168.1.100",
        --     username = "admin",
        -- },
    },

    default_startup = nil,
    -- default_startup = { "connect", "domain_name" },

    launch_menu = {
        -- {
        --     label = "PowerShell 7",
        --     args = { "pwsh.exe", "-NoLogo" },
        --     domain = { DomainName = "local" },
        -- },
        -- {
        --     label = "Command Prompt",
        --     args = { "cmd.exe" },
        --     domain = { DomainName = "local" },
        -- },
    },

    workspaces = {
        -- {
        --     key = "1",
        --     name = "dev",
        --     domain = "dev",
        -- },
        -- {
        --     key = "2",
        --     name = "windows",
        --     domain = "local",
        --     args = { "pwsh.exe", "-NoLogo" },
        -- },
    },
}

