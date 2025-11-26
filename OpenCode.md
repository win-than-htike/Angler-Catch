# OpenCode Guide

## Build, Lint, and Test Commands
- **Build the project:** `flutter build <platform>`
- **Run all tests:** `flutter test`
- **Run a single test file:** `flutter test <path_to_test_file>`
- **Analyze code for issues:** `flutter analyze`

## Code Style Guidelines
- **Imports:** Organize as standard Dart (package, relative, and dart: imports).
- **Formatting:** Use `dart format` and adhere to 80-character line limits.
- **Naming:**
  - Files: `snake_case.dart`
  - Classes: `PascalCase`
  - Variables/Methods: `camelCase`
- **Types:** Always use null-safe, strict typing; avoid `dynamic` unless unavoidable.
- **Error Handling:** Use `try-catch` for exceptions; log using the `logging` package.
- **Build Methods:** Break large `build()` methods into reusable private widgets.
- **State Management:** Prefer `ChangeNotifier`, `ValueNotifier`, or `StreamBuilder` for state.

## Testing
- Use `package:test` for unit tests, `flutter_test` for widgets, and `integration_test` for full app workflows.
- Follow Arrange-Act-Assert pattern.


## Linting Configurations
- Activated: `flutter_lints` (via `analysis_options.yaml`)
- Suppress rules as needed inline (`// ignore: rule_name`) or file-wide.

Adhere to these guidelines to ensure consistency, readability, and maintainability across the codebase.