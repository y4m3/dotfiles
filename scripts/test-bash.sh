#!/usr/bin/env bash
set -euo pipefail

# Create temporary directory and ensure cleanup on exit
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

# 1) Interactive shell should export expected PATH entries
bash -ic 'echo "$PATH"' >"$tmpdir/path.out" 2>"$tmpdir/path.err" || fail "bash -ic PATH"
if ! grep -q "/home" "$tmpdir/path.out" && ! grep -q "$HOME/.local/bin" "$tmpdir/path.out"; then
  fail "PATH does not contain home bin entries"
fi
pass "PATH includes home bin entries"

# 2) Locale is set to UTF-8
bash -ic 'echo "$LANG $LC_ALL"' >"$tmpdir/locale.out" 2>"$tmpdir/locale.err" || fail "bash -ic locale"
if ! grep -qi "utf-8" "$tmpdir/locale.out"; then
  fail "Locale not UTF-8"
fi
pass "Locale is UTF-8"

# 3) bash-completion available
bash -ic 'type _init_completion >/dev/null 2>&1' 2>/dev/null && pass "bash-completion available" || fail "bash-completion missing"

# 4) Prompt files deployed
[ -f "$HOME/.bash_prompt.d/bare.sh" ] && [ -f "$HOME/.bash_prompt.d/enhanced.sh" ] || fail "Prompt files missing"
pass "Prompt files present"

# 5) Colors available
bash -ic 'tput colors' >"$tmpdir/colors.out" 2>"$tmpdir/colors.err" || fail "tput colors"
if [ "$(cat "$tmpdir/colors.out")" -lt 16 ]; then
  fail "Terminal reports fewer than 16 colors"
fi
pass "Terminal supports colors"

echo "All checks passed"
