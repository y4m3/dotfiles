#!/usr/bin/env bash
# Quick syntax check for configuration files (lightweight, no Docker required)
# Usage: bash scripts/check-config-syntax.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Configuration File Syntax Check"
echo "=========================================="
echo ""

errors=0
warnings=0

# Check bash files
echo "1. Checking Bash configuration files..."
bash_files=(
  "home/dot_bashrc.tmpl"
  "home/dot_bash_profile.tmpl"
)
for file in "${bash_files[@]}"; do
  if [ -f "$REPO_ROOT/$file" ]; then
    if bash -n "$REPO_ROOT/$file" 2>&1; then
      echo "   OK $(basename "$file")"
    else
      echo "   ERROR $(basename "$file") has syntax errors"
      bash -n "$REPO_ROOT/$file" 2>&1 | head -3
      errors=$((errors + 1))
    fi
  fi
done

# Check bashrc.d scripts
if [ -d "$REPO_ROOT/home/dot_bashrc.d" ]; then
  for script in "$REPO_ROOT/home/dot_bashrc.d"/*.sh; do
    if [ -f "$script" ]; then
      if bash -n "$script" 2>&1; then
        echo "   OK $(basename "$script")"
      else
        echo "   ERROR $(basename "$script") has syntax errors"
        bash -n "$script" 2>&1 | head -3
        errors=$((errors + 1))
      fi
    fi
  done
fi

# Check TOML files (basic structure check)
echo ""
echo "2. Checking TOML configuration files..."
toml_files=(
  "home/dot_config/create_starship.toml.tmpl"
  "home/dot_config/yazi/yazi.toml.tmpl"
  "home/dot_config/yazi/keymap.toml.tmpl"
  "home/dot_config/yazi/theme.toml.tmpl"
)
for file in "${toml_files[@]}"; do
  if [ -f "$REPO_ROOT/$file" ]; then
    # Basic check: file is readable and not empty
    if [ -s "$REPO_ROOT/$file" ]; then
      # Check for basic TOML structure (has sections or key=value pairs)
      if grep -qE "^\[|^[a-zA-Z_][a-zA-Z0-9_]*\s*=" "$REPO_ROOT/$file" 2> /dev/null; then
        echo "   OK $(basename "$file") appears to be valid TOML"
      else
        echo "   WARN $(basename "$file") may not be valid TOML (no sections or key=value pairs found)"
        warnings=$((warnings + 1))
      fi
    else
      echo "   ERROR $(basename "$file") is empty"
      errors=$((errors + 1))
    fi
  fi
done

# Check KDL file (zellij config)
echo ""
echo "3. Checking KDL configuration file (zellij)..."
kdl_file="home/dot_config/zellij/create_config.kdl.tmpl"
if [ -f "$REPO_ROOT/$kdl_file" ]; then
  # Basic check: file is readable and has KDL-like structure
  if [ -s "$REPO_ROOT/$kdl_file" ]; then
    # Check for basic KDL structure (has key-value pairs or blocks)
    if grep -qE "^[a-zA-Z_][a-zA-Z0-9_]*\s|^[a-zA-Z_][a-zA-Z0-9_]*\s*\{|^//" "$REPO_ROOT/$kdl_file" 2> /dev/null; then
      echo "   OK $(basename "$kdl_file") appears to have KDL structure"
      echo "   Note: Full validation requires zellij setup --check (run in Docker)"
    else
      echo "   WARN $(basename "$kdl_file") may not be valid KDL"
      warnings=$((warnings + 1))
    fi
  else
    echo "   ERROR $(basename "$kdl_file") is empty"
    errors=$((errors + 1))
  fi
else
  echo "   ERROR $(basename "$kdl_file") not found"
  errors=$((errors + 1))
fi

# Check YAML files
echo ""
echo "4. Checking YAML configuration files..."
yaml_files=(
  "home/dot_config/lazygit/create_config.yml.tmpl"
  "home/dot_config/lazydocker/create_config.yml.tmpl"
)
for file in "${yaml_files[@]}"; do
  if [ -f "$REPO_ROOT/$file" ]; then
    # Basic check: file is readable and has YAML-like structure
    if [ -s "$REPO_ROOT/$file" ]; then
      # Check for basic YAML structure (has key: value pairs)
      if grep -qE "^[a-zA-Z_][a-zA-Z0-9_]*\s*:" "$REPO_ROOT/$file" 2> /dev/null; then
        echo "   OK $(basename "$file") appears to have YAML structure"
        echo "   Note: Full validation requires YAML parser (run in Docker)"
      else
        echo "   WARN $(basename "$file") may not be valid YAML"
        warnings=$((warnings + 1))
      fi
    else
      echo "   ERROR $(basename "$file") is empty"
      errors=$((errors + 1))
    fi
  fi
done

echo ""
echo "=========================================="
echo "Summary:"
echo "  Errors: $errors"
echo "  Warnings: $warnings"
echo "=========================================="
echo ""
echo "Note: This is a lightweight static check."
echo "For full validation, run 'make dev' and test tools interactively,"
echo "or run 'make test-all' to execute all tests in Docker."

if [ $errors -eq 0 ]; then
  echo ""
  echo "OK: All configuration files pass static syntax check"
  exit 0
else
  echo ""
  echo "ERROR: Some configuration files have syntax errors"
  exit 1
fi
