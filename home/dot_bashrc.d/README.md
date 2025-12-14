# .bashrc.d directory

This directory holds small, per-user shell fragments sourced by `~/.bashrc`.

Guiding principles

- Keep files here portable and non-sensitive. Host-specific or secret
    configuration belongs in `~/.bashrc.local` or `~/.bashrc.$HOSTNAME`.
- Files should be small shell snippets (typically `*.sh`) that perform
    safe, existence-checked initializations.

Recommended repository-managed files (minimal):

- `10-user-preferences.sh` — personal preferences: editor, readline mode,
    safety aliases. Intended as a per-user starting point.
- `20-paths.sh` — PATH additions with deduplication logic.
- `30-completion.sh` — shell completion setup (currently empty, ready for
    bash-completion or fzf configuration).
- `40-runtimes.sh` — language runtime initializers (pyenv/nvm/asdf),
    kept minimal and conditional (currently empty, ready for runtime setup).
- `60-utils.sh` — small interactive helpers and aliases (includes
    optional `cd` → `ls` helper; enable via `ENABLE_CD_LS=1` in
    `~/.bashrc.local`).

Host-local and experimental helpers

- Do not commit host-specific or experimental helpers. Use
    `~/.bashrc.local` or `~/.bashrc.$HOSTNAME` for those.

Example: enable automatic `ls` after `cd` (opt-in)

Place the following in `~/.bashrc.local` to opt in:

```sh
ENABLE_CD_LS=1
```

The repository provides the implementation inside `60-utils.sh` but the
feature is disabled by default so each host can opt in.

Workflow

1. This repo guarantees `~/.bashrc` and `~/.bashrc.d/` exist.
2. Edit `~/.bashrc.d/10-user-preferences.sh` or create `~/.bashrc.local`
     for personal settings.
3. Use `~/.bashrc.$HOSTNAME` for strict host-specific tweaks.

Templates included in this repo are meant as starting points — keep
them minimal and safe to avoid surprising other hosts.
