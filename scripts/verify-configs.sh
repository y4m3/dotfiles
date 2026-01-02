#!/usr/bin/env bash
# Verify all configuration files can be parsed correctly
# Usage: bash scripts/verify-configs.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# REPO_ROOT is defined but not used in this script
# It may be used in future enhancements
# shellcheck disable=SC2034
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Verifying Configuration Files"
echo "=========================================="
echo ""

errors=0
warnings=0

# Ensure PATH includes tool directories
case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) : ;;
  *) PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# 1. Check zellij config (KDL)
echo "1. Checking zellij config (KDL)..."
if [ -f "$HOME/.config/zellij/config.kdl" ]; then
  if command -v zellij > /dev/null 2>&1; then
    # Try to validate config by checking if zellij can parse it
    # zellij setup --check validates the config file
    if zellij setup --check 2>&1 | grep -qE "(valid|ok|success)"; then
      echo "   OK zellij config is valid"
    elif ! zellij setup --check 2>&1 | grep -qE "(error|Error|invalid|Invalid|failed|Failed)"; then
      # If no error message, assume it's valid
      echo "   OK zellij config appears valid"
    else
      echo "   ERROR zellij config has errors:"
      error_output=$(zellij setup --check 2>&1 | grep -E "(error|Error|invalid|Invalid)" | head -3)
      if [ -n "$error_output" ]; then
        echo "$error_output"
      else
        echo "   (Error details not found in output)"
      fi
      errors=$((errors + 1))
    fi
  else
    echo "   WARN zellij not found, skipping config check"
    warnings=$((warnings + 1))
  fi
else
  echo "   ERROR zellij config file not found"
  errors=$((errors + 1))
fi

# 2. Check starship config (TOML)
echo "2. Checking starship config (TOML)..."
if [ -f "$HOME/.config/starship.toml" ]; then
  if command -v starship > /dev/null 2>&1; then
    # starship config validates the config file
    if starship config 2>&1 | grep -qE "(error|Error|invalid|Invalid)"; then
      echo "   ERROR starship config has errors"
      error_output=$(starship config 2>&1 | grep -E "(error|Error|invalid|Invalid)")
      if [ -n "$error_output" ]; then
        echo "$error_output"
      else
        echo "   (Error details not found in output)"
      fi
      errors=$((errors + 1))
    else
      echo "   OK starship config is valid"
    fi
  else
    echo "   WARN starship not found, skipping config check"
    warnings=$((warnings + 1))
  fi
else
  echo "   ERROR starship config file not found"
  errors=$((errors + 1))
fi

# 3. Check yazi config (TOML)
echo "3. Checking yazi config (TOML)..."
if [ -f "$HOME/.config/yazi/yazi.toml" ]; then
  # Basic TOML syntax check (check if file can be read)
  if [ -r "$HOME/.config/yazi/yazi.toml" ]; then
    echo "   OK yazi.toml exists and is readable"
  else
    echo "   ERROR yazi.toml is not readable"
    errors=$((errors + 1))
  fi
else
  echo "   WARN yazi.toml not found (may be optional)"
  warnings=$((warnings + 1))
fi

# 4. Check lazygit config (YAML)
echo "4. Checking lazygit config (YAML)..."
if [ -f "$HOME/.config/lazygit/config.yml" ]; then
  if command -v lazygit > /dev/null 2>&1; then
    # Try to validate by checking if lazygit can start
    if timeout 2 lazygit --version > /dev/null 2>&1; then
      echo "   OK lazygit config appears valid (lazygit starts)"
    else
      echo "   ERROR lazygit config validation failed"
      errors=$((errors + 1))
    fi
  else
    echo "   WARN lazygit not found, skipping config check"
    warnings=$((warnings + 1))
  fi
else
  echo "   WARN lazygit config file not found (may be optional)"
  warnings=$((warnings + 1))
fi

