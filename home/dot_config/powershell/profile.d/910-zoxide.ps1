# 910-zoxide.ps1 - Tool configuration: zoxide
# Category: 9xx (Must be last)
# See: https://github.com/ajeetdsouza/zoxide
# Note: zoxide must be initialized at the end of shell configuration

# Environment variables
$env:_ZO_RESOLVE_SYMLINKS = "1"
$env:_ZO_ECHO = "1"

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # Initialize zoxide with 'j' as the command
    Invoke-Expression (& { (zoxide init powershell --cmd j | Out-String) })

    # Wrapper for j: add/remove helpers, otherwise delegate to zoxide
    function global:j {
        param(
            [Parameter(Position = 0)]
            [string]$Command,
            [Parameter(Position = 1, ValueFromRemainingArguments)]
            [string[]]$Remaining
        )

        switch ($Command) {
            "add" {
                $path = if ($Remaining) { $Remaining[0] } else { Get-Location }
                zoxide add $path
            }
            { $_ -in "rm", "remove" } {
                if ($Remaining) {
                    zoxide remove $Remaining[0]
                }
            }
            default {
                # Delegate to zoxide's __zoxide_z function
                if ($Command) {
                    __zoxide_z $Command @Remaining
                } else {
                    __zoxide_z
                }
            }
        }
    }
}
