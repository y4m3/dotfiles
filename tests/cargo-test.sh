#!/usr/bin/env bash
# Test Rust/Cargo installation and configuration
# Usage: ./tests/cargo-test.sh
# Or from Docker: bash tests/cargo-test.sh

set -euo pipefail

# Import test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

# Load Cargo environment (required for non-interactive shells)
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Ensure user bins are in PATH (fzf and local tools)
case ":$PATH:" in
    *":$HOME/.fzf/bin:"*) : ;;
    *) PATH="$HOME/.fzf/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":$HOME/.local/bin:"*) : ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Set CARGO_HOME to default if not already set
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

echo "=========================================="
echo "Testing Rust/Cargo Installation"
echo "=========================================="

# Test 1: rustc is installed
assert_executable "rustc" "rustc compiler installed"

# Test 2: cargo is installed
assert_executable "cargo" "cargo package manager installed"

# Test 3: rustup is installed
assert_executable "rustup" "rustup installer/manager installed"

# Test 4: Cargo bin directory exists
assert_command "[ -d \"$CARGO_HOME/bin\" ]" "Cargo bin directory exists"

# Test 5: Cargo bin is in PATH
assert_string_contains "$PATH" "$CARGO_HOME/bin" "Cargo bin in PATH"

# Test 6: rustc version can be retrieved
assert_command "rustc --version | command grep -q 'rustc'" "rustc version check successful"

# Test 7: cargo-installed CLI tools are available
for tool in bat eza fd rg starship zoxide; do
    assert_executable "$tool" "cargo tool available: $tool"
done

# Test 8: cargo version can be retrieved
assert_command "cargo --version | command grep -q 'cargo'" "cargo version check successful"

# Test 9: rustup shows stable toolchain
assert_command "rustup toolchain list | command grep -q stable" "rustup stable toolchain available"

echo ""
print_summary
