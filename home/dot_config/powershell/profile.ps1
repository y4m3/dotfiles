# PowerShell 7 profile. Carries the prompt ported from
# dot_bashrc.d/200-integrations.sh, so it is no longer "deliberately small".
#
# $PROFILE is NOT this file. PowerShell derives $PROFILE from the Personal
# known folder, which OneDrive "Known Folder Move" redirects into the
# OneDrive tree. chezmoi writes to the literal %USERPROFILE%\Documents, so
# on a redirected machine the two paths are different directories and this
# file would never load. run_after_150-windows-pwsh-profile.ps1 resolves
# the real $PROFILE and drops a loader there that dot-sources this file.
# It recognises an earlier body by the first line above, so keep that line
# as it is.

# UTF-8 everywhere (Japanese-safe pipes, redirects, and interactive input)
[Console]::InputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8

# PSReadLine: prefix history search + inline prediction. Non-interactive
# hosts reject these prediction settings, so guard on ConsoleHost.
if ($Host.Name -eq 'ConsoleHost') {
    try {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    }
    catch {}
}

# Editor and pager environment (mirrors dot_bashrc.d/010-env.sh).
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $env:EDITOR = 'nvim'
    $env:VISUAL = 'nvim'
}
$env:LESS = '-R -F -M -i'
# ansi follows the terminal's color scheme (Tracer), same as bash.
$env:BAT_THEME = 'ansi'

# Aliases (mirrors dot_bashrc.d/100-aliases.sh). The bash file's POSIX
# safety aliases (cp/mv/df/du) have no pwsh equivalent semantics, so they
# are not ported.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza @args }
    function ll { eza -l --git @args }
    function la { eza -la --git @args }
    function lt { eza --tree --level=2 @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    # -pp: plain style, no pager; colors still apply on a tty
    function cat { bat -pp @args }
}

if (Get-Command btop4win -ErrorAction SilentlyContinue) {
    # bash-parity name: the Linux side calls it btop
    Set-Alias btop btop4win
}

# fzf defaults (mirrors dot_bashrc.d/200-integrations.sh).
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border'
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
        $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    }
}

# PSFzf: fzf-powered PSReadLine key chords. Importing it costs ~800ms at
# startup and only two chords are ever used, so bind stubs that import on
# the first press instead. Key chords are interactive-only, so this sits
# inside the same ConsoleHost guard as the PSReadLine block above. The
# Get-Module -ListAvailable probe is gone too: it cost 63ms to learn
# something the first press finds out for free.
if ($Host.Name -eq 'ConsoleHost') {
    # No "already loaded" flag is needed: Set-PsFzfOption rewires both
    # chords to PSFzf's own handlers, so this stub is gone the moment it
    # succeeds. On failure the stub stays and reports again on the next
    # press.
    $__initPsFzf = {
        try {
            Import-Module PSFzf -ErrorAction Stop
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' | Out-Null
            return $true
        }
        catch { Write-Warning "PSFzf is not available: $_"; return $false }
    }
    Set-PSReadLineKeyHandler -Key 'Ctrl+t' -BriefDescription 'PSFzf provider (loads on first use)' -ScriptBlock {
        if (& $__initPsFzf) { Invoke-FzfPsReadlineHandlerProvider }
    }
    Set-PSReadLineKeyHandler -Key 'Ctrl+r' -BriefDescription 'PSFzf history (loads on first use)' -ScriptBlock {
        if (& $__initPsFzf) { Invoke-FzfPsReadlineHandlerHistory }
    }
}

