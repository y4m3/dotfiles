# 120-bat.ps1 - Tool configuration: bat
# Category: 1xx (Tool configuration)
# See: https://github.com/sharkdp/bat

# Environment variables
# Tokyo Night themes: tokyonight_day, tokyonight_moon, tokyonight_night, tokyonight_storm
if (-not $env:BAT_THEME) { $env:BAT_THEME = "tokyonight_storm" }
if (-not $env:BAT_PAGER) { $env:BAT_PAGER = "less -FRX" }

# Remove built-in alias that conflicts with our function
Remove-Item alias:cat -Force -ErrorAction SilentlyContinue

# Smart cat function: use bat for interactive viewing, Get-Content for pipes/redirects
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function global:cat {
        # Non-interactive stdout (pipe / redirect) -> use Get-Content
        if ([Console]::IsOutputRedirected) {
            Get-Content @args
            return
        }

        # No arguments -> read from stdin (preserve cat's default behavior)
        if ($args.Count -eq 0) {
            $input | ForEach-Object { $_ }
            return
        }

        # Interactive view with arguments -> use bat
        bat --paging=auto @args
    }
} else {
    # Fallback to Get-Content
    function global:cat { Get-Content @args }
}