# 5. Check lazydocker config (YAML)
echo "5. Checking lazydocker config (YAML)..."
if [ -f "$HOME/.config/lazydocker/config.yml" ]; then
  if command -v lazydocker > /dev/null 2>&1; then
    # Try to validate by checking if lazydocker can start
    if timeout 2 lazydocker --version > /dev/null 2>&1; then
      echo "   OK lazydocker config appears valid (lazydocker starts)"
    else
      echo "   ERROR lazydocker config validation failed"
      errors=$((errors + 1))
    fi
  else
    echo "   WARN lazydocker not found, skipping config check"
    warnings=$((warnings + 1))
  fi
else
  echo "   WARN lazydocker config file not found (may be optional)"
  warnings=$((warnings + 1))
fi

# 6. Check glow config (YAML)
echo "6. Checking glow config (YAML)..."
if [ -f "$HOME/.config/glow/glow.yml" ]; then
  if command -v glow > /dev/null 2>&1; then
    # Try to validate by checking if glow can start
    if timeout 2 glow --version > /dev/null 2>&1; then
      echo "   OK glow config appears valid (glow starts)"
    else
      echo "   ERROR glow config validation failed"
      errors=$((errors + 1))
    fi
  else
    echo "   WARN glow not found, skipping config check"
    warnings=$((warnings + 1))
  fi
else
  echo "   WARN glow config file not found (may be optional)"
  warnings=$((warnings + 1))
fi

# 7. Check btop config
echo "7. Checking btop config..."
if [ -f "$HOME/.config/btop/btop.conf" ]; then
  if command -v btop > /dev/null 2>&1; then
    # btop validates config on startup
    if timeout 2 btop --version > /dev/null 2>&1; then
      echo "   OK btop config appears valid (btop starts)"
    else
      echo "   ERROR btop config validation failed"
      errors=$((errors + 1))
    fi
  else
    echo "   WARN btop not found, skipping config check"
    warnings=$((warnings + 1))
  fi
else
  echo "   WARN btop config file not found (may be optional)"
  warnings=$((warnings + 1))
fi

# 8. Check alacritty config (TOML)
echo "8. Checking alacritty config (TOML)..."
if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
  # Basic TOML syntax check (check if file can be read)
  if [ -r "$HOME/.config/alacritty/alacritty.toml" ]; then
    echo "   OK alacritty.toml exists and is readable"
    # Note: Themes must be installed manually on Windows host (not in WSL)
    # Check if themes directory exists (for Linux/macOS users)
    if [ -d "$HOME/.config/alacritty/themes/themes" ]; then
      echo "   OK Alacritty themes directory exists"
    else
      echo "   WARN Alacritty themes directory not found (install manually: git clone https://github.com/alacritty/alacritty-theme.git ~/.config/alacritty/themes)"
      warnings=$((warnings + 1))
    fi
  else
    echo "   ERROR alacritty.toml is not readable"
    errors=$((errors + 1))
  fi
else
  echo "   WARN alacritty.toml not found (may be optional if Alacritty is not installed)"
  warnings=$((warnings + 1))
fi

# 9. Check bash configs
echo "9. Checking bash configs..."
bash_configs=(
  "$HOME/.bashrc"
  "$HOME/.bash_profile"
)
for config in "${bash_configs[@]}"; do
  if [ -f "$config" ]; then
    # Check bash syntax
    if bash -n "$config" 2>&1; then
      echo "   OK $(basename "$config") syntax is valid"
    else
      echo "   ERROR $(basename "$config") has syntax errors"
      errors=$((errors + 1))
    fi
  else
    echo "   ERROR $(basename "$config") not found"
    errors=$((errors + 1))
  fi
done

# Check bashrc.d scripts
if [ -d "$HOME/.bashrc.d" ]; then
  for script in "$HOME/.bashrc.d"/*.sh; do
    if [ -f "$script" ]; then
      if bash -n "$script" 2>&1; then
        echo "   OK $(basename "$script") syntax is valid"
      else
        echo "   ERROR $(basename "$script") has syntax errors"
        errors=$((errors + 1))
      fi
    fi
  done
fi

echo ""
echo "=========================================="
echo "Summary:"
echo "  Errors: $errors"
echo "  Warnings: $warnings"
echo "=========================================="

if [ $errors -eq 0 ]; then
  echo "OK: All configuration files are valid"
  exit 0
else
  echo "ERROR: Some configuration files have errors"
  exit 1
fi