# Jump to a ghq-managed repository (mirrors dot_bashrc.d/300-project-nav.sh).
if ((Get-Command ghq -ErrorAction SilentlyContinue) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
    function dev {
        $root = ghq root
        # fzf runs the preview through cmd on Windows: keep it one simple
        # command. Quote the path: a ghq root with a space needs one argument.
        # Prefer eza; fall back to dir when eza is not resolvable.
        $previewCmd = if (Get-Command eza -ErrorAction SilentlyContinue) { "eza -la `"$root\{}`"" } else { "dir `"$root\{}`"" }
        $repo = ghq list | fzf --prompt 'repo> ' --preview $previewCmd
        if (-not $repo) { return }
        Set-Location (Join-Path $root $repo)
    }
}

# --- Prompt: 2-line prompt, ported from dot_bashrc.d/200-integrations.sh.
# Line 1: [X mark, red, only when the previous command failed]
#         [venv indicator, cyan] (no nix indicator: nix does not run on
#         Windows)
#         user@host (green) + abbreviated path (blue) + git state (magenta)
# Line 2: [background job count, bright black, only when >=1] $ (becomes #
#         when the shell is elevated)
# Git markers: * unstaged  + staged  % untracked  $ stash
#              u+N/-N upstream ahead/behind (u= when equal)
# Deliberate omission: the bash side's `git config bash.showDirtyState`
# escape hatch is not ported.
# ponytail: two git calls per prompt; add the escape hatch if a heavy repo
# makes the prompt slow.

# Colors: ANSI base codes only, same numbers as the bash prompt. The
# terminal's color scheme supplies the actual hue.
$__pc_exit = '31' # exit code (red)
$__pc_env = '36'  # venv indicator (cyan)
$__pc_host = '32' # user@host (green)
$__pc_path = '34' # path (blue)
$__pc_git = '35'  # git state (magenta)
$__pc_jobs = '90' # background job count (bright black)

# Elevation never changes during the session, so decide once here, not
# inside `prompt` (which runs on every render).
$__pc_isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
        [Security.Principal.WindowsBuiltInRole]::Administrator)

