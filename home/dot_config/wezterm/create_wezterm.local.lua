-- =========================================================
-- Local Configuration Template
-- =========================================================
--
-- environments: Unified configuration for workspaces and connections
--   {
--     key = "1",                    -- LEADER + key for quick switch (optional)
--     workspace_name = "wsl",       -- Workspace name (used everywhere)
--     connection = "connect",       -- "local" | "connect" | "ssh"
--     -- For "connect" or "ssh":
--     remote_address = "127.0.0.1",
--     username = "dev",
--     default_prog = { "/bin/bash", "-l" },  -- Optional
--     -- For "local":
--     args = { "pwsh.exe", "-NoLogo" },
--     is_default = true,            -- Set as default startup (optional)
--   }
--
-- connection types:
--   "local"   - Run local command (uses args)
--   "connect" - WezTerm SSH domain (wezterm connect <workspace_name>)
--   "ssh"     - System SSH command (ssh user@host)
--
-- font: Font configuration (optional)
--   { family = "...", size = 12 }
--
-- =========================================================

-- =========================================================
-- Example: WSL + PowerShell (Windows host)
-- =========================================================
-- return {
--     environments = {
--         {
--             key = "1",
--             workspace_name = "wsl",
--             connection = "connect",
--             remote_address = "127.0.0.1",
--             username = "dev",
--             default_prog = { "/bin/bash", "-l" },
--             is_default = true,
--         },
--         {
--             key = "2",
--             workspace_name = "posh",
--             connection = "local",
--             args = { "pwsh.exe", "-NoLogo" },
--         },
--         {
--             -- No key = launch_menu only
--             workspace_name = "cmd",
--             connection = "local",
--             args = { "cmd.exe" },
--         },
--     },
--     font = {
--         family = "UDEV Gothic 35NFLG",
--         size = 12,
--     },
-- }

-- =========================================================
-- Example: SSH to remote server
-- =========================================================
-- return {
--     environments = {
--         {
--             key = "1",
--             workspace_name = "local",
--             connection = "local",
--             args = { "pwsh.exe", "-NoLogo" },
--             is_default = true,
--         },
--         {
--             key = "2",
--             workspace_name = "prod",
--             connection = "ssh",  -- Uses system ssh command
--             remote_address = "192.168.1.100",
--             username = "admin",
--         },
--     },
-- }

-- =========================================================

return {
    environments = {
        {
            key = "1",
            workspace_name = "default",
            connection = "local",
            args = { "pwsh.exe", "-NoLogo" },
            is_default = true,
        },
        -- {
        --     key = "2",
        --     workspace_name = "wsl",
        --     connection = "connect",
        --     remote_address = "127.0.0.1",
        --     username = "dev",
        -- },
    },

    -- font = {
    --     family = "UDEV Gothic 35NFLG",
    --     size = 12,
    -- },
}
