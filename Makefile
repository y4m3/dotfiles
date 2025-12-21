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
.PHONY: build shell dev test test-shell clean-state

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

# test: Run all test suites
test: build
	$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && \
	           echo "Running all tests..." && \
	           failed=0; \
	           for test in tests/*-test.sh; do \
	               echo ""; \
	               if ! bash "$$test"; then failed=1; fi; \
	           done; \
	           exit $$failed'

# test-shell: Launch interactive shell with tests pre-applied
test-shell: build
	$(DOCKER_RUN_IT) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'bash scripts/apply-container.sh && \
	           echo "" && echo "Ready for testing. Run: bash tests/<name>-test.sh" && exec bash -l'

# clean-state: Remove persistent Docker volume for run_once state
# Use this when you want to force re-execution of all run_once_* scripts
# Example: After major system changes or for testing from scratch
clean-state:
	docker volume rm dotfiles-state cargo-data rustup-data || true
	@echo "✓ Persistent state cleared (dotfiles-state, cargo-data, rustup-data)."
	@echo "  Next 'make dev' or 'make test-*' will re-run all run_once_* scripts."
