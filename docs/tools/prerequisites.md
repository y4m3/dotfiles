# Prerequisites and Base Tools

Concise notes focused on environment-specific behavior. See official docs for usage.

## Installed via `run_once_000-prerequisites.sh.tmpl`

- build tools: `build-essential`, `pkg-config`
- version control: `git` (see `~/.gitconfig` and `~/.gitconfig.local`)
- terminal utilities: `tmux` (see [tmux](tmux.md)), `xclip` (clipboard)
- text processing: `jq` (JSON). For YAML, see [yq](yq.md)
- downloads/archives: `curl`, `wget`, `tar`, `unzip`
- filesystem: `tree`
- system: `ca-certificates`, `gnupg`, `software-properties-common`

## Environment-specific Notes

- Clipboard integration via `xclip` is expected by tmux/zellij configs.
- Git identity is validated by a global pre-commit hook; edit `~/.gitconfig.local` before committing.
- Packages are installed via apt to avoid sudo in day-to-day flows; user-level tools go to `~/.local/bin`.

## Verification

For verification and usage of each tool, refer to their official documentation:
- Git: https://git-scm.com/doc
- jq: https://jqlang.github.io/jq/
- tmux: https://github.com/tmux/tmux
- curl: https://curl.se/docs/
- tree: https://github.com/Old-Man-Programmer/tree
