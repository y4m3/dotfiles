-- =========================================================
-- Local Configuration Template
-- =========================================================
--
-- ssh_domains: List of SSH connections
--   {
--     name = "wsl-dev",            -- Domain name (used in workspace)
--     remote_address = "127.0.0.1", -- Host address (IP or hostname)
--     username = "dev",             -- SSH username
--     default_prog = { "/bin/bash", "-l" }, -- Optional: default shell
--   }
--
-- default_startup: Auto-connect on launch
--   ■ Pattern 1: Connect via SSH domain (connect method)
--     default_startup = { "connect", "wsl-dev" }
--     └─ Specify domain name defined in ssh_domains
--     └─ Uses WezTerm's SSH connection feature (more stable)
--
--   ■ Pattern 2: Execute ssh command directly (ssh method)
--     default_startup = { "ssh", "ssh_config_hostname" }
--     └─ Specify Host name defined in ~/.ssh/config
--     └─ Uses local ssh command directly
--
--   ■ Pattern 3: No auto-connect on startup
--     default_startup = nil
--     └─ Start locally, switch workspace manually
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
-- font: Font configuration (optional)
--   {
--     family = "UDEV Gothic 35NFLG",  -- Font family name
--     size = 12,                       -- Font size
--     weight = "Regular",              -- Font weight
--     stretch = "Normal",              -- Font stretch
--     style = "Normal",                -- Font style
--   }
--
-- =========================================================

-- =========================================================
-- Example Configurations
-- =========================================================

-- ■ Example 1: WSL connection via SSH domain (connect method)
-- return {
--     ssh_domains = {
--         {
--             name = "wsl-dev",              -- Domain name (environment name)
--             remote_address = "127.0.0.1",  -- WSL connects to localhost
--             username = "dev",               -- Username in WSL
--             default_prog = { "/bin/bash", "-l" },
--         },
--     },
--     default_startup = { "connect", "wsl-dev" },  -- Connect to domain on startup
--     launch_menu = {
--         {
--             label = "PowerShell 7",
--             args = { "pwsh.exe", "-NoLogo" },
--             domain = { DomainName = "local" },
--         },
--     },
--     workspaces = {
--         {
--             key = "1",
--             name = "wsl",
--             domain = "wsl-dev",  -- Must match ssh_domains.name
--         },
--         {
--             key = "2",
--             name = "posh",
--             domain = "local",
--             args = { "pwsh.exe", "-NoLogo" },
--         },
--     },
--     font = {
--         family = "UDEV Gothic 35NFLG",
--         size = 12,
--     },
-- }

-- ■ Example 2: Direct ssh command execution (ssh method)
-- return {
--     ssh_domains = {},  -- Can be empty if not using connect method
--     default_startup = { "ssh", "dev" },  -- Host name in ~/.ssh/config
--     launch_menu = {
--         {
--             label = "PowerShell 7",
--             args = { "pwsh.exe", "-NoLogo" },
--             domain = { DomainName = "local" },
--         },
--     },
--     workspaces = {
--         {
--             key = "1",
--             name = "dev",
--             domain = "local",
--             args = { "ssh", "dev" },  -- Host name in SSH config
--         },
--         {
--             key = "2",
--             name = "posh",
--             domain = "local",
--             args = { "pwsh.exe", "-NoLogo" },
--         },
--     },
-- }

-- ■ Example 3: No auto-connect (manual workspace switching)
-- return {
--     ssh_domains = {
--         {
--             name = "wsl-dev",
--             remote_address = "127.0.0.1",
--             username = "dev",
--         },
--     },
--     default_startup = nil,  -- No auto-connect
--     launch_menu = {
--         {
--             label = "PowerShell 7",
--             args = { "pwsh.exe", "-NoLogo" },
--             domain = { DomainName = "local" },
--         },
--     },
--     workspaces = {
--         {
--             key = "1",
--             name = "wsl",
--             domain = "wsl-dev",
--         },
--         {
--             key = "2",
--             name = "posh",
--             domain = "local",
--             args = { "pwsh.exe", "-NoLogo" },
--         },
--     },
-- }

-- =========================================================

return {
    ssh_domains = {
        -- {
        --     name = "your-domain-name",       -- Unique domain identifier
        --     remote_address = "127.0.0.1",    -- IP or hostname
        --     username = "your-username",       -- SSH username
        --     default_prog = { "/bin/bash", "-l" }, -- Optional: default shell
        -- },
        -- {
        --     name = "remote-server",
        --     remote_address = "192.168.1.100",
        --     username = "admin",
        -- },
    },

    default_startup = nil,
    -- Uncomment one of the following:
    -- default_startup = { "connect", "your-domain-name" },  -- connect method
    -- default_startup = { "ssh", "your-hostname" },         -- ssh method
    -- default_startup = "your-workspace-name",              -- workspace name

    launch_menu = {
        {
            label = "PowerShell 7",
            args = { "pwsh.exe", "-NoLogo" },
            domain = { DomainName = "local" },
        },
        -- {
        --     label = "Command Prompt",
        --     args = { "cmd.exe" },
        --     domain = { DomainName = "local" },
        -- },
    },

    workspaces = {
        {
            key = "1",
            name = "default",
            domain = "local",
            args = { "pwsh.exe", "-NoLogo" },
        },
        -- {
        --     key = "2",
        --     name = "remote",
        --     domain = "your-domain-name",  -- Must match ssh_domains.name
        -- },
        -- {
        --     key = "3",
        --     name = "ssh-example",
        --     domain = "local",
        --     args = { "ssh", "your-hostname" },
        -- },
    },

    -- Font configuration (optional)
    -- font = {
    --     family = "UDEV Gothic 35NFLG",
    --     size = 12,
    --     weight = "Regular",
    --     stretch = "Normal",
    --     style = "Normal",
    -- },
}
