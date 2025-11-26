SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: get format analyze check test-unit

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

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

.PHONY: generate
generate: ## Generate code
generate: get l10n build-runner

.PHONY: build-runner
build-runner: ## Run build_runner:build
		@fvm dart --disable-analytics && fvm dart run build_runner build --delete-conflicting-outputs --release

.PHONY: l10n
l10n: ## Generate localization
				@fvm dart pub global activate intl_utils
				@fvm dart pub global run intl_utils:generate
				@fvm flutter gen-l10n --arb-dir lib/src/localization/translations --output-dir lib/src/localization/generated --template-arb-file intl_ru.arb

.PHONY: format
format: ## Format code
				@find lib test -path '*/generated/*' -prune -o -type f -name '*.dart' ! -name '*.*.dart' ! -name 'messages_.*.dart' ! -name 'l10n.dart' -print0 | xargs -0 dart format --set-exit-if-changed --line-length 80 -o none || (echo "¯\_(ツ)_/¯ Format code error"; exit 1)

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: clean-cache
clean-cache: ## Clean the pub cache
				@fvm flutter pub cache repair

.PHONY: clean
clean: ## Clean flutter
				@fvm flutter clean

.PHONY: get
get: ## Get dependencies
				@fvm flutter pub get || (echo "¯\_(ツ)_/¯Get dependencies error"; exit 1)

.PHONY: update
update: get build-runner ## Update dependencies and codegen
				@cd example fvm flutter pub get || (echo "¯\_(ツ)_/¯Get dependencies error"; exit 1)

.PHONY: analyze
analyze: get ## Analyze code
				@fvm dart analyze --fatal-infos --fatal-warnings

.PHONY: check
check: ## Check code
				@fvm dart pub publish --dry-run
				@fvm dart pub global activate pana
				@pana --json --no-warning > log.pana.json

.PHONY: publish
publish: ## Publish package
				@fvm dart pub publish --server=https://pub.dartlang.org || (echo "¯\_(ツ)_/¯Publish error"; exit 1)

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: test-unit
test-unit: ## Runs unit and widget tests
				@fvm flutter test --coverage test/flutter_simple_country_picker_test.dart
				@lcov --remove coverage/lcov.info 'lib/src/localization/*' -o coverage/lcov.info
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml with coverage"; exit 2)

.PHONY: tag
tag: ## Add a tag to the current commit
	@dart run tool/tag.dart

.PHONY: tag-add
tag-add: ## Make command to add TAG. E.g: make tag-add TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "TAG is not set"; exit 1; fi
				@git tag $(TAG)
				@git push origin $(TAG)
				@echo "CREATED AND PUSHED TAG $(TAG)"

.PHONY: tag-remove
tag-remove: ## Make command to delete TAG. E.g: make tag-delete TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "TAG is not set"; exit 1; fi
				@git tag -d $(TAG)
				@git push origin --delete $(TAG)
				@echo "DELETED TAG $(TAG) LOCALLY AND REMOTELY"

.PHONY: diff
diff: ## git diff
	$(call print-target)
	@git diff --exit-code
	@RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi