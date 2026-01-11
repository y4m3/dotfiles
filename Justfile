# Justfile for dotfiles linting and formatting
# Requires: shellcheck, shfmt (installed via Nix Home Manager)
set shell := ["bash", "-c"]

# Default recipe: show help
default:
    @just --list

# Run shellcheck on all shell scripts
lint:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> Running shellcheck on shell scripts..."
    shellcheck -e SC1090,SC1091 \
        home/dot_bashrc.d/*.sh \
        home/dot_bash_prompt.d/*.sh
    echo "==> Running shellcheck on .chezmoiscripts (template-aware)..."
    for f in home/.chezmoiscripts/*.sh.tmpl; do
        # Remove chezmoi template guard lines (starting with double-brace) before shellcheck
        # The sed pattern uses Just's brace escaping: {{'{{' + '}}'}} produces literal braces
        if ! sed '/^{{'{{'}}-.*{{'}}'}}/d' "$f" | shellcheck -e SC1090,SC1091 -; then
            echo "shellcheck failed: $f"
            exit 1
        fi
    done
    echo "✓ All shell scripts passed shellcheck"

# Format all shell scripts with shfmt
format:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> Formatting shell scripts with shfmt..."
    shfmt -w \
        home/dot_bashrc.d/*.sh \
        home/dot_bash_prompt.d/*.sh
    echo "==> Formatting .chezmoiscripts (preserving template guards)..."
    for f in home/.chezmoiscripts/*.sh.tmpl; do
        # Preserve first line (template guard), format middle, preserve last line
        head -1 "$f" > "$f.tmp"
        tail -n +2 "$f" | head -n -1 | shfmt >> "$f.tmp"
        tail -1 "$f" >> "$f.tmp"
        mv "$f.tmp" "$f"
    done
    echo "✓ Shell scripts formatted"

# Check formatting without modifying files
check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> Checking shell script formatting..."
    shfmt -d \
        home/dot_bashrc.d/*.sh \
        home/dot_bash_prompt.d/*.sh
    echo "✓ Formatting check passed"
