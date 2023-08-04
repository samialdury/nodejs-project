COMMIT_SHA := $(shell git rev-parse --short HEAD)
PROJECT_NAME := $(shell basename "$(PWD)")

BIN := node_modules/.bin

SRC_DIR := src
BUILD_DIR := build
CACHE_DIR := .cache

.PHONY: help
## Display this help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: install
install: ## install all dependencies
	@pnpm install
	@$(BIN)/husky install

.PHONY: dev
dev: ## run TS and watch for changes
	@node --no-warnings --require dotenv/config --loader tsx --watch --watch-preserve-output $(SRC_DIR)/main.ts | $(BIN)/pino-pretty

.PHONY: run
run: ## run JS
	@node --require dotenv/config $(BUILD_DIR)/$(SRC_DIR)/main.js | $(BIN)/pino-pretty

##@ Build

.PHONY: build
build: ## build the project
	@rm -rf $(BUILD_DIR)
	@$(BIN)/tsc

.PHONY: build-image
build-image: ## build Docker image (args=<build args>, tag=<string>)
	@docker build $(args) --build-arg COMMIT_SHA='dev,$(COMMIT_SHA)' -t $(or $(tag), $(PROJECT_NAME)) . -f ./Dockerfile

##@ Test

.PHONY: test
test: ## run tests
	@$(BIN)/glob -c 'DOTENV_CONFIG_PATH=.test.env node --no-warnings --require dotenv/config --loader tsx --test' '{src,test}/**/*.test.ts'

.PHONY: test-watch
test-watch: ## run tests and watch for changes
	@$(BIN)/glob -c 'DOTENV_CONFIG_PATH=.test.env node --no-warnings --require dotenv/config --loader tsx --watch --watch-preserve-output --test' '{src,test}/**/*.test.ts'

##@ Code quality

.PHONY: format
format: ## format the code
	@$(BIN)/prettier --cache --cache-location=$(CACHE_DIR)/prettier --write .

.PHONY: lint
lint: ## lint the code
	@$(BIN)/eslint --max-warnings 0 --cache --cache-location $(CACHE_DIR)/eslint --fix .

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
	@$(BIN)/prettier --check .

.PHONY: lint-ci
lint-ci: ## lint the code (CI)
	@$(BIN)/eslint --max-warnings 0 .

##@ Release

.PHONY: release
release: ## create a new release
	@$(BIN)/semantic-release
