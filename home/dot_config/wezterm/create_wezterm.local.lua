-- WezTerm Local Configuration
--
-- This file configures workspaces and connections for your environment.
-- See README.md in this directory for detailed documentation and examples.
--
-- Official docs:
--   • https://wezterm.org/multiplexing.html
--   • https://wezterm.org/config/lua/SshDomain.html
--   • https://wezterm.org/config/lua/config/wsl_domains.html

return {
  environments = {
       {
         -- Setting args = {} launches the OS default shell.
         -- This is a somewhat dirty hack, but useful when you want the system's default behavior.
         key = "9",
         workspace_name = "default",
         connection = "local",
         args = {},
         is_default = true,
       },
  --   {
  --     key = "1",
  --     workspace_name = "mux-server-workspace_name",
  --     connection = "connect",
  --     remote_address = "remote_address_or_ssh_config_name"
  --     username = "your_name",
  --     default_prog = { "/bin/bash", "-l" },
  --     is_default = true,
  --   },
  --   {
  --     key = "2",
  --     workspace_name = "local-workspace_name",
  --     connection = "local", -- local connection
  --     args = { "powershell.exe" },
  --   },
  --   {
  --     key = "3",
  --     workspace_name = "wsl-workspace_name",
  --     connection = "local", -- local connection (wsl)
  --     args = { "wsl.exe", "-d", "Ubuntu", "--", "/bin/bash", "-l" },
  --   },
  --   {
  --     key = "4",
  --     workspace_name = "ssh-workspace_name",
  --     connection = "ssh", -- ssh connection
  --     remote_address = "remote_address_or_ssh_config_name",
  --     username = "your_name"
  --   },
  -- },

  font = {
    family = "UDEV Gothic 35NFLG",
    size = 12,
  },
}
