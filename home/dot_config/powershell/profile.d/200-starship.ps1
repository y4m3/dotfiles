# 200-starship.ps1 - Starship prompt
# Category: 2xx (Prompt)
# See: https://starship.rs/

# Starship prompt initialization (cached)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-CachedInit -ToolName 'starship' -InitCommand @('starship', 'init', 'powershell', '--print-full-init')
}
