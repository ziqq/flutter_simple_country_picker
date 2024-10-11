# feq ($(OS),Windows_NT)
# 	SHELL = cmd
#     RM = del /Q
#     MKDIR = mkdir
#     PWD = $(shell $(PWD))
# else
# 	SHELL = /bin/bash -e -o pipefail
#     RM = rm -f
#     MKDIR = mkdir -p
#     PWD = pwd
# endif

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS> ... <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: generate format check test

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: doctor
doctor: ## Check fvm flutter doctor
				@fvm flutter doctor

.PHONY: version
version: ## Check fvm flutter version
				@fvm flutter --version

.PHONY: format
format: ## Format code
				@echo "╠ RUN FORMAT THE CODE"
				@fvm dart format --fix -l 80 . || (echo "👀 Format code error 👀"; exit 1)
				@echo "╠ CODE FORMATED SUCCESSFULLY"

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: clean-cache
clean-cache: ## Clean the pub cache
				@echo "╠ CLEAN PUB CACHE"
				@fvm flutter pub cache repair
				@echo "╠ PUB CACHE CLEANED SUCCESSFULLY"

.PHONY: clean
clean: ## Clean flutter
				@echo "╠ RUN FLUTTER CLEAN"
				@fvm flutter clean
				@echo "╠ FLUTTER CLEANED SUCCESSFULLY"

.PHONY: get
get: ## Get dependencies
				@echo "╠ RUN GET DEPENDENCIES..."
				@fvm flutter pub get || (echo "▓▓ Get dependencies error ▓▓"; exit 1)
				@echo "╠ DEPENDENCIES GETED SUCCESSFULLY"

.PHONY: analyze
analyze: get ## Analyze code
				@echo "╠ RUN ANALYZE THE CODE..."
				@fvm dart analyze --fatal-infos --fatal-warnings
				@echo "╠ ANALYZED CODE SUCCESSFULLY"

.PHONY: check
check: analyze test-unit ## Check code
				@echo "╠ RUN CECK CODE..."
				@fvm dart pub publish --dry-run
				@fvm dart pub global activate pana
				@pana --json --no-warning --line-length 80 > log.pana.json
				@echo "╠ CECKED CODE SUCCESSFULLY"

.PHONY: publish
publish: ## Publish package
				@echo "╠ RUN PUBLISHING..."
				@fvm dart pub publish --server=https://pub.dartlang.org || (echo "▓▓ Publish error ▓▓"; exit 1)
				@echo "╠ PUBLISH PACKAGE SUCCESSFULLY"

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: run-genhtml
run-genhtml: ## Runs generage coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: test-unit
test-unit: ## Runs unit tests
				@echo "╠ RUNNING UNIT TESTS..."
				@fvm flutter test --coverage test/flutter_simple_country_picker_test.dart || (echo "Error while running tests"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "Error while running genhtml with coverage"; exit 2)
				@echo "╠ UNIT TESTS SUCCESSFULLY"

.PHONY: tag-add
tag-add: ## Make command to add TAG. E.g: make tag-add TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "TAG is not set"; exit 1; fi
				@echo ""
				@echo "START ADDING TAG: $(TAG)"
				@echo ""
				@git tag $(TAG)
				@git push origin $(TAG)
				@echo ""
				@echo "CREATED AND PUSHED TAG $(TAG)"
				@echo ""

.PHONY: tag-remove
tag-remove: ## Make command to delete TAG. E.g: make tag-delete TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "TAG is not set"; exit 1; fi
				@echo ""
				@echo "START REMOVING TAG: $(TAG)"
				@echo ""
				@git tag -d $(TAG)
				@git push origin --delete $(TAG)
				@echo ""
				@echo "DELETED TAG $(TAG) LOCALLY AND REMOTELY"
				@echo ""

.PHONY: diff
diff: ## git diff
	$(call print-target)
	@git diff --exit-code
	@RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi

.PHONY: build-runner
build-runner: ## Run build_runner:build
		@echo "╠ RUN BUILD RUNNER:BUILD"
		@fvm dart --disable-analytics && fvm dart run build_runner build --delete-conflicting-outputs --release
		@echo "╠ BUILD RUNNER:BUILD SUCCESSFULLY"