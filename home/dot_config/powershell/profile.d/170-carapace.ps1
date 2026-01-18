# 170-carapace.ps1 - Shell completion: carapace
# Category: 1xx (Tool configuration)
# See: https://github.com/carapace-sh/carapace

# carapace - Multi-shell completion framework
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    # Initialize carapace for PowerShell
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    carapace _carapace | Out-String | Invoke-Expression
}
