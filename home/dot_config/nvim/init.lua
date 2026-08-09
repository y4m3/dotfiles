-- Authenticate git requests to GitHub. This raises the API rate limit
-- from 60 to 5000 requests per hour. It fetches the token from the gh
-- CLI and injects it via git's http.extraheader.
if vim.fn.executable("gh") == 1 then
  local token = vim.fn.system("gh auth token"):gsub("%s+$", "")
  if vim.v.shell_error == 0 and token ~= "" then
    vim.env.GITHUB_TOKEN = token
    local encoded = vim.base64.encode("x-access-token:" .. token)
    vim.env.GIT_CONFIG_COUNT = "1"
    vim.env.GIT_CONFIG_KEY_0 = "http.https://github.com/.extraheader"
    vim.env.GIT_CONFIG_VALUE_0 = "Authorization: basic " .. encoded
  end
end

-- Entry point: everything lives under lua/config and lua/plugins.
require("config.lazy")
