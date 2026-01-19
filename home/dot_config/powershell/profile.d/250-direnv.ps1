# 250-direnv.ps1 - direnv integration (after starship)
# Category: 2xx (Prompt/shell integration)
# See: https://direnv.net/

# direnv shell integration (loads .envrc per directory)
if (Get-Command direnv -ErrorAction SilentlyContinue) {
    # Hook into prompt to trigger direnv
    $script:DirenvLastDir = $null

    function global:Invoke-Direnv {
        $currentDir = Get-Location
        if ($currentDir.Path -ne $script:DirenvLastDir) {
            $script:DirenvLastDir = $currentDir.Path
            $direnvExport = direnv export pwsh 2>$null
            if ($direnvExport) {
                Invoke-Expression $direnvExport
            }
        }
    }

    # Add to prompt function
    $script:OriginalPrompt = $function:prompt
    function global:prompt {
        Invoke-Direnv
        & $script:OriginalPrompt
    }
}
