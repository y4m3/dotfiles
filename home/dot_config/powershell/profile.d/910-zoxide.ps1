# 910-zoxide.ps1 - Tool configuration: zoxide
# Category: 9xx (Must be last)
# See: https://github.com/ajeetdsouza/zoxide
# Note: zoxide must be initialized at the end of shell configuration

# Environment variables
$env:_ZO_RESOLVE_SYMLINKS = "1"
$env:_ZO_ECHO = "1"

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # Load zoxide internals and replace its alias with our custom wrapper.
    # zoxide init creates `Set-Alias j __zoxide_z` which shadows any function
    # of the same name (PowerShell resolves aliases before functions). We remove
    # the alias and define a function that adds add/remove sub-commands.
    function global:__zoxide_apply {
        Invoke-CachedInit -ToolName 'zoxide' -InitCommand @('zoxide', 'init', 'powershell', '--cmd', 'j')
        Remove-Item Alias:\j -Force -ErrorAction SilentlyContinue
        Remove-Item Alias:\ji -Force -ErrorAction SilentlyContinue
    }

    Register-DeferredInit -Name 'zoxide' -ScriptBlock {
        __zoxide_apply
    }

    # Proxy j: works before OnIdle fires, triggers lazy init on first call
    function global:j {
        param(
            [Parameter(Position = 0)]
            [string]$Command,
            [Parameter(Position = 1, ValueFromRemainingArguments)]
            [string[]]$Remaining
        )

        # Lazy init if OnIdle hasn't fired yet
        if (-not (Test-Path Function:\__zoxide_z)) {
            __zoxide_apply
            if ($global:__deferred_inits) { $global:__deferred_inits.Remove('zoxide') }
        }

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
                if ($Command) {
                    __zoxide_z $Command @Remaining
                } else {
                    __zoxide_z
                }
            }
        }
    }
}
