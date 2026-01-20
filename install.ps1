#Requires -Version 5.1
# install.ps1 — Bootstrap script for chezmoi dotfiles on Windows
# Usage:
#   Local:  .\install.ps1
#   Remote: iwr -useb 'https://raw.githubusercontent.com/y4m3/dotfiles/main/install.ps1' | iex
#   Branch: $env:DOTFILES_BRANCH='feature/xxx'; iwr -useb .../install.ps1 | iex

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Log {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

# Setup ~/.local/bin
$binDir = Join-Path $env:USERPROFILE ".local\bin"
$chezmoiExe = Join-Path $binDir "chezmoi.exe"

if (-not (Test-Path $binDir)) {
    Write-Log "Creating $binDir..."
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
}

# Install chezmoi if not available
$chezmoi = $null
if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    $chezmoi = "chezmoi"
    Write-Log "chezmoi already installed: $(Get-Command chezmoi | Select-Object -ExpandProperty Source)"
} elseif (Test-Path $chezmoiExe) {
    $chezmoi = $chezmoiExe
    Write-Log "chezmoi already installed at $chezmoiExe"
} else {
    Write-Log "Installing chezmoi to $binDir..."

    # Download and run chezmoi installer
    $installScript = Invoke-RestMethod -Uri 'https://get.chezmoi.io/ps1'
    # Run in child scope to avoid variable conflicts with our $binDir
    & ([scriptblock]::Create($installScript))
    # Move chezmoi to ~/.local/bin if installed elsewhere
    $defaultPath = Join-Path $env:USERPROFILE "bin\chezmoi.exe"
    if ((Test-Path $defaultPath) -and -not (Test-Path $chezmoiExe)) {
        Move-Item $defaultPath $chezmoiExe -Force
        # Clean up empty bin directory if it exists
        $defaultBinDir = Join-Path $env:USERPROFILE "bin"
        if ((Test-Path $defaultBinDir) -and @(Get-ChildItem $defaultBinDir).Count -eq 0) {
            Remove-Item $defaultBinDir -Force
        }
    }

    if (Test-Path $chezmoiExe) {
        $chezmoi = $chezmoiExe
        Write-Log "chezmoi installed successfully"
    } else {
        Write-Host "Failed to install chezmoi" -ForegroundColor Red
        exit 1
    }
}

# Determine script directory (for local execution)
$scriptDir = $PSScriptRoot

# Check if running from local source (has .chezmoiroot or .chezmoi.toml.tmpl)
$isLocalSource = $false
if ($scriptDir) {
    $chezmoiRoot = Join-Path $scriptDir ".chezmoiroot"
    $chezmoiToml = Join-Path $scriptDir ".chezmoi.toml.tmpl"
    $homeChezmoiToml = Join-Path $scriptDir "home\.chezmoi.toml.tmpl"
    if ((Test-Path $chezmoiRoot) -or (Test-Path $chezmoiToml) -or (Test-Path $homeChezmoiToml)) {
        $isLocalSource = $true
    }
}

if ($isLocalSource) {
    # Local source: init with --source
    Write-Log "Initializing from local source: $scriptDir"
    & $chezmoi init --apply "--source=$scriptDir"
} else {
    # Remote execution: clone from GitHub
    $branch = $env:DOTFILES_BRANCH
    if (-not $branch) { $branch = "main" }

    Write-Log "Initializing from GitHub (branch: $branch)..."
    if ($branch -eq "main") {
        & $chezmoi init --apply y4m3
    } else {
        & $chezmoi init --apply --branch $branch y4m3
    }
}

Write-Log "Done!"
