# Bootstrap does not inherit environment updates from earlier child scripts.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
$miseCommand = Get-Command mise -ErrorAction SilentlyContinue
if ($miseCommand) { $miseExe = $miseCommand.Source }
else {
    $miseExe = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\mise.exe'
    if (-not (Test-Path -LiteralPath $miseExe)) {
        throw 'mise not found; install jdx.mise from winget and run chezmoi apply again'
    }
}
# Explicit global config avoids a different XDG setting silently selecting
# an unrelated file. These variables affect this script and its children only.
$managedMiseConfig = Join-Path $env:USERPROFILE '.config\mise\config.toml'
if ($env:MISE_GLOBAL_CONFIG_FILE -and
    [IO.Path]::GetFullPath($env:MISE_GLOBAL_CONFIG_FILE) -ine [IO.Path]::GetFullPath($managedMiseConfig)) {
    throw "MISE_GLOBAL_CONFIG_FILE selects a different config; review manually: $env:MISE_GLOBAL_CONFIG_FILE"
}
$env:MISE_GLOBAL_CONFIG_FILE = $managedMiseConfig
if (-not (Test-Path -LiteralPath $env:MISE_GLOBAL_CONFIG_FILE)) {
    throw "mise config not deployed: $env:MISE_GLOBAL_CONFIG_FILE"
}
$userXdgData = [Environment]::GetEnvironmentVariable('XDG_DATA_HOME', 'User')
if ($userXdgData) { $env:XDG_DATA_HOME = $userXdgData }
$miseData = if ($env:MISE_DATA_DIR) { $env:MISE_DATA_DIR }
elseif ($env:XDG_DATA_HOME) { Join-Path $env:XDG_DATA_HOME 'mise' }
else { Join-Path $env:LOCALAPPDATA 'mise' }
$miseShims = Join-Path $miseData 'shims'
$env:Path = "$miseShims;$env:Path"