# Abbreviate $PWD for display. Replace $HOME with ~. If the whole path
# exceeds 40 characters, shorten components from the left (never the last
# one) to their first character. Use two characters for dotfiles, for
# example .config becomes .c. Repeat until the path fits. Ported from the
# bash prompt's __prompt_pwd, backslash-joined for Windows paths.
function __prompt_pwd {
    $p = $PWD.Path
    if ($p -eq $HOME) { return '~' }
    if ($p.StartsWith("$HOME\", [StringComparison]::OrdinalIgnoreCase)) {
        $p = '~' + $p.Substring($HOME.Length)
    }

    $parts = $p -split '\\'
    $max = 40
    for ($i = 0; $i -lt $parts.Count - 1; $i++) {
        if (($parts -join '\').Length -le $max) { break }
        $seg = $parts[$i]
        if (-not $seg -or $seg -eq '~') { continue }
        if ($seg.StartsWith('.')) {
            $parts[$i] = $seg.Substring(0, [Math]::Min(2, $seg.Length))
        }
        else {
            $parts[$i] = $seg.Substring(0, 1)
        }
    }
    return ($parts -join '\')
}

# Git segment for line 1. One `git status --porcelain=v2 --branch` call
# builds the branch name (or short SHA when detached) and the dirty/
# upstream markers. A second call checks for a stash. Both calls are
# skipped when the first one fails (not a repo).
function __prompt_git {
    $lines = git status --porcelain=v2 --branch 2>$null
    if (-not $?) { return '' }

    $branch = ''
    $oid = ''
    $ahead = $null
    $behind = $null
    $unstaged = $false
    $staged = $false
    $untracked = $false

    foreach ($line in $lines) {
        if ($line -match '^# branch\.head (.+)$') { $branch = $matches[1]; continue }
        if ($line -match '^# branch\.oid (.+)$') { $oid = $matches[1]; continue }
        if ($line -match '^# branch\.ab \+(\d+) -(\d+)$') {
            $ahead = [int]$matches[1]; $behind = [int]$matches[2]; continue
        }
        if ($line -match '^[12] (\S\S) ') {
            if ($matches[1][0] -ne '.') { $staged = $true }
            if ($matches[1][1] -ne '.') { $unstaged = $true }
            continue
        }
        if ($line -match '^u ') { $staged = $true; $unstaged = $true; continue }
        if ($line -match '^\? ') { $untracked = $true; continue }
    }

    if ($branch -eq '(detached)') {
        $branch = $oid.Substring(0, [Math]::Min(7, $oid.Length))
    }

    $markers = ''
    if ($unstaged) { $markers += '*' }
    if ($staged) { $markers += '+' }
    if ($untracked) { $markers += '%' }

    $seg = $branch + $markers
    if ($null -ne $ahead) {
        $seg += if ($ahead -eq $behind) { ' u=' } else { " u+$ahead/-$behind" }
    }

    git rev-parse --verify -q refs/stash *>$null
    if ($?) { $seg += '$' }

    return " `e[${__pc_git}m($seg)`e[0m"
}

function prompt {
    # Capture the previous command's result FIRST, before anything else in
    # this function can overwrite $?. In pwsh 7, $? already reflects native
    # exit codes, so it alone is correct here.
    $__ok = $?
    $failed = -not $__ok

    $line1 = ''
    if ($failed) { $line1 += "`e[${__pc_exit}m✗ `e[0m" }

    if ($env:VIRTUAL_ENV) {
        $venv = Split-Path -Leaf $env:VIRTUAL_ENV
        $line1 += "`e[${__pc_env}m($venv) `e[0m"
    }

    $userHost = "$($env:USERNAME)@$($env:COMPUTERNAME.ToLowerInvariant())"
    $line1 += "`e[${__pc_host}m$userHost`e[0m "
    $line1 += "`e[${__pc_path}m$(__prompt_pwd)`e[0m"
    $line1 += __prompt_git

    $line2 = ''
    $jobCount = (Get-Job -State Running).Count
    if ($jobCount -gt 0) { $line2 += "`e[${__pc_jobs}m&$jobCount `e[0m" }
    $line2 += if ($__pc_isAdmin) { '# ' } else { '$ ' }

    return "$line1`n$line2"
}

# zoxide: skip on a machine without it, so the profile still loads. This
# has to come after `prompt` is defined: zoxide's init wraps whatever
# prompt exists when it runs, and a later definition would drop the hook
# that records the directories visited.
#
# The generated init script is cached: `zoxide init` costs a child
# process (~75ms) to print text that only changes when zoxide itself
# does. The binary's mtime invalidates it, and the command name is part
# of the file name so renaming it does not pick up a stale cache.
# ponytail: mtime of the resolved binary; delete the cache by hand if a
# shim hides an upgrade.
$__zoxideCmd = 'j'
$__zoxide = Get-Command zoxide -ErrorAction SilentlyContinue
if ($__zoxide) {
    $__cacheDir = if ($env:XDG_CACHE_HOME) { Join-Path $env:XDG_CACHE_HOME 'powershell' }
    else { Join-Path $env:USERPROFILE '.cache\powershell' }
    $__zoxideInit = Join-Path $__cacheDir "zoxide-init-$__zoxideCmd.ps1"

    try {
        # A zero-byte cache is left over from a version of this script that
        # wrote the init output before checking it. Its mtime carries no
        # signal, so rebuild whenever the file is empty, not just when it is
        # older than the binary.
        if (-not [IO.File]::Exists($__zoxideInit) -or
            (Get-Item $__zoxideInit).Length -eq 0 -or
            [IO.File]::GetLastWriteTimeUtc($__zoxideInit) -lt [IO.File]::GetLastWriteTimeUtc($__zoxide.Source)) {
            if (-not [IO.Directory]::Exists($__cacheDir)) { [void][IO.Directory]::CreateDirectory($__cacheDir) }
            # A failed or empty init must not reach the cache: its mtime
            # would be newer than the binary's, so nothing would regenerate
            # it until zoxide itself was upgraded.
            $__zoxideText = zoxide init powershell --cmd $__zoxideCmd | Out-String
            if ($LASTEXITCODE -ne 0 -or -not $__zoxideText.Trim()) {
                throw "zoxide init failed (exit $LASTEXITCODE)"
            }
            # Publish through a rename: a second shell starting at the same
            # moment must never dot-source a half-written file.
            $__zoxideTmp = "$__zoxideInit.$PID.tmp"
            try {
                [IO.File]::WriteAllText($__zoxideTmp, $__zoxideText, [Text.UTF8Encoding]::new($false))
                [IO.File]::Move($__zoxideTmp, $__zoxideInit, $true)
            }
            finally {
                # A Move that loses to a shell dot-sourcing the cache, or to a
                # directory sitting on the name, leaves this sibling behind and
                # nothing else ever collects it: one orphan per shell start.
                if ([IO.File]::Exists($__zoxideTmp)) { [IO.File]::Delete($__zoxideTmp) }
            }
        }
        . $__zoxideInit
    }
    catch {
        # An unwritable cache must not cost the shell its zoxide. Same guard as
        # above: never run the output of a failed init.
        $__zoxideText = zoxide init powershell --cmd $__zoxideCmd | Out-String
        if ($LASTEXITCODE -eq 0 -and $__zoxideText.Trim()) { Invoke-Expression $__zoxideText }
    }
}

# Machine-local settings, the pwsh counterpart of ~/.bashrc.local. chezmoi
# does not manage this file, so it survives every apply. Keep it last: it
# overrides everything above. Literal ~/.config, like the loader: that is
# where chezmoi puts the body regardless of XDG_CONFIG_HOME.
# -LiteralPath: [ and ] are legal in a Windows user name, and the default
# -Path would take them for a wildcard.
$__localProfile = Join-Path $env:USERPROFILE '.config\powershell\profile.local.ps1'
if (Test-Path -LiteralPath $__localProfile) { . $__localProfile }
