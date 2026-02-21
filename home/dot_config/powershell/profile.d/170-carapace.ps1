# 170-carapace.ps1 - Shell completion: carapace
# Category: 1xx (Tool configuration)
# See: https://github.com/carapace-sh/carapace

# carapace - Multi-shell completion framework (cached)
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    Register-DeferredInit -Name 'carapace' -ScriptBlock {
        Invoke-CachedInit -ToolName 'carapace' -InitCommand @('carapace', '_carapace') -ScoopAppName 'carapace-bin'
    }
}
