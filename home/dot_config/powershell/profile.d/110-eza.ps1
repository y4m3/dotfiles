# 110-eza.ps1 - Tool configuration: eza
# Category: 1xx (Tool configuration)
# See: https://github.com/eza-community/eza

# Remove built-in aliases that conflict with our functions
# PowerShell's alias takes precedence over functions
Remove-Item alias:ls -Force -ErrorAction SilentlyContinue

if (Get-Command eza -ErrorAction SilentlyContinue) {
    # eza aliases
    function global:ls { eza --color=auto --group-directories-first --icons @args }
    function global:ll { eza -alF --git --icons @args }
    function global:la { eza -a --icons @args }
    function global:tree { eza --tree --color=auto --group-directories-first --icons @args }
} else {
    # Fallback to Get-ChildItem with format
    function global:ls { Get-ChildItem @args }
    function global:ll { Get-ChildItem -Force @args | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
    function global:la { Get-ChildItem -Force @args }
}
