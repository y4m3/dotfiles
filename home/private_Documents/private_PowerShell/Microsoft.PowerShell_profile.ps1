# PowerShell 7 profile — deliberately small.

# UTF-8 everywhere (Japanese-safe pipes, redirects, and interactive input)
[Console]::InputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8

# PSReadLine: prefix history search + inline prediction. Non-interactive
# hosts reject these prediction settings, so guard on ConsoleHost.
if ($Host.Name -eq 'ConsoleHost') {
    try {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    }
    catch {}
}

# zoxide: skip on a machine without it, so the profile still loads.
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd j | Out-String) })
}
