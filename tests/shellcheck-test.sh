#!/usr/bin/env bash
# Test shellcheck and shfmt installation
# Usage: bash tests/shellcheck-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing shellcheck and shfmt"
echo "=========================================="

# Ensure ~/.local/bin is in PATH
case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Test 1: shellcheck is installed
assert_executable "shellcheck" "shellcheck installed"

# Test 2: shfmt is installed
assert_executable "shfmt" "shfmt installed"

# Test 3: shellcheck version can be retrieved
assert_command "shellcheck --version | command grep -q 'version:'" "shellcheck version check successful"

# Test 4: shfmt version can be retrieved
assert_command "shfmt --version" "shfmt version check successful"

# Test 5: shellcheck can lint a simple script
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat > "$tmpdir/test.sh" << 'EOF'
#!/bin/bash
echo "Hello, World!"
EOF

assert_command "shellcheck \"$tmpdir/test.sh\"" "shellcheck can lint simple script"

# Test 6: shfmt can format a simple script
cat > "$tmpdir/unformatted.sh" << 'EOF'
#!/bin/bash
if [ 1 -eq 1 ]; then
echo "test"
fi
EOF

assert_command "shfmt \"$tmpdir/unformatted.sh\" >/dev/null" "shfmt can format simple script"

echo ""
print_summary
