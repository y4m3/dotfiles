---
description: "Documentation standards for this repository. Delegate general usage to official docs, focus on project-specific customizations, English only, generalize examples."
globs:
  - "docs/**/*.md"
  - "README.md"
---

# Documentation Standards

## Core Principles

1. **Delegate to official documentation**: General usage instructions should link to official sources
2. **Focus on project-specific**: Document only repository-specific customizations and configurations
3. **English only**: All documentation MUST be in English (no Japanese)
4. **Generalize examples**: Avoid specific numbers, file names, or user-specific values

## Delegate to Official Documentation

**REQUIRED**: Link to official documentation for general usage

Instead of documenting general tool usage, link to official sources:

```markdown
## Official Documentation

- [Tool Name Documentation](https://official-docs-url)
- [Tool Name GitHub](https://github.com/owner/repo)
```

**Example** (from `docs/tools/chezmoi.md`):
```markdown
## Official Documentation

- [chezmoi.io](https://www.chezmoi.io/)
- [chezmoi GitHub repository](https://github.com/twpayne/chezmoi)

## Installation

This repository includes automated installation via `run_once_010-chezmoi.sh.tmpl`. 
For detailed installation instructions, refer to the [official chezmoi documentation](https://www.chezmoi.io/install/).
```

## Project-Specific Content

**REQUIRED**: Document only repository-specific customizations

Focus on:
- How the tool is installed in this repository (which `run_once` script)
- Repository-specific configuration files and their locations
- Custom environment variables or settings
- Integration with other tools in this repository

**Example** (from `docs/tools/zoxide.md`):
```markdown
## Environment-specific Configuration

- Provides `j` command instead of `z` (defined in shell initialization)
- Optional auto `ls` enabled via `ENABLE_CD_LS=1` in `.bashrc.local`
- Exclusion paths and display behavior controlled by environment variables

This setting is implemented in `60-utils.sh` and wraps the normal `cd` command.
```

## English Only

**REQUIRED**: All documentation MUST be in English

- No Japanese text in documentation files
- No Japanese comments in code examples
- Exception: `dev_memo/` directory (development notes, can contain Japanese)

**Rationale**: This is a public repository; English ensures broader accessibility.

## Generalize Examples

**REQUIRED**: Avoid specific numbers, file names, or user-specific values

**Bad**:
```markdown
# Example
cd /home/user/projects/my-project
git commit -m "feat: add feature"
```

**Good**:
```markdown
# Example
cd /path/to/project
git commit -m "feat: add feature"
```

**Bad**:
```markdown
# Configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --line-range :500 {}"'
```

**Good**:
```markdown
# Configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
```

## Documentation Structure

### Tool-Specific Documentation (`docs/tools/*.md`)

**REQUIRED**: Follow this structure

```markdown
# Tool Name

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

- [Official Documentation URL](https://...)
- [GitHub Repository](https://github.com/...)

## Installation

- Managed by `run_once_XXX-category-toolname.sh.tmpl`
- Installs to `~/.local/bin/toolname` (or other location)

## Environment-specific Configuration

- Repository-specific settings
- Custom environment variables
- Integration with other tools

## Troubleshooting

- Repository-specific issues only
- Link to official troubleshooting for general issues
```

### Main Documentation (`docs/*.md`)

**REQUIRED**: Focus on repository workflows and policies

- `README.md`: Quick start, main targets, directory structure
- `docs/configuration.md`: Configuration policy and customization methods
- `docs/testing-guide.md`: Testing system and change detection
- `docs/troubleshooting.md`: Common issues and solutions
- `docs/pre-commit-checklist.md`: Verification workflow before commits

## Remove Redundant Content

**REQUIRED**: Remove content that duplicates official documentation

**Remove**:
- General usage instructions
- Common command examples (unless repository-specific)
- Detailed keybinding lists (link to official docs instead)
- Generic troubleshooting (link to official docs instead)

**Keep**:
- Repository-specific installation methods
- Custom configuration files and their locations
- Integration with other repository tools
- Project-specific workflows

## Code Examples

**REQUIRED**: Use generic paths and values

```markdown
# Good: Generic example
export PATH="$HOME/.local/bin:$PATH"

# Bad: Specific user path
export PATH="/home/john/.local/bin:$PATH"
```

**REQUIRED**: Include context for repository-specific examples

```markdown
# Repository-specific: zoxide provides 'j' command instead of 'z'
# Configured in ~/.bashrc.d/60-utils.sh
j() {
  # Implementation
}
```

## References

**REQUIRED**: Link to related repository documentation

```markdown
## References

- [Configuration Guide](../docs/configuration.md) - Configuration policy
- [Testing Guide](../docs/testing-guide.md) - Testing workflow
- [Tool Name Official Docs](https://...) - General usage
```

## Checklist for New Documentation

When creating or updating documentation:

- [ ] Links to official documentation for general usage
- [ ] Focuses on repository-specific customizations only
- [ ] All text is in English
- [ ] Examples use generic paths/values
- [ ] No redundant content that duplicates official docs
- [ ] References to related repository documentation included

## References

- [Configuration Guide](../docs/configuration.md) - Configuration policy
- [Testing Guide](../docs/testing-guide.md) - Testing workflow
- Existing tool documentation: `docs/tools/*.md` (examples of simplified documentation)

