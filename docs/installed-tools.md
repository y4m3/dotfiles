# Installed Tools

Complete list of tools managed by this dotfiles repository. Each tool links to its detailed documentation.

## Prerequisites (apt)

Managed by `run_once_000-prerequisites.sh.tmpl`:

- **build-essential** - GCC, G++, Make compilers
- **pkg-config** - Compile/link flag manager
- **git** - Version control system  
  https://git-scm.com/
- **jq** - Command-line JSON processor  
  https://jqlang.github.io/jq/
- **tmux** - Terminal multiplexer | [docs](tools/tmux.md)  
  https://github.com/tmux/tmux
- **xclip** - X11 clipboard integration
- **curl** / **wget** - File download tools
- **tree** - Directory structure visualizer
- **unzip** / **tar** - Archive extraction

See [prerequisites guide](tools/prerequisites.md) for all base tools.

## Language Runtimes

- **Rust** (rustup + cargo) - Rust toolchain | [docs](tools/cargo-tools.md)  
  https://www.rust-lang.org/  
  Managed by `run_once_100-runtimes-rust.sh.tmpl`
  
- **Node.js** (via Volta) - JavaScript runtime | [docs](tools/nodejs.md)  
  https://nodejs.org/ | https://volta.sh/  
  Managed by `run_once_110-runtimes-nodejs.sh.tmpl`
  
- **uv** - Fast Python package and project manager | [docs](tools/uv.md)  
  https://github.com/astral-sh/uv  
  Managed by `run_once_120-runtimes-python-uv.sh.tmpl`

## Shell & CLI Tools

- **direnv** - Load/unload environment variables by directory | [docs](tools/direnv.md)  
  https://direnv.net/  
  Managed by `run_once_240-shell-direnv.sh.tmpl`
  
- **fzf** - Fuzzy finder for command-line | [docs](tools/fzf.md)  
  https://github.com/junegunn/fzf  
  Managed by `run_once_200-shell-fzf.sh.tmpl`
  
- **shellcheck** - Shell script linter | [docs](tools/shellcheck-shfmt.md)  
  https://www.shellcheck.net/  
  Managed by `run_once_250-shell-shellcheck.sh.tmpl`
  
- **shfmt** - Shell script formatter | [docs](tools/shellcheck-shfmt.md)  
  https://github.com/mvdan/sh  
  Managed by `run_once_250-shell-shellcheck.sh.tmpl`
  
- **yq** - YAML processor (jq for YAML) | [docs](tools/yq.md)  
  https://github.com/mikefarah/yq  
  Managed by `run_once_275-utils-yq.sh.tmpl`
  
- **zoxide** - Smarter cd command (jump to directories) | [docs](tools/zoxide.md)  
  https://github.com/ajeetdsouza/zoxide  
  Managed by `run_once_210-shell-cargo-tools.sh.tmpl`

## Cargo Tools (Rust-based)

All installed via `run_once_210-shell-cargo-tools.sh.tmpl` | [docs](tools/rust-cli-tools.md)

- **bat** - Cat clone with syntax highlighting  
  https://github.com/sharkdp/bat
  
- **eza** - Modern ls replacement (exa successor)  
  https://github.com/eza-community/eza
  
- **fd** - Simple, fast alternative to find  
  https://github.com/sharkdp/fd
  
- **ripgrep (rg)** - Fast grep alternative  
  https://github.com/BurntSushi/ripgrep
  
- **starship** - Cross-shell prompt  
  https://starship.rs/

## Git & Development Tools

- **delta** - Syntax-highlighting pager for git diff | [docs](tools/delta.md)  
  https://github.com/dandavison/delta  
  Managed by `run_once_320-devtools-delta.sh.tmpl`
  
- **gh** - GitHub CLI | [docs](tools/github-tools.md)  
  https://cli.github.com/  
  Managed by `run_once_300-devtools-gh.sh.tmpl`
  
- **ghq** - Remote repository management | [docs](tools/github-tools.md)  
  https://github.com/x-motemen/ghq  
  Managed by `run_once_310-devtools-ghq.sh.tmpl`
  
- **lazygit** - Terminal UI for git | [docs](tools/lazygit.md)  
  https://github.com/jesseduffield/lazygit  
  Managed by `run_once_330-devtools-lazygit.sh.tmpl`

## Utilities & Monitoring

- **btop** - Resource monitor (top replacement) | [docs](tools/btop.md)  
  https://github.com/aristocratos/btop  
  Managed by `run_once_280-utils-btop.sh.tmpl`
  
- **yazi** - Terminal file manager | [docs](tools/yazi.md)  
  https://github.com/sxyazi/yazi  
  Managed by `run_once_285-utils-yazi.sh.tmpl`

## Terminal & Container Tools

- **zellij** - Terminal multiplexer (tmux alternative) | [docs](tools/zellij.md)  
  https://github.com/zellij-org/zellij  
  Managed by `run_once_265-terminal-zellij.sh.tmpl`
  
- **lazydocker** - Terminal UI for Docker | [docs](tools/lazydocker.md)  
  https://github.com/jesseduffield/lazydocker  
  Managed by `run_once_340-devtools-lazydocker.sh.tmpl`

## Configuration Highlights

All tools are configured with:
- **Tokyo Night** inspired color themes (consistent across tools)
- **Vim-style keybindings** (h/j/k/l navigation where applicable)
- **System clipboard integration** (xclip for copy/paste)
- **Shell integration** (completions, aliases, environment variables)
- **Nerd Fonts** support (icons and glyphs)

See individual tool documentation in [docs/tools/](tools/) for configuration details.

See `docs/tools/` for detailed configuration guides.
