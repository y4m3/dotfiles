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
VOLUME_VIM := -v vim-data:/root/.vim
VOLUME_LOCAL_BIN := -v local-bin-data:/root/.local/bin
VOLUME_FZF := -v fzf-data:/root/.fzf
VOLUME_FNM := -v fnm-data:/root/.local/share/fnm
# Mount gh config from host if available (for GitHub API authentication)
# Use $$HOME to reference shell variable, not Make variable
VOLUME_GH := $(shell test -d ~/.config/gh && echo "-v $$HOME/.config/gh:/root/.config/gh:ro" || echo "")
VOLUMES_MINIMAL := $(VOLUME_DOTFILES)
VOLUMES_FULL := $(VOLUME_DOTFILES) $(VOLUME_CARGO) $(VOLUME_RUSTUP) $(VOLUME_SNAPSHOT) $(VOLUME_VIM) $(VOLUME_LOCAL_BIN) $(VOLUME_FZF) $(VOLUME_FNM) $(VOLUME_GH)

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
# Exit code 130 (SIGINT) from exit command is treated as success
dev: build
	$(DOCKER_RUN_IT) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'if bash scripts/apply-container.sh; then exec bash -l; else echo "Error: Failed to apply configuration" >&2; exit 1; fi' || \
	  ([ $$? -eq 130 ] && exit 0 || exit $$?)

