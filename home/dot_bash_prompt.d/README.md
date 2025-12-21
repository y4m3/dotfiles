# ~/.bash_prompt.d/

This directory contains selectable prompt styles for bash. Available prompt styles:

- `bare` — Minimal and server-friendly style. Displays exit status (✓ for success, ✗ for failure), git branch name, and dirty marker (*). Has no external dependencies.
- `enhanced` — Colorized prompt style. Displays exit status (✓/✗), git branch name with dirty marker, Python version, and active virtual environment name.

## Selection Priority (from highest to lowest)

1. Environment variable `PROMPT_STYLE` (set in `~/.bashrc.local` or shell session)
2. Built-in default: `bare`

## Usage Example (Session-only Switch)

To change the prompt style for the current session only:

```sh
export PROMPT_STYLE=enhanced
exec $SHELL
```

## Persistent Configuration

To persistently change the prompt style, add the following to `~/.bashrc.local`:

```sh
export PROMPT_STYLE=enhanced
```

## Detailed Prompt Style Descriptions

### bare (Minimal Style)

Example output:

```
✓ (main*) user@host:cwd $
✗ (develop) user@host:cwd $
```

Features:

- **exit status**: ✓ symbol indicates successful command execution (exit code 0), ✗ symbol indicates failed command execution (non-zero exit code)
- **git branch**: Shows current git branch name in parentheses `(branch-name)`. The `*` asterisk symbol indicates dirty state (uncommitted changes exist in the working directory)
- **external dependencies**: None required. Git branch information is displayed only when `git` command is available on the system

### enhanced (Feature-rich Style)

Example output:

```
✓ user@host:cwd (main*)[3.11.6][venv-name] $
✗ user@host:cwd (develop)[3.11.0] $
```

Features:

- **exit status**: ✓ symbol indicates successful command execution (exit code 0), ✗ symbol indicates failed command execution (non-zero exit code)
- **colored display**: Username@hostname displayed in green color, current working directory path displayed in blue color
- **git branch**: Shows current git branch name in parentheses `(branch-name)`. The `*` asterisk symbol indicates dirty state (uncommitted changes exist)
- **Python version**: Displays Python version number in square brackets `[version]`, detected from `.python-version` file or active virtual environment
- **venv**: Displays active Python virtual environment name in square brackets `[venv-name]` when a virtual environment is activated

Python version detection priority order:

1. `$(pwd)/.python-version` — Reads from .python-version file in the current project directory
2. `$VIRTUAL_ENV/.python-version` — Reads from .python-version file in the virtual environment directory

## Troubleshooting

**When ✓ and ✗ symbols are not displayed:**

- Verify that your terminal application supports UTF-8 encoding
- Try adding a UTF-8 locale setting to `.bashrc.local`, for example: `export LANG=en_US.UTF-8`

**When git information is not displayed:**

- Verify that the `git` command is installed on your system: run `which git`
- Verify that `git status` command works correctly when executed inside a git repository directory
