.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS> ... <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Check fvm flutter doctor
				@fvm flutter doctor

.PHONY: version
version: ## Check fvm flutter version
				@fvm flutter --version

.PHONY: format
format: ## Format code
				@fvm dart format --fix -l 80 . || (echo "👀 Format code error 👀"; exit 1)

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
				@fvm flutter pub get || (echo "▓▓ Get dependencies error ▓▓"; exit 1)

.PHONY: l10n
l10n: ## Generate localization
				@fvm dart pub global activate intl_utils
				@fvm dart pub global run intl_utils:generate
				@fvm flutter gen-l10n --arb-dir lib/src/common/localization/translations --output-dir lib/src/common/localization/generated --template-arb-file intl_ru.arb

.PHONY: generate
generate: get ## Generate the code
				@fvm dart pub global activate protoc_plugin
				@protoc --proto_path=lib/src/protobuf --dart_out=lib/src/protobuf lib/src/protobuf/client.proto
				@fvm dart run build_runner build --delete-conflicting-outputs
				@fvm dart format -l 80 lib/src/model/pubspec.yaml.g.dart lib/src/protobuf/ test/

.PHONY: gen
gen: generate

.PHONY: codegen
codegen: generate

.PHONY: analyze
analyze: get format ## Analyze code
				@fvm dart analyze --fatal-infos --fatal-warnings

.PHONY: check
check: analyze ## Check code
				@fvm dart pub publish --dry-run
				@fvm dart pub global activate pana
				@pana --json --no-warning --line-length 80 > log.pana.json

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: test-unit
test-unit: ## Runs unit tests
				@fvm flutter test --coverage || (echo "Error while running tests"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "Error while running genhtml with coverage"; exit 2)

.PHONY: diff
diff: ## git diff
				$(call print-target)
				@git diff --exit-code
				@RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi

.PHONY: build-runner
build-runner: ## Run build_runner:build
				@fvm dart --disable-analytics && fvm dart run build_runner build --delete-conflicting-outputs --release

.PHONY: splash-screen
splash-screen: ## Generate app splash screen used https://pub.dev/packages/flutter_native_splash
				@fvm dart run flutter_native_splash:create  || (echo "▓▓ Create splash screen error ▓▓"; exit 1)