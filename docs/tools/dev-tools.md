# Development Tools

All tools managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

## Code Quality

### Shell

| Tool | Description | Documentation |
|------|-------------|---------------|
| **shellcheck** | Shell script linter | https://github.com/koalaman/shellcheck |
| **shfmt** | Shell script formatter | https://github.com/mvdan/sh |

This repository uses `Justfile` for shell script quality:

```bash
just lint    # Run shellcheck across *.sh
just format  # Run shfmt across home/
just check   # Check formatting
```

### JavaScript/Markdown

| Tool | Description | Documentation |
|------|-------------|---------------|
| **prettier** | Code formatter (JS, JSON, MD) | https://prettier.io/ |
| **markdownlint-cli2** | Markdown linter | https://github.com/DavidAnson/markdownlint-cli2 |
| **markdown-toc** | Markdown TOC generator | https://github.com/jonschlinkert/markdown-toc |
| **mermaid-cli** | Diagram generator (`mmdc`) | https://github.com/mermaid-js/mermaid-cli |

**Configuration:**

- **prettier**: Config at `.prettierrc` or `prettier.config.js` in project root. Neovim integrates via conform.nvim.
- **markdownlint-cli2**: Rules in `.markdownlint.yaml`. Disable rules inline: `<!-- markdownlint-disable MD013 -->`
- **mermaid-cli**: Generate diagrams: `mmdc -i input.mmd -o output.svg`

### Code Search

| Tool | Description | Documentation |
|------|-------------|---------------|
| **ast-grep** | AST-based code search | https://ast-grep.github.io/ |

Structural code search using AST patterns. More precise than regex for refactoring:

```bash
sg -p 'console.log($$$)' --lang js     # Find all console.log calls
sg -p 'function $NAME($$$) {}' --lang js  # Find function declarations
```

## Data Processing

| Tool | Description | Documentation |
|------|-------------|---------------|
| **jq** | JSON processor | https://jqlang.github.io/jq/ |
| **yq** | YAML processor (jq syntax) | https://github.com/mikefarah/yq |

No global configuration; use per-command options as needed.

**Common patterns:**

```bash
# jq
jq '.key' file.json           # Extract field
jq -r '.items[]' file.json    # Raw output, iterate array
cat file.json | jq -s '.'     # Slurp multiple JSON objects

# yq (uses jq-like syntax for YAML)
yq '.metadata.name' file.yaml
yq -i '.spec.replicas = 3' file.yaml  # In-place edit
```

## Command Runners

| Tool | Description | Documentation |
|------|-------------|---------------|
| **just** | Command runner | https://just.systems/ |
| **deno** | JS/TS runtime (formatting/linting) | https://deno.land/ |

**just:**

This repository uses `Justfile` at root for common tasks. Run `just --list` to see available recipes.

```bash
just lint    # Shell linting
just format  # Shell formatting
just check   # Check formatting
```

**deno:**

Used primarily for formatting and linting TypeScript/JavaScript. Neovim integrates via conform.nvim. Deno is also the runtime for denops.vim plugins.

## Runtimes & Environment

### Node.js

- **Docs**: https://nodejs.org/

Installs Node.js 22 LTS directly via Nix (required for Claude Code and MCP servers).

- No version manager required (single version managed by Nix)
- Node.js is available system-wide via Nix PATH
- Global tools should be installed via npm (`npm install -g <tool>`)
- Projects can use `.nvmrc` files for documentation purposes

**Version Management:**
- Update version in `home/dot_config/nix/home.nix` (e.g., `nodejs_22` -> `nodejs_24`)
- Run `home-manager switch` to apply changes

### direnv

- **Docs**: https://direnv.net/

Load and unload environment variables depending on the current directory.

Shell hook added in `~/.bashrc.d/150-direnv.sh`.

**Team Policy:**
- `.envrc` is per-project and versioned for the team
- Use only direnv stdlib and widely available tool commands (e.g., `uv`)
- See [envrc-examples.md](../templates/envrc-examples.md) for portable snippets

**Security:**
- `.envrc` must be explicitly allowed with `direnv allow`
- Changes to `.envrc` require re-approval
- Keep secrets out of VCS

## Python

### uv (Package Manager)

- **Docs**: https://github.com/astral-sh/uv

Fast Python package installer and virtual environment manager.

**direnv Integration:**
- Add `layout python_uv` to project `.envrc`, then `direnv allow`
- Python versions and venvs are managed per-project; no global Python enforced

### pyright (LSP)

- **Docs**: https://microsoft.github.io/pyright/
- **GitHub**: https://github.com/microsoft/pyright

Static type checker for Python with LSP support.

Automatically used by Neovim/LazyVim for Python files.

### ruff (Linter/Formatter)

- **Docs**: https://docs.astral.sh/ruff/
- **GitHub**: https://github.com/astral-sh/ruff

Fast Python linter and formatter (replaces flake8, black, isort).

```bash
ruff check .           # Lint
ruff format .          # Format
ruff check --fix .     # Auto-fix
```

Automatically used by Neovim/LazyVim for Python files.
