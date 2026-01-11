# Docker

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

- Docker Engine: https://docs.docker.com/engine/
- Docker Compose: https://docs.docker.com/compose/

## Installation

Installed via `run_onchange_client_ubuntu_210-docker.sh.tmpl` using official installation script.

**Important**: Run `chezmoi apply` on the host system (not inside a Docker container). Installation is automatically skipped in containers.

## User Group Management

The installation script automatically adds the current user to the `docker` group. After installation, activate the group:

```bash
# Option 1: Log out and log back in
# Option 2: Activate in current session
newgrp docker

# Verify
docker ps
```
