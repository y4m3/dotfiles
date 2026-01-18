# 100-editor.ps1 - Editor configuration
# Category: 1xx (Tools)
# Sets EDITOR/VISUAL with nvim preference, vim fallback

# Detect preferred editor
$script:EditorCmd = $null
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $script:EditorCmd = "nvim"
} elseif (Get-Command vim -ErrorAction SilentlyContinue) {
    $script:EditorCmd = "vim"
}

if ($script:EditorCmd) {
    # Set environment variables
    $env:EDITOR = $script:EditorCmd
    $env:VISUAL = $script:EditorCmd
    $env:GIT_EDITOR = $script:EditorCmd

    # Convenience functions
    function global:v { & $script:EditorCmd @args }
    function global:vi { & $script:EditorCmd @args }

    if ($script:EditorCmd -eq "nvim") {
        function global:vim { & nvim @args }
    }
}
