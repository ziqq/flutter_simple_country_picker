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
				@echo "╠ RUN ANALYZE THE CODE..."
				@fvm dart analyze --fatal-infos --fatal-warnings
				@echo "╠ ANALYZED CODE SUCCESSFULLY"

.PHONY: check
check: analyze ## Check code
				@echo "╠ RUN CECK CODE..."
				@fvm dart pub publish --dry-run
				@fvm dart pub global activate pana
				@pana --json --no-warning --line-length 80 > log.pana.json
				@echo "╠ CECKED CODE SUCCESSFULLY"

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: test-unit
test-unit: ## Runs unit tests
				@echo "╠ RUNNING UNIT TESTS..."
				@fvm flutter test --coverage || (echo "Error while running tests"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "Error while running genhtml with coverage"; exit 2)
				@echo "╠ UNIT TESTS SUCCESSFULLY"

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