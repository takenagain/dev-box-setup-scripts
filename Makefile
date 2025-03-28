# Default shell
SHELL := /bin/bash

BINARY_NAME := runner
PROJECT_DIR := $(CURDIR)/$(BINARY_NAME)
TARGET_DIR := $(PROJECT_DIR)/target/release
RUST_CHECK := $(shell which rustc)

.PHONY: all check-rust install-rust build install run-scripts run-% list-scripts list-scripts-json list-scripts-csv list-scripts-table clean deps test fmt fmt-check lint install-deps

install-deps:
	@echo "Installing system dependencies..."
	@if [ "$(shell uname -s)" = "Linux" ]; then \
		if [ -f /etc/debian_version ]; then \
			bash $(CURDIR)/scripts/debian/apt.sh; \
		elif [ -f /etc/alpine-release ]; then \
			sh $(CURDIR)/scripts/alpine/apk.sh; \
		fi; \
	elif [ "$(shell uname -s)" = "Darwin" ]; then \
		bash $(CURDIR)/scripts/darwin/brew.sh; \
	else \
		echo "Unsupported OS"; exit 1; \
	fi

all: install-deps install

check-rust:
ifeq ($(RUST_CHECK),)
	@echo "Rust is not installed. Installing Rust..."
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	@source "$$HOME/.cargo/env"
else
	@echo "Rust is already installed"
endif

install-rust:
	@echo "Installing Rust..."
	@if [ "$(shell uname -s)" = "Linux" ]; then \
		if [ -f /etc/debian_version ]; then \
			bash $(CURDIR)/scripts/debian/rust.sh; \
		elif [ -f /etc/alpine-release ]; then \
			sh $(CURDIR)/scripts/alpine/rust.sh; \
		fi; \
	elif [ "$(shell uname -s)" = "Darwin" ]; then \
		bash $(CURDIR)/scripts/darwin/rust.sh; \
	else \
		echo "Unsupported OS"; exit 1; \
	fi

build: check-rust
	@echo "Building $(BINARY_NAME)..."
	@cargo build --release --manifest-path $(PROJECT_DIR)/Cargo.toml

install: build
	@echo "Running $(BINARY_NAME) in interactive mode..."
	@$(TARGET_DIR)/$(BINARY_NAME) -s $(CURDIR)/scripts interactive --all

# Add a new target for simplified script running
install-%: build
	@echo "Running script: $*"
	@$(TARGET_DIR)/$(BINARY_NAME) -s $(CURDIR)/scripts run $*

clean:
	@echo "Cleaning build artifacts..."
	@cargo clean --manifest-path $(PROJECT_DIR)/Cargo.toml

deps: check-rust
	@echo "Installing/Updating dependencies..."
	@cargo update --manifest-path $(PROJECT_DIR)/Cargo.toml

test: check-rust
	@echo "Running tests..."
	@cargo test --manifest-path $(PROJECT_DIR)/Cargo.toml

fmt: check-rust
	@echo "Formatting code..."
	@cargo fmt --manifest-path $(PROJECT_DIR)/Cargo.toml

fmt-check: check-rust
	@echo "Checking code formatting..."
	@cargo fmt --manifest-path $(PROJECT_DIR)/Cargo.toml -- --check

lint: check-rust
	@echo "Running clippy..."
	@cargo clippy --manifest-path $(PROJECT_DIR)/Cargo.toml -- -D warnings
