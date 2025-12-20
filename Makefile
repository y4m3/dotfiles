# Docker image name and tag (customizable via: make IMAGE=custom-tag build)
IMAGE ?= dotfiles-test:ubuntu24.04

# Container working directory path (source code mounted at this location inside container)
WORKDIR := /workspace

# Volume mount definitions for persistent state
VOLUME_DOTFILES := -v dotfiles-state:/root/.config/chezmoi
VOLUME_CARGO := -v cargo-data:/root/.cargo
VOLUME_RUSTUP := -v rustup-data:/root/.rustup
VOLUMES_MINIMAL := $(VOLUME_DOTFILES)
VOLUMES_FULL := $(VOLUME_DOTFILES) $(VOLUME_CARGO) $(VOLUME_RUSTUP)

# Common docker run base command
DOCKER_RUN_BASE := docker run --rm -v "$(PWD):$(WORKDIR)" -w $(WORKDIR)
DOCKER_RUN_IT := $(DOCKER_RUN_BASE) -it

# Declare phony targets (not file-based; always execute when invoked)
.PHONY: build shell dev test test-cargo test-bash test-all test-quick-cargo test-quick-bash test-shell clean-state

# build: Construct Docker image from Dockerfile
# Creates a Docker image containing Ubuntu 24.04, essential tools (git, curl),
# bash-completion, locales, and pre-installed chezmoi.
# This is a prerequisite for all other targets.
build: Dockerfile
	docker build -t $(IMAGE) .
# shell: Launch interactive bash shell in a clean container
shell: build
	$(DOCKER_RUN_IT) $(IMAGE) bash

# dev: Initialize chezmoi and launch interactive shell
# Applies dotfiles configuration and drops into a login shell for manual testing
dev: build
	$(DOCKER_RUN_IT) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && exec bash -l'

# test: Complete testing pipeline including smoke tests
# This target executes the full automated testing workflow:
# 1. chezmoi init: Initialize chezmoi using mounted source directory
# 2. chezmoi apply: Deploy configuration to container root home directory with --force flag
# 3. bash scripts/test-bash.sh: Execute automated smoke tests to verify configuration
# Tests validate: PATH setup, UTF-8 locale, bash-completion availability,
# prompt file deployment, and terminal color support.
# Use this target to validate all changes before deploying to actual systems.
test: build
	docker run --rm -v "$(PWD):$(WORKDIR)" -w $(WORKDIR) $(IMAGE) \
	  bash -lc 'chezmoi init --source=$(WORKDIR) --destination=/root && \
	           chezmoi apply --source=$(WORKDIR) --destination=/root --force && \
	           bash scripts/test-bash.sh'

# test-cargo: Test Rust/Cargo installation and configuration
test-cargo: build
	$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && bash tests/cargo-test.sh'

# test-bash: Test bash configuration and environment
test-bash: build
	$(DOCKER_RUN_BASE) $(VOLUMES_MINIMAL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && bash tests/bash-config-test.sh'

# test-all: Run all test suites
test-all: build
	$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && \
	           echo "Running all tests..." && \
	           for test in tests/*-test.sh; do echo ""; bash "$$test"; done'

# test-quick-cargo: Fast Cargo test using persistent state (2nd run ~5-10s)
test-quick-cargo: build
	$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && bash tests/cargo-test.sh'

# test-quick-bash: Fast bash config test using persistent state (2nd run ~5-10s)
test-quick-bash: build
	$(DOCKER_RUN_BASE) $(VOLUMES_MINIMAL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && bash tests/bash-config-test.sh'

# test-shell: Launch interactive shell with tests pre-applied
test-shell: build
	$(DOCKER_RUN_IT) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && \
	           echo "" && echo "Ready for testing. Run: bash tests/cargo-test.sh" && exec bash -l'

# clean-state: Remove persistent Docker volume for run_once state
# Use this when you want to force re-execution of all run_once_* scripts
# Example: After major system changes or for testing from scratch
clean-state:
	docker volume rm dotfiles-state cargo-data rustup-data || true
	@echo "✓ Persistent state cleared (dotfiles-state, cargo-data, rustup-data)."
	@echo "  Next 'make dev' or 'make test-*' will re-run all run_once_* scripts."
