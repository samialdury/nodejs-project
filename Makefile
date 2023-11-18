.DEFAULT_GOAL ?= help

COMMIT_SHA ?= $(shell git rev-parse --short HEAD)
PROJECT_NAME ?= nodejs-project

RED ?= $(shell tput setaf 1)
GREEN ?= $(shell tput setaf 2)
YELLOW ?= $(shell tput setaf 3)
CYAN ?= $(shell tput setaf 6)
NC ?= $(shell tput sgr0)

BIN := node_modules/.bin

LOCAL_DIR ?= local
SCRIPTS_DIR ?= $(LOCAL_DIR)/scripts
SRC_DIR ?= src
BUILD_DIR ?= build
CACHE_DIR ?= .cache

TEST_FILES ?= {src,test}/**/*.test.ts

##@ Misc

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# You can remove this target once you've ran it.
.PHONY: prepare
prepare: ## Prepare template (name=<string>)
	@node $(SCRIPTS_DIR)/prepare-template.js $(name)
	@rm -rf local

##@ Development

.PHONY: install
install: ## install all dependencies (skip-postinstall=<boolean>?)
	@pnpm install
ifeq ($(skip-postinstall),true)
	@echo "Skipping postinstall"
else
	@$(BIN)/husky install
endif

.PHONY: dev
dev: ## run TS and watch for changes
	@node --env-file .dev.env --no-warnings --import tsx --watch --watch-preserve-output $(SRC_DIR)/main.ts

.PHONY: run
run: ## run JS
	@node --env-file .env $(BUILD_DIR)/$(SRC_DIR)/main.js

##@ Build

.PHONY: build
build: ## build the project
	@echo "=== $(YELLOW)cleaning build directory$(NC) ==="
	@rm -rf $(BUILD_DIR)
	@echo "=== $(CYAN)building project$(NC) (TS $$($(BIN)/tsc --version)) ==="
	@$(BIN)/tsc
	@echo "=== $(GREEN)build successful$(NC) ==="

.PHONY: build-image
build-image: ## build Docker image (args=<build args>?, tag=<string>?)
	@docker build $(args) --build-arg COMMIT_SHA='dev,$(COMMIT_SHA)' -t $(or $(tag), $(PROJECT_NAME)) . -f ./Dockerfile

##@ Test

.PHONY: test
test: ## run tests
	@$(BIN)/glob -c 'node --env-file .test.env --no-warnings --import tsx --test' '$(TEST_FILES)'

.PHONY: test-watch
test-watch: ## run tests and watch for changes
	@$(BIN)/glob -c 'node --env-file .test.env --no-warnings --import tsx --watch --watch-preserve-output --test' '$(TEST_FILES)'

##@ Code quality

.PHONY: format
format: ## format the code
	@echo "=== $(CYAN)running Prettier$(NC) ==="
	@$(BIN)/prettier --cache --cache-location=$(CACHE_DIR)/prettier --write --log-level warn .
	@echo "=== $(GREEN)format successful$(NC) ==="

.PHONY: lint
lint: ## lint the code
	@echo "=== $(CYAN)running ESLint$(NC) ==="
	@$(BIN)/eslint --max-warnings 0 --cache --cache-location $(CACHE_DIR)/eslint --fix .
	@echo "=== $(GREEN)lint successful$(NC) ==="

##@ CI

.PHONY: install-ci
install-ci: ## install all dependencies (CI)
	@pnpm install --frozen-lockfile

.PHONY: build-ci
build-ci: build ## build the project (CI)

.PHONY: test-ci
test-ci: test ## run tests (CI)

.PHONY: format-ci
format-ci: ## format the code (CI)
	@echo "=== $(CYAN)running Prettier$(NC) ==="
	@$(BIN)/prettier --check --log-level warn .
	@echo "=== $(GREEN)format successful$(NC) ==="

.PHONY: lint-ci
lint-ci: ## lint the code (CI)
	@echo "=== $(CYAN)running ESLint$(NC) ==="
	@$(BIN)/eslint --max-warnings 0 .
	@echo "=== $(GREEN)lint successful$(NC) ==="

##@ Release

.PHONY: release
release: ## create a new release
	@$(BIN)/semantic-release
