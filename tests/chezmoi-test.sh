#!/usr/bin/env bash
# chezmoi-test.sh
# Test chezmoi dotfiles manager installation and functionality

set -euo pipefail

# Source test helpers
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$script_dir/lib/helpers.sh"

total_tests=0
passed_tests=0

echo "=========================================="
echo "Testing chezmoi"
echo "=========================================="

# Test 1: Check if chezmoi is installed
total_tests=$((total_tests + 1))
if command -v chezmoi &> /dev/null; then
  passed_tests=$((passed_tests + 1))
  echo "PASS: chezmoi installed"
else
  echo "FAIL: chezmoi not found in PATH"
fi

# Test 2: Check chezmoi version
total_tests=$((total_tests + 1))
if version=$(chezmoi --version 2> /dev/null); then
  passed_tests=$((passed_tests + 1))
  echo "PASS: chezmoi version prints"
  echo "      Version: $version"
else
  echo "FAIL: chezmoi --version failed"
fi

# Test 3: Check chezmoi help works
total_tests=$((total_tests + 1))
if chezmoi help &> /dev/null; then
  passed_tests=$((passed_tests + 1))
  echo "PASS: chezmoi help works"
else
  echo "FAIL: chezmoi help failed"
fi

# Test 4: Check chezmoi can show data
total_tests=$((total_tests + 1))
if chezmoi data &> /dev/null; then
  passed_tests=$((passed_tests + 1))
  echo "PASS: chezmoi data command works"
else
  echo "FAIL: chezmoi data command failed"
fi

# Print test summary
echo ""
echo "================================"
echo "Test Summary:"
echo "  Passed: $passed_tests"
echo "  Failed: $((total_tests - passed_tests))"
echo "  Total:  $total_tests"
echo "================================"

if [ "$passed_tests" -eq "$total_tests" ]; then
  echo "All tests passed!"
  exit 0
else
  echo "Some tests failed!"
  exit 1
fi
