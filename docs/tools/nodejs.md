# Node.js Runtime

Concise notes focused on environment-specific behavior. See official docs for general usage.

## Official Documentation

- Node.js: https://nodejs.org/

## Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`):
- Installs Node.js 22 LTS directly (required for Claude Code and MCP servers)
- No version manager required (single version managed by Nix)

## Environment-specific Configuration

- Node.js is available system-wide via Nix PATH
- Global tools should be installed via npm (`npm install -g <tool>`)
- Projects can use `.nvmrc` files for documentation purposes

## Version Management

This configuration uses a fixed Node.js version managed by Nix:
- Update version in `home/dot_config/nix/home.nix` (e.g., `nodejs_22` → `nodejs_24`)
- Run `home-manager switch` to apply changes
