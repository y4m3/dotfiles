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

Files are loaded in lexicographic (numerical) order:

- **000-099**: Core functionality and foundation
  - `000-aliases-helper.sh`: Helper functions for alias management
  - `010-user-preferences.sh`: Basic environment variables and settings
  - `020-paths.sh`: PATH management
  - `030-security-permissions.sh`: Security settings (file permissions)

- **100-199**: Tool configuration (one tool per file, sequential numbering)
  - `100-eza.sh`: eza configuration
  - `101-bat.sh`: bat configuration
  - `102-ripgrep.sh`: ripgrep configuration
  - `103-fd.sh`: fd configuration
  - `105-direnv.sh`: direnv configuration
  - `106-fzf.sh`: fzf configuration
  - `107-completion.sh`: Other completion features (bash-completion, gh, etc.)

- **200-299**: Runtime initialization
  - `200-runtimes.sh`: Language runtime initialization (Rust, Node.js, Python, etc.)
  - `299-zoxide.sh`: zoxide configuration (loaded last to avoid conflicts with other tools)

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

The repository provides the implementation inside `299-zoxide.sh` but the
feature is disabled by default so each host can opt in.

Workflow

1. This repo guarantees `~/.bashrc` and `~/.bashrc.d/` exist.
2. Edit `~/.bashrc.d/010-user-preferences.sh` or create `~/.bashrc.local`
     for personal settings.
3. Use `~/.bashrc.$HOSTNAME` for strict host-specific tweaks.

Templates included in this repo are meant as starting points — keep
them minimal and safe to avoid surprising other hosts.
