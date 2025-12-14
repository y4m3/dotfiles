# Docker image name and tag (customizable via: make IMAGE=custom-tag build)
IMAGE ?= dotfiles-test:ubuntu24.04

# Container working directory path (source code mounted at this location inside container)
WORKDIR := /workspace

# Declare phony targets (not file-based; always execute when invoked)
.PHONY: build shell dev test

# build: Construct Docker image from Dockerfile
# Creates a Docker image containing Ubuntu 24.04, essential tools (git, curl),
# bash-completion, locales, and pre-installed chezmoi.
# This is a prerequisite for all other targets.
build: Dockerfile
	docker build -t $(IMAGE) .
# shell: Launch interactive bash shell in a clean container
# Mounts the current directory as /workspace inside the container.
# Use this target for manual exploration and manual testing without applying configurations.
# Useful for debugging and understanding the test environment.
shell: build
	docker run --rm -it -v "$(PWD):$(WORKDIR)" -w $(WORKDIR) $(IMAGE) bash

# dev: Initialize chezmoi and launch an interactive shell for testing
# This target executes the following sequence:
# 1. Runs scripts/apply-container.sh (which calls chezmoi init and apply)
# 2. Launches an interactive login shell for manual verification
# Use this target to verify the applied bash configuration and test interactively.
dev: build
	docker run --rm -it -v "$(PWD):$(WORKDIR)" -w $(WORKDIR) $(IMAGE) \
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
	docker run --rm -it -v "$(PWD):$(WORKDIR)" -w $(WORKDIR) $(IMAGE) \
	  bash -lc 'chezmoi init --source=$(WORKDIR) --destination=/root && \
	           chezmoi apply --source=$(WORKDIR) --destination=/root --force && \
	           bash scripts/test-bash.sh'
