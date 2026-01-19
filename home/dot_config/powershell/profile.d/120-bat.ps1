# 120-bat.ps1 - Tool configuration: bat
# Category: 1xx (Tool configuration)
# See: https://github.com/sharkdp/bat

# Environment variables
# Tokyo Night themes: tokyonight_day, tokyonight_moon, tokyonight_night, tokyonight_storm
if (-not $env:BAT_THEME) { $env:BAT_THEME = "tokyonight_storm" }
if (-not $env:BAT_PAGER) { $env:BAT_PAGER = "less -FRX" }

# Smart cat function: use bat for interactive viewing
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function global:cat {
        if ($args.Count -eq 0) {
            # No arguments: read from stdin
            $input | bat --paging=auto
        } else {
            bat --paging=auto @args
        }
    }
}
