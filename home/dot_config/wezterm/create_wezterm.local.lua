-- =========================================================
-- Local Configuration Template
-- =========================================================
--
-- ssh_domains: List of SSH connections
--   {
--     name = "wsl-dev",            -- Domain name (used in environments)
--     remote_address = "127.0.0.1", -- Host address (IP or hostname)
--     username = "dev",             -- SSH username
--     default_prog = { "/bin/bash", "-l" }, -- Optional: default shell
--   }
--
-- environments: Unified config for workspaces and launch_menu
--   {
--     key = "1",                  -- LEADER + key for quick switch (optional)
--     name = "workspace_name",    -- Workspace name
--     label = "Display Name",     -- Launch menu label (defaults to name)
--     domain = "domain_name",     -- Domain to spawn in
--     args = { "cmd", "arg" },    -- Optional: command to run
--     is_default = true,          -- Set as default startup (optional)
--   }
--
--   - With "key": added to both workspaces (LEADER + N) and launch_menu
--   - Without "key": added to launch_menu only
--   - With "is_default": sets default startup and default_workspace
--
-- font: Font configuration (optional)
--   {
--     family = "UDEV Gothic 35NFLG",  -- Font family name
--     size = 12,                       -- Font size
--   }
--
-- =========================================================

-- =========================================================
-- Example Configurations
-- =========================================================

-- Example 1: WSL + PowerShell (Windows host)
-- return {
--     ssh_domains = {
--         {
--             name = "wsl-dev",
--             remote_address = "127.0.0.1",
--             username = "dev",
--             default_prog = { "/bin/bash", "-l" },
--         },
--     },
--     environments = {
--         {
--             key = "1",
--             name = "wsl",
--             label = "WSL Development",
--             domain = "wsl-dev",
--             is_default = true,
--         },
--         {
--             key = "2",
--             name = "posh",
--             label = "PowerShell 7",
--             domain = "local",
--             args = { "pwsh.exe", "-NoLogo" },
--         },
--         {
--             -- No key = launch_menu only
--             name = "cmd",
--             label = "Command Prompt",
--             domain = "local",
--             args = { "cmd.exe" },
--         },
--     },
--     font = {
--         family = "UDEV Gothic 35NFLG",
--         size = 12,
--     },
-- }

-- Example 2: SSH to remote server
-- return {
--     ssh_domains = {
--         {
--             name = "prod-server",
--             remote_address = "192.168.1.100",
--             username = "admin",
--         },
--     },
--     environments = {
--         {
--             key = "1",
--             name = "local",
--             label = "Local Shell",
--             domain = "local",
--             is_default = true,
--         },
--         {
--             key = "2",
--             name = "prod",
--             label = "Production Server",
--             domain = "prod-server",
--         },
--     },
-- }

-- =========================================================

return {
    ssh_domains = {
        -- {
        --     name = "your-domain",
        --     remote_address = "127.0.0.1",
        --     username = "your-username",
        --     default_prog = { "/bin/bash", "-l" },
        -- },
    },

    environments = {
        {
            key = "1",
            name = "default",
            label = "PowerShell 7",
            domain = "local",
            args = { "pwsh.exe", "-NoLogo" },
            is_default = true,
        },
        -- {
        --     key = "2",
        --     name = "wsl",
        --     label = "WSL Development",
        --     domain = "your-domain",  -- Must match ssh_domains.name
        -- },
    },

    -- font = {
    --     family = "UDEV Gothic 35NFLG",
    --     size = 12,
    -- },
}
