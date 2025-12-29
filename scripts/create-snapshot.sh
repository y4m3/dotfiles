#!/usr/bin/env bash
# Create snapshot of environment A (state after successful make test-all)
# This snapshot is used to detect manually installed tools

set -euo pipefail

SNAPSHOT_DIR="${SNAPSHOT_DIR:-/root/.local/share/env-snapshot}"
mkdir -p "$SNAPSHOT_DIR"

echo "==> Creating environment snapshot..."

# Snapshot ~/.local/bin
if [ -d "$HOME/.local/bin" ]; then
  find "$HOME/.local/bin" -type f -executable | sort > "$SNAPSHOT_DIR/local-bin-files.txt"
  echo "  Snapshot: $(wc -l < "$SNAPSHOT_DIR/local-bin-files.txt") files in ~/.local/bin"
fi

# Snapshot ~/.cargo/bin
if [ -d "$HOME/.cargo/bin" ]; then
  find "$HOME/.cargo/bin" -type f -executable | sort > "$SNAPSHOT_DIR/cargo-bin-files.txt"
  echo "  Snapshot: $(wc -l < "$SNAPSHOT_DIR/cargo-bin-files.txt") files in ~/.cargo/bin"
fi

# Snapshot ~/.config structure (excluding chezmoi-managed files)
if [ -d "$HOME/.config" ]; then
  # List all directories and files, excluding chezmoi
  find "$HOME/.config" -mindepth 1 -maxdepth 2 \
    ! -path "$HOME/.config/chezmoi/*" \
    \( -type d -o -type f \) | sort > "$SNAPSHOT_DIR/config-structure.txt"
  echo "  Snapshot: $(wc -l < "$SNAPSHOT_DIR/config-structure.txt") items in ~/.config"
fi

# Snapshot installed apt packages
dpkg -l | awk '/^ii/ {print $2 " " $3}' > "$SNAPSHOT_DIR/apt-packages.txt"
echo "  Snapshot: $(wc -l < "$SNAPSHOT_DIR/apt-packages.txt") apt packages"

# Create timestamp
date -Iseconds > "$SNAPSHOT_DIR/timestamp.txt"

echo "✓ Environment snapshot created at $SNAPSHOT_DIR"
