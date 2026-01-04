# Node.js Runtime

Concise notes focused on environment-specific behavior. See official docs for general usage.

## Official Documentation

- Node.js: https://nodejs.org/
- fnm: https://github.com/Schniz/fnm

## Installation

Managed by `run_onchange_client_ubuntu_110-nodejs.sh.tmpl`:
- Installs fnm (Fast Node Manager) to `~/.local/share/fnm`
- Installs latest LTS Node.js via fnm
- Shell integration defined in `home/dot_bashrc.d/200-runtimes.sh`

## Environment-specific Configuration

- fnm environment is set up in `~/.bashrc.d/200-runtimes.sh`:
  - `FNM_DIR="$HOME/.local/share/fnm"`
  - `PATH="$FNM_DIR:$PATH"`
  - `eval "$(fnm env)"` sets up Node.js paths
- Global tools should be installed via npm (`npm install -g <tool>`).
- Projects can use `.node-version` or `.nvmrc` files for version pinning.

## Common Commands

```bash
# List installed Node.js versions
fnm list

# Install specific version
fnm install 20

# Use specific version
fnm use 20

# Set default version
fnm default 20
```
