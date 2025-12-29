# Docker image name and tag (customizable via: make IMAGE=custom-tag build)
IMAGE ?= dotfiles-test:ubuntu24.04
IMAGE_LINT ?= dotfiles-lint:latest

# Container working directory path (source code mounted at this location inside container)
WORKDIR := /workspace

# Volume mount definitions for persistent state
VOLUME_DOTFILES := -v dotfiles-state:/root/.config/chezmoi
VOLUME_CARGO := -v cargo-data:/root/.cargo
VOLUME_RUSTUP := -v rustup-data:/root/.rustup
VOLUME_SNAPSHOT := -v env-snapshot:/root/.local/share/env-snapshot
# Mount gh config from host if available (for GitHub API authentication)
# Use $$HOME to reference shell variable, not Make variable
VOLUME_GH := $(shell test -d ~/.config/gh && echo "-v $$HOME/.config/gh:/root/.config/gh:ro" || echo "")
VOLUMES_MINIMAL := $(VOLUME_DOTFILES)
VOLUMES_FULL := $(VOLUME_DOTFILES) $(VOLUME_CARGO) $(VOLUME_RUSTUP) $(VOLUME_SNAPSHOT) $(VOLUME_GH)

# Get GitHub token from host if gh is available
# This allows authenticated GitHub API requests in Docker (5000/hour vs 60/hour unauthenticated)
GITHUB_TOKEN := $(shell command -v gh >/dev/null 2>&1 && gh auth token 2>/dev/null || echo "")

# Common docker run base command
DOCKER_RUN_BASE := docker run --rm -v "$(PWD):$(WORKDIR)" -w $(WORKDIR) $(if $(GITHUB_TOKEN),-e GITHUB_TOKEN="$(GITHUB_TOKEN)",)
DOCKER_RUN_IT := $(DOCKER_RUN_BASE) -it
DOCKER_RUN_BASE_USER := $(DOCKER_RUN_BASE) -u $(shell id -u):$(shell id -g)

# Declare phony targets (not file-based; always execute when invoked)
.PHONY: build dev test test-all clean reset build-lint lint format 

# build: Construct Docker image from Dockerfile
# Creates a Docker image containing Ubuntu 24.04, essential tools (git, curl),
# bash-completion, locales, and pre-installed chezmoi.
# This is a prerequisite for all other targets.
build: Dockerfile
	docker build -t $(IMAGE) .
# dev: Initialize chezmoi and launch interactive shell
# Applies dotfiles configuration and drops into a login shell for manual testing
dev: build
	$(DOCKER_RUN_IT) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'if bash scripts/apply-container.sh; then exec bash -l; else echo "Error: Failed to apply configuration" >&2; exit 1; fi'

# test: Change detection test (default, frequently used)
# Runs tests for changed files only. If no changes detected, runs all tests.
test: build
	@$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'export TEST_TYPE=changed; \
	           bash scripts/apply-container.sh > /dev/null 2>&1 && \
	           tests_to_run=$$(bash scripts/detect-changes.sh); \
	           if [ -z "$$tests_to_run" ]; then \
	             echo "No changes detected, running all tests..."; \
	             failed=0; \
	             for test in tests/*-test.sh; do \
	                 echo ""; \
	                 if ! bash "$$test"; then failed=1; fi; \
	             done; \
	             exit $$failed; \
	           else \
	             echo "Running affected tests: $$tests_to_run"; \
	             failed=0; \
	             for test in $$tests_to_run; do \
	                 echo ""; \
	                 if ! bash "$$test"; then failed=1; fi; \
	             done; \
	             exit $$failed; \
	           fi'

# test-all: Run all test suites and create snapshot on success
# Runs all tests regardless of changes. Creates snapshot on success.
# Usage: make test-all [BASELINE=1]
#   BASELINE=1: Save results as baseline after successful tests
test-all: build
	@$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'export TEST_TYPE=all; \
	           bash scripts/apply-container.sh && \
	           echo "Running all tests..." && \
	           failed=0; \
	           for test in tests/*-test.sh; do \
	               echo ""; \
	               if ! bash "$$test"; then failed=1; fi; \
	           done; \
	           if [ $$failed -eq 0 ]; then \
	               echo ""; \
	               echo "==> All tests passed. Creating environment snapshot..."; \
	               bash scripts/create-snapshot.sh; \
	               if [ "$(BASELINE)" = "1" ]; then \
	                   echo ""; \
	                   echo "==> Saving baseline test results..."; \
	                   bash scripts/record-test-results.sh --baseline; \
	               fi; \
	           fi; \
	           exit $$failed'

# clean: Remove persistent Docker volumes
# Usage: make clean [REBUILD=1]
#   REBUILD=1: Rebuild environment after cleaning (runs test-all)
clean:
	@if [ "$(REBUILD)" = "1" ]; then \
		echo "==> Performing complete reset and rebuild..."; \
		echo "  This will remove all persistent volumes and rebuild environment A."; \
		read -p "Are you sure? [y/N] " -n 1 -r; \
		echo; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			docker volume rm dotfiles-state cargo-data rustup-data env-snapshot || true; \
			echo "✓ Volumes cleared. Rebuilding environment A..."; \
			$(MAKE) test-all; \
		else \
			echo "Cancelled."; \
		fi; \
	else \
		echo "==> Removing persistent volumes..."; \
		docker volume rm dotfiles-state cargo-data rustup-data env-snapshot || true; \
		echo "✓ Persistent state cleared (dotfiles-state, cargo-data, rustup-data, env-snapshot)."; \
		echo "  Next 'make dev' or 'make test' will rebuild the environment."; \
	fi

# reset: Reset manual installations while preserving chezmoi state
# Compares current state with snapshot and removes manually installed tools
reset: build
	@echo "==> Resetting manual installations..."
	@echo "  This will remove manually installed tools while preserving chezmoi state."
	@$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/reset-manual-installs.sh'
	@echo "✓ Manual installations reset. Next 'make dev' will restore state A."

# build-lint: Build lightweight Docker image for linting/formatting
build-lint: Dockerfile.lint
	docker build -t $(IMAGE_LINT) -f Dockerfile.lint .

# lint: Run shellcheck on all shell scripts
# Fast execution using lightweight lint-only Docker image
# Excludes SC1090/SC1091 (dynamic source files)
lint: build-lint
	@echo "==> Running shellcheck on all shell scripts..."
	@$(DOCKER_RUN_BASE_USER) $(IMAGE_LINT) \
	  shellcheck -e SC1090,SC1091 \
	             home/run_once_*.sh.tmpl \
	             home/dot_bashrc.d/*.sh \
	             home/dot_bash_prompt.d/*.sh \
	             scripts/*.sh \
	             tests/*.sh tests/lib/*.sh
	@echo "✓ All shell scripts passed shellcheck"

# format: Format all shell scripts with shfmt
# Fast execution using lightweight lint-only Docker image
# Reads .editorconfig for indent settings
format: build-lint
	@echo "==> Formatting shell scripts with shfmt..."
	@$(DOCKER_RUN_BASE_USER) $(IMAGE_LINT) \
	  shfmt -w home/run_once_*.sh.tmpl \
	           home/dot_bashrc.d/*.sh \
	           home/dot_bash_prompt.d/*.sh \
	           scripts/*.sh \
	           tests/*.sh tests/lib/*.sh
	@echo "✓ Shell scripts formatted"
	@echo "  Next 'make dev' or 'make test' will re-run all run_once_* scripts."
