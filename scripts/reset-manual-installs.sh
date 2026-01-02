#!/usr/bin/env bash
# Reset manual installations by comparing current state with snapshot
# This script removes files that were added after the snapshot was created

set -euo pipefail

SNAPSHOT_DIR="${SNAPSHOT_DIR:-/root/.local/share/env-snapshot}"

if [ ! -d "$SNAPSHOT_DIR" ] || [ ! -f "$SNAPSHOT_DIR/timestamp.txt" ]; then
  echo "Error: No snapshot found. Run 'make test-all' first to create a snapshot." >&2
  exit 1
fi

echo "==> Resetting manual installations..."
echo "  Snapshot created: $(cat "$SNAPSHOT_DIR/timestamp.txt")"

# Compare ~/.local/bin
if [ -f "$SNAPSHOT_DIR/local-bin-files.txt" ]; then
  current_files=$(mktemp)
  if [ -d "$HOME/.local/bin" ]; then
    find "$HOME/.local/bin" -type f -executable | sort > "$current_files"
  else
    touch "$current_files"
  fi

  # Find files that were added after snapshot
  # comm returns non-zero if files don't exist, but we've already checked they exist
  if ! added_files=$(comm -13 "$SNAPSHOT_DIR/local-bin-files.txt" "$current_files" 2>&1); then
    echo "Error: Failed to compare files in ~/.local/bin" >&2
    echo "$added_files" >&2
    added_files=""
  fi

  if [ -n "$added_files" ]; then
    echo "  Removing manually installed files from ~/.local/bin:"
    echo "$added_files" | while read -r file; do
      echo "    - $(basename "$file")"
      rm -f "$file"
    done
  else
    echo "  No manually installed files found in ~/.local/bin"
  fi

  rm -f "$current_files"
fi

# Compare ~/.cargo/bin
if [ -f "$SNAPSHOT_DIR/cargo-bin-files.txt" ]; then
  current_files=$(mktemp)
  if [ -d "$HOME/.cargo/bin" ]; then
    find "$HOME/.cargo/bin" -type f -executable | sort > "$current_files"
  else
    touch "$current_files"
  fi

  # comm returns non-zero if files don't exist, but we've already checked they exist
  if ! added_files=$(comm -13 "$SNAPSHOT_DIR/cargo-bin-files.txt" "$current_files" 2>&1); then
    echo "Error: Failed to compare files in ~/.cargo/bin" >&2
    echo "$added_files" >&2
    added_files=""
  fi

  if [ -n "$added_files" ]; then
    echo "  Removing manually installed cargo tools:"
    echo "$added_files" | while read -r file; do
      tool_name=$(basename "$file")
      echo "    - $tool_name"
      # Try cargo uninstall first, then remove binary
      # cargo uninstall may fail if package is not installed via cargo, which is acceptable
      if ! cargo uninstall "$tool_name" 2>&1; then
        echo "      (cargo uninstall failed, removing binary directly)"
      fi
      rm -f "$file"
    done
  else
    echo "  No manually installed cargo tools found"
  fi

  rm -f "$current_files"
fi

# Compare apt packages
if [ -f "$SNAPSHOT_DIR/apt-packages.txt" ]; then
  current_packages=$(mktemp)
  dpkg -l | awk '/^ii/ {print $2 " " $3}' > "$current_packages"

  # Find packages that were added after snapshot
  # comm may fail if process substitution fails, but we've already created the files
  if ! added_packages=$(comm -13 <(awk '{print $1}' "$SNAPSHOT_DIR/apt-packages.txt" | sort) \
    <(awk '{print $1}' "$current_packages" | sort) 2>&1); then
    echo "Error: Failed to compare apt packages" >&2
    echo "$added_packages" >&2
    added_packages=""
  fi

  if [ -n "$added_packages" ]; then
    echo "  Manually installed apt packages (remove manually if needed):"
    echo "$added_packages" | while read -r pkg; do
      echo "    - $pkg"
    done
    echo "  Run 'sudo apt-get remove <package>' to remove them"
  else
    echo "  No manually installed apt packages found"
  fi

  rm -f "$current_packages"
fi

# Note about ~/.config
echo "  Note: Manually created config files in ~/.config may need manual cleanup"

echo "✓ Manual installations reset"
echo "  Next 'make dev' will restore state A (run_once installed tools only)"
