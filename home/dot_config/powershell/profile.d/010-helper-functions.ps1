# 010-helper-functions.ps1 - Helper functions for PowerShell profile
# Category: 0xx (Foundation)
# Provides common helper functions used by other profile scripts

# Set alias only if not already defined
function Set-AliasIfNotSet {
    param(
        [string]$Name,
        [string]$Value
    )
    if (-not (Get-Alias -Name $Name -ErrorAction SilentlyContinue)) {
        Set-Alias -Name $Name -Value $Value -Scope Global
    }
}

# Set function alias (for commands with arguments)
function Set-FunctionAliasIfNotSet {
    param(
        [string]$Name,
        [scriptblock]$Command
    )
    if (-not (Get-Command -Name $Name -CommandType Function -ErrorAction SilentlyContinue)) {
        Set-Item -Path "function:global:$Name" -Value $Command
    }
}
