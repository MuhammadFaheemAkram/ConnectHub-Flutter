# Contributing to ConnectHub (Flutter)

Thanks for your interest! ConnectHub is a learning-focused reference project, so contributions that improve clarity, correctness or teaching value are especially welcome.

## Ground Rules

- Be respectful. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- **Keep the architecture intact:**
  - Respect the layer boundaries: View → Cubit/Bloc → UseCase → Repository → API service / drift.
  - `domain/` stays pure Dart, Views never import `data/`, and drift files never import `material_ui`.
  - **Screens read only the cache.** Repositories refresh drift from the API, and they own the optimistic writes and their rollback.
  - **Every API call goes through `ApiGuard`**, which ties the request to its session and handles a 401.
  - **The router owns navigation decisions.** Screens never check "am I signed in?" and use typed routes only.
- **UI:** import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`.
- **Dependencies:** keep them few and mainstream, and explain each new one in the README's tech stack.

## Development Setup

- Install [FVM](https://fvm.app), then run `fvm install`. It reads `.fvmrc`, which pins Flutter 3.47.6.
- iOS needs Xcode. Android needs the Android SDK and Java 17+ (Android Studio's bundled JDK works).
- Get the packages with `fvm flutter pub get`, then start the app with `fvm flutter run`. Sign in with **Use demo account**.
- After changing annotated code (freezed, json_serializable, injectable, drift, typed routes), regenerate it:

  ```bash
  fvm dart run build_runner build
  ```

  Generated files are committed, and CI fails if they are stale.
- **Changing the database schema:**
  1. Bump `schemaVersion` in `app_database.dart`.
  2. Run `fvm dart run drift_dev make-migrations`. It exports the new version to `drift_schemas/` and regenerates the steps and the migration test.
  3. Write the new step in `stepByStep`.
  4. Add a data-integrity test in `test/drift/` for anything that moves data.

## Coding Conventions

- **Lints:** `fvm flutter analyze` must report **no issues**. The rules are `flutter_lints` plus strict casts, inference and raw types.
- **Formatting:** `fvm dart format .` (the tall style).
- **Pages and Views:** Pages create and provide a Cubit/Bloc and wire navigation. Views render state and forward intents.
- **Cubit or Bloc:** use a Cubit by default. Use a Bloc only when event transformers (debounce, `droppable`, `restartable`) earn their place.
- **Immutable state:** freezed classes and sealed unions, rendered with an exhaustive `switch`.
- **Accessibility:** every tappable is at least 48 × 48 and has a label, and text contrast meets WCAG AA in both themes. Above 130 % text (`context.prefersStackedLayout`), side-by-side controls stack. The accessibility tour (`test/app/accessibility_tour_test.dart`) checks all of this, so add new screens and states to it.
- **Comments** explain *architecture decisions*, not obvious code.

## Commits

This project uses **[Conventional Commits](https://www.conventionalcommits.org/)**:

```
<type>(<scope>): <message>
```

Examples: `feat(chat): add message reactions`, `test(feed): cover a failed second page`, `docs(project): update architecture notes`.

## Pull Requests

1. Fork the repository and create a topic branch.
2. Make sure `fvm flutter analyze`, `fvm dart format --output=none --set-exit-if-changed .` and `fvm flutter test` all pass.
3. Update or add documentation where relevant.
4. Open a PR with a clear description of the change and its motivation.

## Tests

- **Cubits/Blocs:** `bloc_test`.
- **Views:** widget tests with `MockCubit` / `MockBloc` from `bloc_test`, and `mocktail`.
- **Repositories:** the real repositories on the real `FakeServer` and an in-memory database (`DataStack` in `test/helpers/`).
- **Fakes over mocks:** hand-written repository fakes in `test/helpers/fakes/`.
- **drift:** `NativeDatabase.memory()`.
- **Preferences:** `InMemorySharedPreferencesAsync`.
- **App-level flows:** `pumpConnectHub`, with `tearDown(getIt.reset)`.
- **Every async wait must be bounded.** See [docs/TESTING.md](docs/TESTING.md).
