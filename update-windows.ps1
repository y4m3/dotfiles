# Preview declared winget packages only. Use -Apply to install updates.
# GUI apps are never included; Neovim/compiler updates require an opt-in.
[CmdletBinding()]
param([switch]$Apply, [switch]$IncludeEditorToolchain)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$json = chezmoi execute-template --source $PSScriptRoot '{{ .packages.winget | toJson }}'
if ($LASTEXITCODE -ne 0) { throw 'Could not read packages.winget' }
# PS 5.1 emits a JSON array as one pipeline object. Do not wrap that
# pipeline in @(...), which would turn the entire allowlist into one ID.
$ids = ConvertFrom-Json -InputObject ($json -join "`n")
$manual = @('Neovim.Neovim', 'BrechtSanders.WinLibs.POSIX.UCRT')
$failed = @()
foreach ($id in $ids) {
    if (-not $IncludeEditorToolchain -and $id -in $manual) {
        Write-Host "skipped editor toolchain: $id (use -IncludeEditorToolchain)"
        continue
    }
    if ($Apply) {
        # Respect winget pins; do not force or include unknown versions.
        winget upgrade --id $id --exact --source winget --accept-source-agreements --accept-package-agreements
        # UPDATE_NOT_APPLICABLE means the installed package is up to date.
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) { $failed += $id }
    }
    else {
        winget list --id $id --exact --source winget --upgrade-available --accept-source-agreements
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335212) { $failed += $id }
    }
}
if ($failed.Count -gt 0) { throw ('winget failed for: ' + ($failed -join ', ')) }
