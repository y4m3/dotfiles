# direnv

Load and unload environment variables depending on the current directory.

## Official Documentation

https://direnv.net/

## Installation

Managed by `run_onchange_client_ubuntu_240-direnv.sh.tmpl`:
- Downloads latest release from GitHub
- Installs to `~/.local/bin/direnv`
- Shell hook added in `~/.bashrc.d/105-direnv.sh`

## Configuration

### Shell Integration

Automatically loaded via `~/.bashrc.d/105-direnv.sh`:
```bash
eval "$(direnv hook bash)"
```

## Team Policy

- `.envrc` is per-project and versioned for the team.
- Use only direnv stdlib and widely available tool commands (e.g., `uv`).

## Usage

For general usage and examples, refer to the [direnv documentation](https://direnv.net/).

## Repository-specific Examples

See `docs/templates/envrc-examples.md` for portable snippets used in this repository.

## Security

For security best practices, refer to the [direnv documentation](https://direnv.net/). Key points:
- `.envrc` must be explicitly allowed with `direnv allow`
- Changes to `.envrc` require re-approval
- Keep secrets out of VCS
