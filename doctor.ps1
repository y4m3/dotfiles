# Read-only environment health check for Windows. It changes nothing but
# one temp file of its own, which it takes away again. Never throws; always
# exits 0. Reports "ok:"/"warn:" lines and a final warning count so drift
# (an "accidentally working" setup) shows up before it bites.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$warnings = 0

try {

# Use chezmoi's YAML parser, not regexes that depend on indentation/order.
$packages = $null
try {
    $json = chezmoi execute-template --source $PSScriptRoot '{{ .packages | toJson }}'
    if ($LASTEXITCODE -ne 0) { throw 'chezmoi could not read package declarations' }
    $packages = ConvertFrom-Json -InputObject ($json -join [Environment]::NewLine)
}
catch {
    Write-Host "warn: package declarations unavailable: $_"
    $warnings++
}

# winget backs check a's per-package loop only.
$wingetAvailable = [bool](Get-Command winget -ErrorAction SilentlyContinue)
if (-not $wingetAvailable) {
    Write-Host "warn: winget command not found"
    $warnings++
}

# a. winget packages declared in packages.yaml are actually installed.
if ($packages -and $wingetAvailable) {
    $wingetIds = $packages.winget
    foreach ($id in $wingetIds) {
        $listing = @(winget list --id $id --exact --source winget --accept-source-agreements --disable-interactivity)
        $probeExit = $LASTEXITCODE
        if ($probeExit -eq 0) {
            Write-Host "ok: winget package installed: $id"
        }
        else {
            Write-Host "warn: winget package missing or lookup failed: $id (exit $probeExit)"
            $warnings++
        }
    }

    # A second winget package can ship the same binaries under a different
    # id: BurntSushi.ripgrep.GNU installs its own rg.exe beside the declared
    # .MSVC one. Both land on PATH, whichever comes first wins, and the
    # check above still says the declared package is installed. Take the
    # installed ids from `winget export` rather than `winget list`, which
    # truncates a long id in its table.
    # export is the one winget command that writes. A guid, not a pid: pids
    # are reused, and the file removed below has to be one this run made.
    $exportPath = Join-Path ([IO.Path]::GetTempPath()) "doctor-winget-$([guid]::NewGuid()).json"
    $installedIds = @()
    try {
        winget export -o $exportPath --source winget --disable-interactivity --accept-source-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'winget export failed' }
        $export = Get-Content -LiteralPath $exportPath -Raw | ConvertFrom-Json
        $installedIds = @($export.Sources.Packages.PackageIdentifier)
    }
    catch {
        # Under Set-StrictMode an export with nothing in it is an exception
        # rather than an empty result. Nothing outside this check reads
        # these ids, so a failure costs this check and stops there.
        $installedIds = @()
    }
    finally {
        Remove-Item -LiteralPath $exportPath -ErrorAction SilentlyContinue
    }

    if (-not $installedIds) {
        Write-Host "warn: could not read the installed winget packages (skipping the shadowing check)"
        $warnings++
    }
    else {
        foreach ($id in $wingetIds) {
            # Publisher.Name names the package; whatever follows is the
            # build variant, and that is what these packages differ by.
            $family = $id -replace '^([^.]+\.[^.]+).*', '$1'
            foreach ($other in $installedIds) {
                # A sibling that is declared too was asked for; only an
                # undeclared one is a surprise on PATH.
                if ($wingetIds -notcontains $other -and ($other -eq $family -or $other -like "$family.*")) {
                    Write-Host "warn: $other is installed next to the declared $id and can shadow it on PATH"
                    $warnings++
                }
            }
        }
    }
}

# b. Expected commands resolve, and not via an undeclared package manager.
$commands = 'git', 'pwsh', 'mise', 'nvim', 'rg', 'fd', 'node', 'gcc', 'tar', 'curl', 'zoxide', 'fzf', 'lazygit', 'shfmt', 'tree-sitter', `
    'lua-language-server', 'marksman', 'stylua', 'taplo', 'uv', 'ruff', 'ty', 'sqlfluff', 'prettier', 'markdownlint-cli2', 'markdown-toc', `
    'bat', 'eza', 'delta', 'gh', 'ghq', 'jq', 'less', 'shellcheck', 'yamllint'
foreach ($cmd in $commands) {
    $resolved = Get-Command $cmd -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $resolved) {
        Write-Host "warn: command not found: $cmd"
        $warnings++
    }
    elseif ($resolved.Source -match '\\scoop\\') {
        Write-Host "warn: $cmd resolved via scoop (undeclared package manager): $($resolved.Source)"
        $warnings++
    }
    else {
        Write-Host "ok: $cmd -> $($resolved.Source)"
    }
}