# test: Change detection test (default, frequently used)
# Runs tests for changed files only. If no changes detected, runs all tests.
test: build
	@echo "=== Performance Measurement ==="
	@$(DOCKER_RUN_BASE) $(VOLUMES_FULL) $(IMAGE) \
	  bash -lc 'export TEST_TYPE=changed; \
	           TEST_LOG_DIR="$${XDG_CACHE_HOME:-$$HOME/.cache}/test-logs"; \
	           mkdir -p "$$TEST_LOG_DIR"; \
	           TEST_LOG_FILE="$$TEST_LOG_DIR/test-$$(date +%Y%m%d-%H%M%S).log"; \
	           TEST_RESULTS_JSONL="$$TEST_LOG_DIR/results-$$(date +%Y%m%d-%H%M%S).jsonl"; \
	           export TEST_RESULTS_JSONL; \
	           : > "$$TEST_RESULTS_JSONL"; \
	           echo "Test log file: $$TEST_LOG_FILE"; \
	           echo "Test results file: $$TEST_RESULTS_JSONL"; \
	           echo "[$$(date +%H:%M:%S)] Starting apply-container.sh..." | tee -a "$$TEST_LOG_FILE"; \
	           APPLY_START=$$(date +%s); \
	           bash scripts/apply-container.sh >> "$$TEST_LOG_FILE" 2>&1; \
	           APPLY_STATUS=$$?; \
	           APPLY_END=$$(date +%s); \
	           APPLY_DURATION=$$((APPLY_END - APPLY_START)); \
	           if [ "$$APPLY_STATUS" -eq 0 ]; then \
	             echo "[$$(date +%H:%M:%S)] apply-container.sh completed in $$APPLY_DURATION seconds" | tee -a "$$TEST_LOG_FILE"; \
	             export PATH="$$HOME/.local/bin:$$HOME/.cargo/bin:$$PATH"; \
	             FNM_PATH="$$HOME/.local/share/fnm"; \
	             if [ -x "$$FNM_PATH/fnm" ]; then export PATH="$$FNM_PATH:$$PATH"; eval "$$($$FNM_PATH/fnm env)"; fi; \
	           else \
	             echo "[$$(date +%H:%M:%S)] apply-container.sh failed after $$APPLY_DURATION seconds (exit $$APPLY_STATUS)" | tee -a "$$TEST_LOG_FILE"; \
	             exit $$APPLY_STATUS; \
	           fi; \
	           TESTS_START=$$(date +%s); \
	           tests_to_run=$$(bash scripts/detect-changes.sh); \
	           if [ -z "$$tests_to_run" ]; then \
	             echo "No changes detected, running all tests..." | tee -a "$$TEST_LOG_FILE"; \
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
	                 status="pass"; \
	                 if [ $$test_exit -ne 0 ]; then \
	                     fail_count=$$((fail_count + 1)); \
	                     status="fail"; \
	                 fi; \
	                 # Count WARN in log file (WARN is non-fatal) \
	                 test_warn=0; \
	                 if [ -f "$$test_log" ]; then \
	                     test_warn=$$(awk "/^\\[TEST\\] WARN:/ {count++} END {print count+0}" "$$test_log" 2>/dev/null | tr -d "\n\r"); \
	                     test_warn=$$(echo "$$test_warn" | tr -d "\n\r" | grep -E "^[0-9]+$$" || echo "0"); \
	                 fi; \
	                 warn_count=$$((warn_count + test_warn)); \
	                 jq -n --arg name "$$test_name" --arg status "$$status" --arg log_file "$$test_log" \
	                   --argjson duration_seconds "$$TEST_DURATION" --argjson warn_count "$$test_warn" \
	                   '\''{name:$$name,status:$$status,duration_seconds:$$duration_seconds,warn_count:$$warn_count,log_file:$$log_file}'\'' >> "$$TEST_RESULTS_JSONL"; \
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
	             bash scripts/record-test-results.sh; \
	             if [ $$fail_count -ne 0 ]; then exit 1; else exit 0; fi; \
	           else \
	             echo "Running affected tests: $$tests_to_run" | tee -a "$$TEST_LOG_FILE"; \
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
	                 status="pass"; \
	                 if [ $$test_exit -ne 0 ]; then \
	                     fail_count=$$((fail_count + 1)); \
	                     status="fail"; \
	                 fi; \
	                 test_warn=0; \
	                 if [ -f "$$test_log" ]; then \
	                     test_warn=$$(awk "/^\\[TEST\\] WARN:/ {count++} END {print count+0}" "$$test_log" 2>/dev/null | tr -d "\n\r"); \
	                     test_warn=$$(echo "$$test_warn" | tr -d "\n\r" | grep -E "^[0-9]+$$" || echo "0"); \
	                 fi; \
	                 warn_count=$$((warn_count + test_warn)); \
	                 jq -n --arg name "$$test_name" --arg status "$$status" --arg log_file "$$test_log" \
	                   --argjson duration_seconds "$$TEST_DURATION" --argjson warn_count "$$test_warn" \
	                   '\''{name:$$name,status:$$status,duration_seconds:$$duration_seconds,warn_count:$$warn_count,log_file:$$log_file}'\'' >> "$$TEST_RESULTS_JSONL"; \
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
	             bash scripts/record-test-results.sh; \
	             if [ $$fail_count -ne 0 ]; then exit 1; else exit 0; fi; \
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
	           TEST_RESULTS_JSONL="$$TEST_LOG_DIR/results-all-$$(date +%Y%m%d-%H%M%S).jsonl"; \
	           export TEST_RESULTS_JSONL; \
	           : > "$$TEST_RESULTS_JSONL"; \
	           echo "Test log file: $$TEST_LOG_FILE"; \
	           echo "Test results file: $$TEST_RESULTS_JSONL"; \
	           bash scripts/apply-container.sh && \
	           export PATH="$$HOME/.local/bin:$$HOME/.cargo/bin:$$PATH" && \
	           FNM_PATH="$$HOME/.local/share/fnm" && \
	           if [ -x "$$FNM_PATH/fnm" ]; then export PATH="$$FNM_PATH:$$PATH"; eval "$$($$FNM_PATH/fnm env)"; fi && \
	           echo "Running all tests..." && \
	           warn_count=0; \
	           fail_count=0; \
	           for test in tests/*-test.sh; do \
	               echo ""; \
	               test_name=$$(basename "$$test"); \
	               test_log="$$TEST_LOG_DIR/$$test_name-$$(date +%Y%m%d-%H%M%S).log"; \
	               export TEST_LOG_FILE="$$test_log"; \
	               echo "Running $$test_name (log: $$test_log)..." | tee -a "$$TEST_LOG_FILE"; \
	               TEST_START=$$(date +%s); \
	               bash "$$test" 2>&1 | tee -a "$$TEST_LOG_FILE"; \
	               test_exit=$${PIPESTATUS[0]}; \
	               TEST_END=$$(date +%s); \
	               TEST_DURATION=$$((TEST_END - TEST_START)); \
	               if [ $$test_exit -ne 0 ]; then \
	                   fail_count=$$((fail_count + 1)); \
	               fi; \
	               status="pass"; \
	               if [ $$test_exit -ne 0 ]; then status="fail"; fi; \
	               test_warn=0; \
	               if [ -f "$$test_log" ]; then \
	                   test_warn=$$(awk "/^\\[TEST\\] WARN:/ {count++} END {print count+0}" "$$test_log" 2>/dev/null | tr -d "\n\r"); \
	                   test_warn=$$(echo "$$test_warn" | tr -d "\n\r" | grep -E "^[0-9]+$$" || echo "0"); \
	               fi; \
	               warn_count=$$((warn_count + test_warn)); \
	               jq -n --arg name "$$test_name" --arg status "$$status" --arg log_file "$$test_log" \
	                 --argjson duration_seconds "$$TEST_DURATION" --argjson warn_count "$$test_warn" \
	                 '\''{name:$$name,status:$$status,duration_seconds:$$duration_seconds,warn_count:$$warn_count,log_file:$$log_file}'\'' >> "$$TEST_RESULTS_JSONL"; \
	           done; \
	           echo ""; \
	           echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	           echo "Overall Test Results:" | tee -a "$$TEST_LOG_FILE"; \
	           echo "  Total WARN: $$warn_count" | tee -a "$$TEST_LOG_FILE"; \
	           echo "  Total FAIL: $$fail_count" | tee -a "$$TEST_LOG_FILE"; \
	           echo "========================================" | tee -a "$$TEST_LOG_FILE"; \
	           if [ $$fail_count -eq 0 ]; then \
	               echo ""; \
	               echo "==> All tests passed (No FAIL). Creating environment snapshot..." | tee -a "$$TEST_LOG_FILE"; \
	               bash scripts/create-snapshot.sh; \
	               if [ "$(BASELINE)" = "1" ]; then \
	                   echo ""; \
	                   echo "==> Saving baseline test results..." | tee -a "$$TEST_LOG_FILE"; \
	                   bash scripts/record-test-results.sh --baseline; \
	               else \
	                   bash scripts/record-test-results.sh; \
	               fi; \
	           else \
	               echo "==> Tests completed with issues (WARN: $$warn_count, FAIL: $$fail_count)" | tee -a "$$TEST_LOG_FILE"; \
	               echo "==> Check log files in $$TEST_LOG_DIR for details" | tee -a "$$TEST_LOG_FILE"; \
	               bash scripts/record-test-results.sh; \
	           fi; \
	           if [ $$fail_count -ne 0 ]; then exit 1; else exit 0; fi'

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
			for vol in dotfiles-state cargo-data rustup-data env-snapshot vim-data local-bin-data fzf-data fnm-data; do \
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
		for vol in dotfiles-state cargo-data rustup-data env-snapshot vim-data local-bin-data fzf-data fnm-data; do \
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
			echo "✓ Persistent state cleared (dotfiles-state, cargo-data, rustup-data, env-snapshot, vim-data, local-bin-data, fzf-data, fnm-data)."; \
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
	             home/dot_bashrc.d/*.sh \
	             home/dot_bash_prompt.d/*.sh \
	             scripts/*.sh \
	             tests/*.sh tests/lib/*.sh
	@echo "==> Running shellcheck on .chezmoiscripts (template-aware)..."
	@$(DOCKER_RUN_BASE_USER) $(IMAGE_LINT) bash -c '\
	  for f in home/.chezmoiscripts/*.sh.tmpl; do \
	    if ! sed "/^{{-.*-}}$$/d" "$$f" | shellcheck -e SC1090,SC1091 -; then \
	      echo "shellcheck failed: $$f"; exit 1; \
	    fi; \
	  done'
	@echo "✓ All shell scripts passed shellcheck"

# format: Format all shell scripts with shfmt
# Fast execution using lightweight lint-only Docker image
# Reads .editorconfig for indent settings
format: build-lint
	@echo "==> Formatting shell scripts with shfmt..."
	@$(DOCKER_RUN_BASE_USER) $(IMAGE_LINT) \
	  shfmt -w home/dot_bashrc.d/*.sh \
	           home/dot_bash_prompt.d/*.sh \
	           scripts/*.sh \
	           tests/*.sh tests/lib/*.sh
	@echo "==> Formatting .chezmoiscripts (preserving template guards)..."
	@$(DOCKER_RUN_BASE_USER) $(IMAGE_LINT) bash -c '\
	  for f in home/.chezmoiscripts/*.sh.tmpl; do \
	    head -1 "$$f" > "$$f.tmp"; \
	    tail -n +2 "$$f" | head -n -1 | shfmt >> "$$f.tmp"; \
	    tail -1 "$$f" >> "$$f.tmp"; \
	    mv "$$f.tmp" "$$f"; \
	  done'
	@echo "✓ Shell scripts formatted"
