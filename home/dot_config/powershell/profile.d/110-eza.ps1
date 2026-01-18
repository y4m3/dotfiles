# 110-eza.ps1 - Tool configuration: eza
# Category: 1xx (Tool configuration)
# See: https://github.com/eza-community/eza

if (Get-Command eza -ErrorAction SilentlyContinue) {
    # eza aliases
    function global:ls { eza --color=auto --group-directories-first --icons @args }
    function global:ll { eza -alF --git --icons @args }
    function global:la { eza -a --icons @args }
    function global:tree { eza --tree --color=auto --group-directories-first --icons @args }
} else {
    # Fallback to Get-ChildItem with format
    function global:ll { Get-ChildItem -Force @args | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
    function global:la { Get-ChildItem -Force @args }
}
