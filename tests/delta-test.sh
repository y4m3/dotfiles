#!/usr/bin/env bash
# Test delta installation and git integration
# Usage: bash tests/delta-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing delta"
echo "=========================================="

# Ensure ~/.local/bin is in PATH
case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "delta" "delta installed"
assert_command "delta --version" "delta version prints"

# Check git config integration
# Work around git worktree issue: unset GIT_DIR to avoid worktree path confusion
core_pager=$(GIT_DIR="" git config --global core.pager 2>&1 || echo "")
assert_string_contains "$core_pager" "delta" "git core.pager is delta"

tmprepo="$(setup_tmpdir)"
cd "$tmprepo"
git init -q

git config user.email test@example.com
git config user.name tester

echo "old" > sample.txt
git add sample.txt
git commit -q -m "init"

echo "new" > sample.txt
# shellcheck disable=SC2209  # capturing git diff output with fallback exit status
out=$(GIT_PAGER=delta git -c core.pager=delta diff sample.txt || true)

assert_string_contains "$out" "+new" "delta renders git diff output"

print_summary
