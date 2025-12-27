#!/usr/bin/env bash
# Test direnv installation and basic functionality
# Usage: bash tests/direnv-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing direnv"
echo "=========================================="

# Ensure ~/.local/bin is on PATH
case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "direnv" "direnv installed"
assert_command "direnv version" "direnv version check"
assert_command "direnv hook bash >/dev/null" "direnv hook generates bash code"

# Functional check: .envrc is applied via direnv exec
workdir="$(setup_tmpdir)"
cat > "$workdir/.envrc" << 'EOF'
export DIRENV_TEST_VAR=ok
EOF

direnv allow "$workdir"
# shellcheck disable=SC2016  # inner shell expands DIRENV_TEST_VAR
value=$(direnv exec "$workdir" bash -c "echo -n \"\$DIRENV_TEST_VAR\"")

assert_string_contains "$value" "ok" "direnv exec applies .envrc"

print_summary
