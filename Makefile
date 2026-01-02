# Use bash as the shell for Makefile recipes (required for bash-specific features)
# This Makefile uses bash-specific features like:
# - `read -n` for non-blocking input
# - `[[` for conditional expressions
# - `PIPESTATUS` array for pipeline exit codes
# Note: This Makefile assumes bash is available at /bin/bash.
# If your system uses a different path, adjust accordingly.
SHELL := /bin/bash

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
# Note: Currently only Ubuntu 24.04 is supported. Platform-specific changes
# may be needed if support for other platforms is added in the future.
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
	@echo "=== Performance Measurement ==="
	@$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'export TEST_TYPE=changed; \
	           TEST_LOG_DIR="$${XDG_CACHE_HOME:-$$HOME/.cache}/test-logs"; \
	           mkdir -p "$$TEST_LOG_DIR"; \
	           TEST_LOG_FILE="$$TEST_LOG_DIR/test-$$(date +%Y%m%d-%H%M%S).log"; \
	           echo "Test log file: $$TEST_LOG_FILE"; \
	           echo "[$$(date +%H:%M:%S)] Starting apply-container.sh..." | tee -a "$$TEST_LOG_FILE"; \
	           APPLY_START=$$(date +%s); \
	           bash scripts/apply-container.sh >> "$$TEST_LOG_FILE" 2>&1; \
	           APPLY_STATUS=$$?; \
	           APPLY_END=$$(date +%s); \
	           APPLY_DURATION=$$((APPLY_END - APPLY_START)); \
	           if [ "$$APPLY_STATUS" -eq 0 ]; then \
	             echo "[$$(date +%H:%M:%S)] apply-container.sh completed in $$APPLY_DURATION seconds" | tee -a "$$TEST_LOG_FILE"; \
	           else \
	             echo "[$$(date +%H:%M:%S)] apply-container.sh failed after $$APPLY_DURATION seconds (exit $$APPLY_STATUS)" | tee -a "$$TEST_LOG_FILE"; \
	             exit $$APPLY_STATUS; \
	           fi; \
	           [ -f ~/.bashrc ] && source ~/.bashrc; \
	           TESTS_START=$$(date +%s); \
	           tests_to_run=$$(bash scripts/detect-changes.sh); \
	           if [ -z "$$tests_to_run" ]; then \
	             echo "No changes detected, running all tests..." | tee -a "$$TEST_LOG_FILE"; \
	             failed=0; \
	             warn_count=0; \
	             fail_count=0; \
	             for test in tests/*-test.sh; do \
	                 echo "" | tee -a "$$TEST_LOG_FILE"; \
	                 test_name=$$(basename "$$test"); \
	                 test_log="$$TEST_LOG_DIR/$$test_name-$$(date +%Y%m%d-%H%M%S).log"; \
	                 export TEST_LOG_FILE="$$test_log"; \
	                 TEST_START=$$(date +%s); \
	                 echo "[$$(date +%H:%M:%S)] Running $$test_name (log: $$test_log)..." | tee -a "$$TEST_LOG_FILE"; \
	                 bash "$$test" 2>&1 | tee -a "$$TEST_LOG_FILE"; \
	                 test_exit=$${PIPESTATUS[0]}; \
	                 TEST_END=$$(date +%s); \
	                 TEST_DURATION=$$((TEST_END - TEST_START)); \
	                 echo "[$$(date +%H:%M:%S)] $$test_name completed in $$TEST_DURATION seconds" | tee -a "$$TEST_LOG_FILE"; \
	                 if [ $$test_exit -ne 0 ]; then \
	                     failed=1; \
	                 fi; \
	                 # Count WARN and FAIL in log file \
	                 test_warn=0; \
	                 test_fail=0; \
	                 if [ -f "$$test_log" ]; then \
	                     # Use awk to count lines (more reliable than grep -c with newlines) \
	                     test_warn=$$(awk "/^\\[.*\\] WARN:/ {count++} END {print count+0}" "$$test_log" 2>/dev/null || echo "0" | tr -d '\n'); \
	                     test_fail=$$(awk "/^\\[.*\\] FAIL:/ {count++} END {print count+0}" "$$test_log" 2>/dev/null || echo "0" | tr -d '\n'); \
	                     # Ensure numeric values and remove any newlines \
	                     test_warn=$$(echo "$$test_warn" | tr -d '\n'); \
	                     test_fail=$$(echo "$$test_fail" | tr -d '\n'); \
	                     if [ -z "$$test_warn" ] || ! [ "$$test_warn" -ge 0 ] 2>/dev/null; then test_warn=0; fi; \
	                     if [ -z "$$test_fail" ] || ! [ "$$test_fail" -ge 0 ] 2>/dev/null; then test_fail=0; fi; \
	                 fi; \
	                 warn_count=$$((warn_count + test_warn)); \
	                 fail_count=$$((fail_count + test_fail)); \
	             done; \
	             TESTS_END=$$(date +%s); \
	             TESTS_DURATION=$$((TESTS_END - TESTS_START)); \
	             echo "[$$(date +%H:%M:%S)] All tests completed in $$TESTS_DURATION seconds" | tee -a "$$TEST_LOG_FILE"; \
	             echo ""; \
	             echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	             echo "Overall Test Results:" | tee -a "$$TEST_LOG_FILE"; \
	             echo "  Total WARN: $$warn_count" | tee -a "$$TEST_LOG_FILE"; \
	             echo "  Total FAIL: $$fail_count" | tee -a "$$TEST_LOG_FILE"; \
	             echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	             if [ $$fail_count -gt 0 ] || [ $$warn_count -gt 0 ]; then \
	                 exit 1; \
	             else \
	                 exit 0; \
	             fi; \
	           else \
	             echo "Running affected tests: $$tests_to_run" | tee -a "$$TEST_LOG_FILE"; \
	             failed=0; \
	             warn_count=0; \
	             fail_count=0; \
	             for test in $$tests_to_run; do \
	                 echo "" | tee -a "$$TEST_LOG_FILE"; \
	                 test_name=$$(basename "$$test"); \
	                 test_log="$$TEST_LOG_DIR/$$test_name-$$(date +%Y%m%d-%H%M%S).log"; \
	                 export TEST_LOG_FILE="$$test_log"; \
	                 TEST_START=$$(date +%s); \
	                 echo "[$$(date +%H:%M:%S)] Running $$test_name (log: $$test_log)..." | tee -a "$$TEST_LOG_FILE"; \
	                 bash "$$test" 2>&1 | tee -a "$$TEST_LOG_FILE"; \
	                 test_exit=$${PIPESTATUS[0]}; \
	                 TEST_END=$$(date +%s); \
	                 TEST_DURATION=$$((TEST_END - TEST_START)); \
	                 echo "[$$(date +%H:%M:%S)] $$test_name completed in $$TEST_DURATION seconds" | tee -a "$$TEST_LOG_FILE"; \
	                 if [ $$test_exit -ne 0 ]; then \
	                     failed=1; \
	                 fi; \
	                 # Count WARN and FAIL in log file \
	                 test_warn=0; \
	                 test_fail=0; \
	                 if [ -f "$$test_log" ]; then \
	                     # Use awk to count lines (more reliable than grep -c with newlines) \
	                     test_warn=$$(awk "/^\\[.*\\] WARN:/ {count++} END {print count+0}" "$$test_log" 2>/dev/null || echo "0" | tr -d '\n'); \
	                     test_fail=$$(awk "/^\\[.*\\] FAIL:/ {count++} END {print count+0}" "$$test_log" 2>/dev/null || echo "0" | tr -d '\n'); \
	                     # Ensure numeric values and remove any newlines \
	                     test_warn=$$(echo "$$test_warn" | tr -d '\n'); \
	                     test_fail=$$(echo "$$test_fail" | tr -d '\n'); \
	                     if [ -z "$$test_warn" ] || ! [ "$$test_warn" -ge 0 ] 2>/dev/null; then test_warn=0; fi; \
	                     if [ -z "$$test_fail" ] || ! [ "$$test_fail" -ge 0 ] 2>/dev/null; then test_fail=0; fi; \
	                 fi; \
	                 warn_count=$$((warn_count + test_warn)); \
	                 fail_count=$$((fail_count + test_fail)); \
	             done; \
	             TESTS_END=$$(date +%s); \
	             TESTS_DURATION=$$((TESTS_END - TESTS_START)); \
	             echo "[$$(date +%H:%M:%S)] Affected tests completed in $$TESTS_DURATION seconds" | tee -a "$$TEST_LOG_FILE"; \
	             echo ""; \
	             echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	             echo "Overall Test Results:" | tee -a "$$TEST_LOG_FILE"; \
	             echo "  Total WARN: $$warn_count" | tee -a "$$TEST_LOG_FILE"; \
	             echo "  Total FAIL: $$fail_count" | tee -a "$$TEST_LOG_FILE"; \
	             echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	             if [ $$fail_count -gt 0 ] || [ $$warn_count -gt 0 ]; then \
	                 exit 1; \
	             else \
	                 exit 0; \
	             fi; \
	           fi'

