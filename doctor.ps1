# Read-only environment health check for Windows. It changes nothing but
# one temp file of its own, which it takes away again. Never throws; always
# exits 0. Reports "ok:"/"warn:" lines and a final warning count so drift
# (an "accidentally working" setup) shows up before it bites.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$warnings = 0

try {

# packages.yaml backs check a and the PSGallery check below. Skip both
# when it is missing.
$yamlPath = Join-Path $PSScriptRoot 'home\.chezmoidata\packages.yaml'
$yamlExists = Test-Path $yamlPath
if ($yamlExists) {
    $yaml = Get-Content $yamlPath -Raw
}
else {
    Write-Host "warn: packages.yaml not found: $yamlPath"
    $warnings++
}

# winget backs check a's per-package loop only.
$wingetAvailable = [bool](Get-Command winget -ErrorAction SilentlyContinue)
if (-not $wingetAvailable) {
    Write-Host "warn: winget command not found"
    $warnings++
}

# a. winget packages declared in packages.yaml are actually installed.
if ($yamlExists -and $wingetAvailable) {
    $block = [regex]::Match($yaml, '(?ms)^  winget:\r?\n(.*?)(?=^  \S)').Groups[1].Value
    $wingetIds = [regex]::Matches($block, '(?m)^\s*-\s+(\S+)') | ForEach-Object { $_.Groups[1].Value }
    foreach ($id in $wingetIds) {
        $found = winget list --id $id --exact --disable-interactivity | Select-String -SimpleMatch $id
        if ($found) {
            Write-Host "ok: winget package installed: $id"
        }
        else {
            Write-Host "warn: winget package missing: $id"
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
        winget export -o $exportPath --disable-interactivity --accept-source-agreements 2>&1 | Out-Null
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
$commands = 'git', 'pwsh', 'wezterm', 'nvim', 'rg', 'fd', 'node', 'gcc', 'zoxide', 'fzf', 'lazygit', 'shfmt', 'tree-sitter', `
    'lua-language-server', 'marksman', 'stylua', 'taplo', 'uv', 'ruff', 'ty', 'sqlfluff', 'prettier', 'markdownlint-cli2', 'markdown-toc', `
    'bat', 'eza', 'delta', 'gh', 'ghq', 'jq', 'btop4win', 'less', 'shellcheck'
foreach ($cmd in $commands) {
    $resolved = Get-Command $cmd -ErrorAction SilentlyContinue
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

# uv's tool-shim dir (~\.local\bin) is where `uv tool install` puts entry
# points, not where uv itself lives. uv must come from winget.
$uvCmd = Get-Command uv -ErrorAction SilentlyContinue
if ($uvCmd -and $uvCmd.Source -match '\\\.local\\bin\\') {
    Write-Host "warn: uv resolved from its own tool-shim dir, not winget: $($uvCmd.Source)"
    $warnings++
}

# PSGallery modules declared in packages.yaml are actually installed.
if ($yamlExists) {
    $psgalleryBlock = [regex]::Match($yaml, '(?ms)^  psgallery:\r?\n(.*?)(?=^  \S)').Groups[1].Value
    $psgalleryModules = [regex]::Matches($psgalleryBlock, '(?m)^\s*-\s+(\S+)') | ForEach-Object { $_.Groups[1].Value }
    foreach ($mod in $psgalleryModules) {
        if (Get-Module -ListAvailable $mod) {
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
        if (-not (Test-Path $expanded)) {
            Write-Host "warn: PATH entry does not exist: $entry"
            $warnings++
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
