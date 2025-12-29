---
description: "Policy for non-interactive tool installation tests in CI/Docker environments. Defines required test levels and exception criteria."
alwaysApply: true
---

# Non-Interactive Tool Installation Test Policy

## Summary

This rule codifies expectations for validating tools installed via chezmoi in non-interactive contexts (e.g., Docker builds and CI pipelines). It ensures consistency, reproducibility, and early regression detection while minimizing noise and test maintenance costs.

## Principles

- Non-interactive tests MUST detect broken installations and regressions.
- Tests MUST be fast, deterministic, and avoid network dependencies.
- Interactive usability and detailed UX validation are out of scope.
- Tests SHOULD prioritize actionable failure signals with clear diagnostics.

## Test Levels

### 1. Level 1 — Smoke Tests (Required Default)

For each installed CLI tool:

- The tool MUST be discoverable in PATH (e.g., `command -v <tool>`).
- The tool MUST report a valid version or invocation status (e.g., `<tool> --version`).
- The tool SHOULD support a minimal help invocation (`<tool> --help`).

Smoke tests SHOULD be included for all CLI tools unless explicitly exempted.

### 2. Level 2 — Minimal Functional Tests

Apply when a tool's core value depends on configuration or integration:

- Include ONE representative positive behavior test.
- Tests MUST use deterministic input/output.
- Tests MUST avoid external services and network.
- Tests MUST complete quickly (target ~2 s or less).

Typical cases requiring Level 2:

- Tools that influence shell initialization or environment variables.
- Tools whose correct operation is prerequisite for other tools or pipelines.

### 3. Level 3 — Selective Integration Tests

Apply only for high-impact tool combinations where failure would break critical workflows:

- Scope to minimal success paths across dependent tools.
- Ensure tests do not degrade CI performance.
- Use sparingly and only when necessary for regression assurance.

## Level 0 — Explicit Exception

A tool MAY be exempt from non-interactive testing (Level 0) **only if all criteria below are satisfied**:

- Failure of the tool does not block core workflows.
- Failures are immediately obvious in interactive use.
- Automated tests add negligible regression detection value.
- Automated tests for the tool would be brittle or generate false positives.
- A justification for the exception is documented inline with the tool entry.

## Tools That MUST NOT Be Level 0

Tools MUST be tested at least at Level 1 when:

- They affect shell startup, PATH ordering, or environment setup.
- They are prerequisites for other automated steps.
- They are referenced in dotfiles logic, chezmoi conditionals, or automation scripts.
- Their absence can silently break pipelines or build processes.

## Implementation Requirements

- Smoke tests MUST be per-tool and independent of external services.
- Functional tests MUST produce clear error diagnostics on failure.
- Tests MUST include appropriate timeouts to prevent CI hangs.
- Tests SHOULD verify major or minor version ranges, not strict string matches.

## Documentation Expectations

- Exceptions (Level 0 tools) MUST include inline comments explaining the rationale.
- Tests and levels SHOULD be reviewed when tool usage changes.
- Tests SHOULD be upgraded if tool responsibilities evolve or dependencies increase.

## Test Design Constraints

- Avoid snapshot matching full CLI output; use exit codes or targeted patterns.
- Avoid reliance on network resources or variable external state.
- Keep the automated test suite minimal and stable, focused on regression detection.

## References

- [Testing Guide](../docs/testing-guide.md) - Detailed testing workflow and test types
- [Pre-Commit Checklist](../docs/pre-commit-checklist.md) - Verification workflow before commits

