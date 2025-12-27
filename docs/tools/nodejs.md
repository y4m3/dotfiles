# Node.js Runtime

Concise notes focused on environment-specific behavior. See official docs for general usage.

## Official Documentation

- Node.js: https://nodejs.org/
- Volta: https://volta.sh/

## Installation

Managed by `run_once_110-runtimes-nodejs.sh.tmpl`:
- Installs Volta and latest LTS Node.js
- Installs npm, yarn, pnpm as needed
- Shell integration defined in `home/dot_bashrc.d/40-runtimes.sh`

## Environment-specific Configuration

- PATH includes Volta and user npm prefix:
  - `VOLTA_HOME="$HOME/.volta"`
  - `PATH="$VOLTA_HOME/bin:$PATH"`
  - `NPM_CONFIG_PREFIX="$HOME/.npm-global"`
  - `PATH="$NPM_CONFIG_PREFIX/bin:$PATH"`
- Global tools should be installed via Volta (`volta install <tool>`), not `npm -g`.
- Projects should pin Node.js and package manager using Volta (`package.json` `volta` field).
- No enforced package manager preference (npm/yarn/pnpm). Use per-project choice.

 
