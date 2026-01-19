# 160-fzf.ps1 - Tool configuration: fzf
# Category: 1xx (Tool configuration)
# See: https://github.com/junegunn/fzf

if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Use fd as default command (faster and respects .fdignore)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
        $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    }

    # Basic UI options
    $env:FZF_DEFAULT_OPTS = '--height 40% --reverse --border'

    # File preview (if bat is available)
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        $env:FZF_CTRL_T_OPTS = "--preview 'bat -n --color=always {} 2>nul || type {}'"
    }

    # Directory preview (if eza is available)
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        $env:FZF_ALT_C_OPTS = "--preview 'eza --tree --color=auto {} 2>nul'"
    }

    # PSFzf module integration (if available)
    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}