# test-all: Run all test suites and create snapshot on success
# Runs all tests regardless of changes. Creates snapshot on success.
# Usage: make test-all [BASELINE=1]
#   BASELINE=1: Save results as baseline after successful tests
test-all: build
	@$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'export TEST_TYPE=all; \
	           TEST_LOG_DIR="$${XDG_CACHE_HOME:-$$HOME/.cache}/test-logs"; \
	           mkdir -p "$$TEST_LOG_DIR"; \
	           TEST_LOG_FILE="$$TEST_LOG_DIR/test-all-$$(date +%Y%m%d-%H%M%S).log"; \
	           echo "Test log file: $$TEST_LOG_FILE"; \
	           bash scripts/apply-container.sh && \
	           echo "Running all tests..." && \
	           failed=0; \
	           warn_count=0; \
	           fail_count=0; \
	           for test in tests/*-test.sh; do \
	               echo ""; \
	               test_name=$$(basename "$$test"); \
	               test_log="$$TEST_LOG_DIR/$$test_name-$$(date +%Y%m%d-%H%M%S).log"; \
	               export TEST_LOG_FILE="$$test_log"; \
	               echo "Running $$test_name (log: $$test_log)..." | tee -a "$$TEST_LOG_FILE"; \
	               bash "$$test" 2>&1 | tee -a "$$TEST_LOG_FILE"; \
	               test_exit=$${PIPESTATUS[0]}; \
	               if [ $$test_exit -ne 0 ]; then \
	                   failed=1; \
	               fi; \
	               # Count WARN and FAIL in log file \
	               test_warn=$$(grep -c "^\[.*\] WARN:" "$$test_log" 2>/dev/null || echo "0"); \
	               test_fail=$$(grep -c "^\[.*\] FAIL:" "$$test_log" 2>/dev/null || echo "0"); \
	               # Remove any newlines and ensure numeric values before arithmetic \
	               test_warn=$$(echo "$$test_warn" | tr -d '\n\r' | grep -E '^[0-9]+$$' || echo "0"); \
	               test_fail=$$(echo "$$test_fail" | tr -d '\n\r' | grep -E '^[0-9]+$$' || echo "0"); \
	               # Ensure values are numeric (default to 0 if empty or invalid) \
	               if [ -z "$$test_warn" ] || ! [ "$$test_warn" -ge 0 ] 2>/dev/null; then test_warn=0; fi; \
	               if [ -z "$$test_fail" ] || ! [ "$$test_fail" -ge 0 ] 2>/dev/null; then test_fail=0; fi; \
	               warn_count=$$((warn_count + test_warn)); \
	               fail_count=$$((fail_count + test_fail)); \
	           done; \
	           echo ""; \
	           echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	           echo "Overall Test Results:" | tee -a "$$TEST_LOG_FILE"; \
	           echo "  Total WARN: $$warn_count" | tee -a "$$TEST_LOG_FILE"; \
	           echo "  Total FAIL: $$fail_count" | tee -a "$$TEST_LOG_FILE"; \
	           echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	           if [ $$fail_count -eq 0 ] && [ $$warn_count -eq 0 ]; then \
	               echo ""; \
	               echo "==> All tests passed (No FAIL, No WARN). Creating environment snapshot..." | tee -a "$$TEST_LOG_FILE"; \
	               bash scripts/create-snapshot.sh; \
	               if [ "$(BASELINE)" = "1" ]; then \
	                   echo ""; \
	                   echo "==> Saving baseline test results..." | tee -a "$$TEST_LOG_FILE"; \
	                   bash scripts/record-test-results.sh --baseline; \
	               fi; \
	           else \
	               echo "==> Tests completed with issues (WARN: $$warn_count, FAIL: $$fail_count)" | tee -a "$$TEST_LOG_FILE"; \
	               echo "==> Check log files in $$TEST_LOG_DIR for details" | tee -a "$$TEST_LOG_FILE"; \
	           fi; \
	           if [ $$fail_count -gt 0 ] || [ $$warn_count -gt 0 ]; then \
	               exit 1; \
	           else \
	               exit 0; \
	           fi'

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
			volume_errors=0; \
			for vol in dotfiles-state cargo-data rustup-data env-snapshot; do \
				if docker volume inspect "$$vol" >/dev/null 2>&1; then \
					error_msg=$$(docker volume rm "$$vol" 2>&1); \
					exit_code=$$?; \
					if [ $$exit_code -ne 0 ]; then \
						if echo "$$error_msg" | grep -q "no such volume"; then \
							:; \
						elif echo "$$error_msg" | grep -qE "(in use|cannot connect|permission denied|Error response)"; then \
							echo "Error: Failed to remove volume $$vol" >&2; \
							echo "$$error_msg" >&2; \
							volume_errors=1; \
						fi; \
					fi; \
				fi; \
			done; \
			if [ $$volume_errors -eq 0 ]; then \
				echo "✓ Volumes cleared. Rebuilding environment A..."; \
				$(MAKE) test-all; \
			else \
				echo "Error: Some volumes could not be removed. Please stop any running containers first." >&2; \
				exit 1; \
			fi; \
		else \
			echo "Cancelled."; \
		fi; \
	else \
		echo "==> Removing persistent volumes..."; \
		volume_errors=0; \
		for vol in dotfiles-state cargo-data rustup-data env-snapshot; do \
			if docker volume inspect "$$vol" >/dev/null 2>&1; then \
				error_msg=$$(docker volume rm "$$vol" 2>&1); \
				exit_code=$$?; \
				if [ $$exit_code -ne 0 ]; then \
					if echo "$$error_msg" | grep -q "no such volume"; then \
						:; \
					elif echo "$$error_msg" | grep -qE "(in use|cannot connect|permission denied|Error response)"; then \
						echo "Error: Failed to remove volume $$vol" >&2; \
						echo "$$error_msg" >&2; \
						volume_errors=1; \
					fi; \
				fi; \
			fi; \
		done; \
		if [ $$volume_errors -eq 0 ]; then \
			echo "✓ Persistent state cleared (dotfiles-state, cargo-data, rustup-data, env-snapshot)."; \
			echo "  Next 'make dev' or 'make test' will rebuild the environment."; \
		else \
			echo "Error: Some volumes could not be removed. Please stop any running containers first." >&2; \
			exit 1; \
		fi; \
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
