# .bashrc.d directory

This directory holds small, per-user shell fragments sourced by `~/.bashrc`.

Guiding principles

- Keep files here portable and non-sensitive. Host-specific or secret
    configuration belongs in `~/.bashrc.local` or `~/.bashrc.$HOSTNAME`.
- Files should be small shell snippets (typically `*.sh`) that perform
    safe, existence-checked initializations.
- Files are numbered with 3-digit prefixes to ensure execution order.
- One tool per file: each tool's configuration (environment variables, aliases,
    initialization, completion) is kept in a single file for cohesion.

Numbering system

Files are loaded in lexicographic (numerical) order. Numbers use 10-step
increments to allow future additions without renumbering.

- **0xx**: Core functionality and foundation
  - `010-aliases-helper.sh`: Helper functions for alias management
  - `020-user-preferences.sh`: Basic environment variables and settings
  - `030-paths.sh`: PATH management
  - `040-security-permissions.sh`: Security settings (file permissions)

- **1xx**: Tool configuration (one tool per file)
  - `110-eza.sh`: eza configuration
  - `120-bat.sh`: bat configuration
  - `130-ripgrep.sh`: ripgrep configuration
  - `140-fd.sh`: fd configuration
  - `150-direnv.sh`: direnv configuration
  - `160-fzf.sh`: fzf configuration
  - `170-completion.sh`: Completion features (bash-completion, gh, etc.)

- **2xx**: Prompt
  - `210-starship.sh`: Starship prompt configuration

- **8xx**: OS-specific
  - `810-wsl-editors.sh.tmpl`: WSL editor integration

- **9xx**: Must be last
  - `910-zoxide.sh`: zoxide configuration (must be loaded last)

Interactive vs non-interactive

- Aliases are set only in interactive shells (using `is_interactive()` helper)
- Environment variables needed by non-interactive scripts are set unconditionally
- User-defined aliases in `~/.bashrc.local` take precedence (via `alias_if_not_set()`)

Host-local and experimental helpers

- Do not commit host-specific or experimental helpers. Use
    `~/.bashrc.local` or `~/.bashrc.$HOSTNAME` for those.

Example: enable automatic `ls` after `cd` (opt-in)

Place the following in `~/.bashrc.local` to opt in:

```sh
ENABLE_CD_LS=1
```

The repository provides the implementation inside `910-zoxide.sh` but the
feature is disabled by default so each host can opt in.

Workflow

1. This repo guarantees `~/.bashrc` and `~/.bashrc.d/` exist.
2. Edit `~/.bashrc.d/020-user-preferences.sh` or create `~/.bashrc.local`
     for personal settings.
3. Use `~/.bashrc.$HOSTNAME` for strict host-specific tweaks.

Templates included in this repo are meant as starting points — keep
them minimal and safe to avoid surprising other hosts.