# Detect old machine PATH runtimes shadowing mise, without changing PATH.
$miseData = if ($env:MISE_DATA_DIR) { $env:MISE_DATA_DIR }
elseif ($env:XDG_DATA_HOME) { Join-Path $env:XDG_DATA_HOME 'mise' }
else { Join-Path $env:LOCALAPPDATA 'mise' }
foreach ($cmd in @('node', 'uv', 'tree-sitter', 'marksman', 'stylua', 'lua-language-server', 'taplo', 'shfmt', 'shellcheck', 'prettier', 'markdownlint-cli2', 'markdown-toc')) {
    $resolved = Get-Command $cmd -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($resolved -and -not $resolved.Source.Replace('/', '\').StartsWith($miseData.Replace('/', '\').TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "warn: $cmd is outside mise: $($resolved.Source). Keep it until the migration is verified."
        $warnings++
    }
}
Write-Host 'info: WezTerm is installed separately using its official installer; btop4win is not required'

# A shim may exist even when its requested version is missing. Check the
# declared versions without loading project config/hooks or installing tools.
$mise = Get-Command mise -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($mise -and $packages) {
    $names = @{ 'aqua:JohnnyMorganz/StyLua' = 'stylua'; 'aqua:mvdan/sh' = 'shfmt' }
    foreach ($entry in $packages.mise.PSObject.Properties) {
        $command = if ($names.ContainsKey($entry.Name)) { $names[$entry.Name] }
        else { ($entry.Name -split '[:/]')[-1] }
        $toolPath = & $mise.Source --no-config which $command --tool "$($entry.Name)@$($entry.Value)"
        if ($LASTEXITCODE -ne 0 -or -not $toolPath) {
            Write-Host "warn: declared mise tool unavailable: $($entry.Name)@$($entry.Value)"
            $warnings++
        }
    }
}

# PSGallery modules declared in packages.yaml are actually installed.
if ($packages) {
    $pwsh = Get-Command pwsh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    foreach ($mod in $packages.psgallery) {
        # Bootstrap may run in 5.1, but PSFzf is installed for PowerShell 7.
        $moduleFound = $false
        if ($pwsh) {
            & $pwsh.Source -NoProfile -Command "if (Get-Module -ListAvailable '$mod') { exit 0 } else { exit 1 }"
            $moduleFound = $LASTEXITCODE -eq 0
        }
        if ($moduleFound) {
            Write-Host "ok: PSGallery module installed: $mod"
        }
        else {
            Write-Host "warn: PSGallery module missing: $mod"
            $warnings++
        }
    }
}

# c. XDG base dirs must point nvim (and friends) at the deployed config.
$xdgVars = @{
    XDG_CONFIG_HOME = '.config'
    XDG_DATA_HOME   = '.local\share'
    XDG_STATE_HOME  = '.local\state'
    XDG_CACHE_HOME  = '.cache'
}
foreach ($name in $xdgVars.Keys) {
    $expected = Join-Path $env:USERPROFILE $xdgVars[$name]
    $value = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($value -eq $expected) {
        Write-Host "ok: $name=$value"
    }
    else {
        Write-Host "warn: $name is '$value', expected '$expected'"
        $warnings++
    }
}

# d. UDEV font (wezterm local.lua falls back to a system font if missing).
$fontDirs = @(
    (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'),
    (Join-Path $env:WINDIR 'Fonts')
)
$udevFont = $fontDirs | Where-Object { Test-Path $_ } |
    ForEach-Object { Get-ChildItem $_ -Filter '*UDEV*' -ErrorAction SilentlyContinue } |
    Select-Object -First 1
if ($udevFont) {
    Write-Host "ok: UDEV font found: $($udevFont.FullName)"
}
else {
    Write-Host "warn: no UDEV font found (wezterm local.lua falls back to a system font)"
    $warnings++
}

# e. User PATH: duplicate entries and entries pointing at nothing. Read the
# raw registry value (unexpanded): the Environment API expands %VAR%
# entries, which would hide the real, unexpanded duplicates/typos.
$envKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
if (-not $envKey) {
    Write-Host "warn: could not open registry key: HKCU\Environment"
    $warnings++
}
else {
    $userPath = [string]$envKey.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    $envKey.Close()

    $seen = @{}
    foreach ($entry in ($userPath -split ';' | Where-Object { $_ })) {
        $norm = $entry.ToLowerInvariant().TrimEnd('\')
        if ($seen.ContainsKey($norm)) {
            Write-Host "warn: duplicate PATH entry: $entry"
            $warnings++
        }
        else {
            $seen[$norm] = $true
        }
        $expanded = [Environment]::ExpandEnvironmentVariables($entry)
        if (-not (Test-Path -LiteralPath $expanded)) {
            Write-Host "warn: PATH entry does not exist: $entry"
            $warnings++
        }
    }
}

# Windows retains the old cleanup candidates. Presence does not mean unused
# or authorize removal; this is an inventory for a later manual decision.
$removalManifest = Join-Path $PSScriptRoot 'home/.chezmoiremove'
if (Test-Path -LiteralPath $removalManifest) {
    foreach ($line in Get-Content -LiteralPath $removalManifest) {
        $relative = $line.Trim()
        if (-not $relative -or $relative.StartsWith('#') -or $relative.StartsWith('{{')) { continue }
        $candidate = Join-Path $env:USERPROFILE $relative
        if (Test-Path -LiteralPath $candidate) {
            Write-Host "info: legacy cleanup candidate retained; review before removing: $candidate"
        }
    }
}

}
catch {
    Write-Host "warn: doctor check failed: $_"
    $warnings++
}

Write-Host "`n$warnings warning(s)"
exit 0
