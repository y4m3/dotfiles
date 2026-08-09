# Bootstrap for Windows: install chezmoi if missing, then init+apply.
# Configs (PowerShell profile, WezTerm, nvim) plus winget apps from .chezmoidata/packages.yaml.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$binDir = Join-Path $HOME '.local\bin'
$repo = 'y4m3'

if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing chezmoi to $binDir"
    if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }
    & ([scriptblock]::Create((Invoke-RestMethod 'https://get.chezmoi.io/ps1'))) -BinDir $binDir
    $env:Path = "$binDir;$env:Path"
    # Persist for future shells, not just this bootstrap session. Read and
    # write the raw registry value. The Environment API expands %VAR%
    # entries. If you write the expanded entries back, they become
    # permanent, literal values instead of variables.
    $envKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
    try {
        $userPath = [string]$envKey.GetValue('Path', '',
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        if (($userPath -split ';') -notcontains $binDir) {
            $newPath = if ($userPath) { "$binDir;$userPath" } else { $binDir }
            $envKey.SetValue('Path', $newPath,
                [Microsoft.Win32.RegistryValueKind]::ExpandString)
        }
    }
    finally {
        $envKey.Close()
    }
}

# Run doctor.ps1 as a best-effort health check. It must never fail the
# install: catch errors and report them, do not rethrow.
function Invoke-Doctor {
    param([string]$CandidateDir)

    $doctorDir = $CandidateDir
    if (-not $doctorDir) {
        # $PSScriptRoot is empty here too (irm | iex path). Ask chezmoi for
        # the source dir instead: it prints the `home` subdirectory (see
        # .chezmoiroot), so its parent is the repo root.
        try {
            $sourcePath = chezmoi source-path 2>$null
        }
        catch {
            $sourcePath = $null
        }
        if (-not $sourcePath) {
            return
        }
        $doctorDir = Split-Path $sourcePath -Parent
    }

    $doctorPath = Join-Path $doctorDir 'doctor.ps1'
    if (-not (Test-Path $doctorPath)) {
        Write-Host "==> doctor.ps1 not found, skipping health check"
        return
    }

    try {
        & $doctorPath
    }
    catch {
        Write-Host "==> doctor.ps1 failed to run: $_"
    }
}

# $PSScriptRoot is empty under `irm ... | iex`. There, $MyInvocation.MyCommand
# has no Path property, and StrictMode turns that access into a terminating
# error. The script then initializes from GitHub instead.
$scriptDir = $PSScriptRoot
if ($scriptDir -and (Test-Path (Join-Path $scriptDir '.chezmoiroot'))) {
    chezmoi init --apply --source=$scriptDir
    # Capture before Invoke-Doctor: doctor.ps1 ends with its own `exit 0`,
    # which overwrites $LASTEXITCODE.
    $initExitCode = $LASTEXITCODE
    Invoke-Doctor -CandidateDir $scriptDir
    exit $initExitCode
}

$branch = if ($env:DOTFILES_BRANCH) { $env:DOTFILES_BRANCH } else { 'main' }
chezmoi init --apply --branch $branch $repo
# ErrorActionPreference only catches terminating errors from cmdlets. It
# does not catch a native command's non-zero exit code. PS 5.1 keeps
# running regardless.
if ($LASTEXITCODE -ne 0) {
    throw "chezmoi init failed with exit code $LASTEXITCODE"
}

Invoke-Doctor
