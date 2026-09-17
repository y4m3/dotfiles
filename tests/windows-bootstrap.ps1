# Read-only validation: templates are rendered, never applied. All winget
# calls in behavior tests are PowerShell functions inside a child process.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path $PSScriptRoot -Parent
$ps51 = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'

function Render([string]$Path, [string]$Os = 'windows') {
    $override = @{ chezmoi = @{ os = $Os } } | ConvertTo-Json -Compress
    $result = chezmoi execute-template --source $repo --override-data $override --file $Path
    if ($LASTEXITCODE -ne 0) { throw "render failed: $Path" }
    return $result -join "`n"
}

$scripts = @(Get-ChildItem (Join-Path $repo 'home/.chezmoiscripts') -Filter '*.ps1.tmpl')
foreach ($file in $scripts) {
    $rendered = Render $file.FullName
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseInput($rendered, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw "$($file.Name): $errors" }
    # Check with the bootstrap's actual Windows PowerShell 5.1 parser too.
    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($rendered))
    & $ps51 -NoProfile -NonInteractive -Command "`$t=`$null; `$e=`$null; [void][System.Management.Automation.Language.Parser]::ParseInput([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encoded')), [ref]`$t, [ref]`$e); if (`$e.Count) { `$e; exit 1 }"
    if ($LASTEXITCODE -ne 0) { throw "PS 5.1 parse failed: $($file.Name)" }
    if ((Render $file.FullName 'linux').Trim()) { throw "Windows script rendered on Linux: $($file.Name)" }
}

foreach ($path in @('doctor.ps1', 'update-windows.ps1', 'home/dot_config/powershell/profile.ps1')) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repo $path), [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw "parse failed: $path : $errors" }
}

$wingetScript = Render (Join-Path $repo 'home/.chezmoiscripts/run_onchange_100-windows-apps.ps1.tmpl')
foreach ($scenario in @('present', 'missing', 'lookup-failed', 'install-failed')) {
    $mock = @'
function winget {
    $sourceIndex = [array]::IndexOf($args, '--source')
    if ($sourceIndex -lt 0 -or $args[$sourceIndex + 1] -ne 'winget') { throw 'wrong source' }
    if ($args -notcontains '--accept-source-agreements') { throw 'missing source agreement' }
    if ($args[0] -eq 'list') {
        $global:LASTEXITCODE = switch ($scenario) {
            'present' { 0 }
            'lookup-failed' { -1978335231 }
            default { -1978335212 }
        }
        return
    }
    if ($args[0] -ne 'install') { throw 'unexpected command' }
    if ($scenario -eq 'present' -or $scenario -eq 'lookup-failed') { throw 'unexpected installation' }
    if ($args -notcontains '--accept-package-agreements') { throw 'missing package agreement' }
    Write-Output 'MOCK-INSTALL'
    $global:LASTEXITCODE = if ($scenario -eq 'install-failed') { 1 } else { 0 }
}
'@
    $harness = "`$scenario = '$scenario'`n$mock`n$wingetScript"
    $result = @(& $ps51 -NoProfile -NonInteractive -Command $harness)
    $code = $LASTEXITCODE
    $shouldFail = $scenario -in @('lookup-failed', 'install-failed')
    if (($code -ne 0) -ne $shouldFail) { throw "$scenario returned $code : $result" }
    if ($scenario -eq 'missing' -and $result -notcontains 'MOCK-INSTALL') { throw 'missing package was not installed' }
    if ($scenario -in @('present', 'lookup-failed') -and $result -contains 'MOCK-INSTALL') { throw 'unexpected install' }
    Write-Host "ok: winget $scenario"
}

# Exercise preview/apply scoping with a fake winget, never the real updater.
$updatePath = (Join-Path $repo 'update-windows.ps1').Replace("'", "''")
foreach ($mode in @('', '-Apply', '-Apply -IncludeEditorToolchain')) {
    $harness = @'
function winget {
    $sourceIndex = [array]::IndexOf($args, '--source')
    if ($sourceIndex -lt 0 -or $args[$sourceIndex + 1] -ne 'winget') { throw 'wrong source' }
    $id = $args[[array]::IndexOf($args, '--id') + 1]
    Write-Output "MOCK:$($args[0]):$id"
    $global:LASTEXITCODE = 0
}
'@
    # Process-only policy for this test child; no machine/user policy change.
    $result = @(& $ps51 -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$harness`n& '$updatePath' $mode")
    if ($LASTEXITCODE -ne 0) { throw "update script failed: $mode : $result" }
    $calls = @($result | Where-Object { $_ -like 'MOCK:*' })
    if (-not $calls.Count) { throw 'update script made no mock calls' }
    $verb = if ($mode) { 'upgrade' } else { 'list' }
    if ($calls | Where-Object { $_ -notlike "MOCK:${verb}:*" }) { throw 'preview attempted mutation' }
    if ($calls -match 'wez.wezterm|btop4win|OpenJS.NodeJS|astral-sh.uv') { throw 'removed package included in updates' }
    $editorCalls = @($calls | Where-Object { $_ -match 'Neovim.Neovim|BrechtSanders.WinLibs' })
    $expected = if ($mode -like '*IncludeEditorToolchain*') { 2 } else { 0 }
    if ($editorCalls.Count -ne $expected) { throw "editor toolchain opt-in failed ($mode): $calls" }
    Write-Host "ok: allowlist update mode '$mode'"
}

# Linux ignores the new Windows-only config, and its suppliers stay Nix.
$ignore = Render (Join-Path $repo 'home/.chezmoiignore') 'linux'
if ($ignore -notmatch '(?m)^\.config/mise/') { throw 'mise config leaked onto Linux' }
Write-Host 'OK: Windows templates, PowerShell syntax, Linux guards, winget retry behavior'
