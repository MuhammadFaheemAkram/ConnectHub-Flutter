# Learning Notes

Every Flutter / Dart concept ConnectHub uses, grouped by topic, each pointing to where it lives in the code. The phase write-ups ([1](PHASE_1_SUMMARY.md) · [2](PHASE_2_SUMMARY.md) · [3](PHASE_3_SUMMARY.md) · [4](PHASE_4_SUMMARY.md) · [5](PHASE_5_SUMMARY.md) · [6](PHASE_6_SUMMARY.md) · [7](PHASE_7_SUMMARY.md)) explain the *why* in more depth.

---

## 1. Toolchain and project setup

| Concept | Where | Notes |
|---|---|---|
| FVM per-project pinning | `.fvmrc` | The Flutter version is part of the repo, like the Gradle wrapper. Run everything as `fvm flutter …`. |
| `material_ui` package | every UI file | In Flutter 3.47, Material left the core SDK. UI files import `package:material_ui/material_ui.dart`, never `flutter/material.dart`. |
| Strict analysis | `analysis_options.yaml` | `strict-casts`, `strict-inference`, `strict-raw-types`; generated files stay in scope, so their compile errors are reported. |
| Code generation | `build.yaml`, `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `app_routes.g.dart`, `app_database.steps.dart` | `build_runner` turns annotations into committed `part` files; CI fails if they are stale. |
| Schema exports | `drift_schemas/` | `drift_dev make-migrations` exports every schema version and writes typed migration steps and tests. |

## 2. Dart language

- **Sealed classes + exhaustive `switch`:** `AppException`, `Result`, `SessionState`, every Bloc event family, the UI states. A missing case is a compile error.
- **Class modifiers:** `final class` (closed value types), `abstract final class` (namespaces such as `AppSpacing`, `DemoAccount`), `abstract interface class` (repository and service contracts).
- **Primary constructors (Dart 3.13):** `final class const Ok<T>(final T value) extends Result<T>;` (`core/common/result.dart`), the feed cursor in the fake server.
- **Records**
  - record typedefs for joined rows: `typedef CachedPost = ({PostRow post, UserRow author, DateTime? bookmarkedAt});`;
  - waiting for two futures at once: `final (user, posts) = await (refreshUser(id), refreshUserPosts(id)).wait;`;
  - destructuring in loops: `for (final (mode, label, icon) in _choices)`.
- **Patterns**
  - destructuring `case Ok(value: final hasMore)`, `case Err(:final exception)`;
  - type tests inside patterns: `case Err(exception: NotFoundException())`;
  - the null-check pattern: `if (notification.postId case final postId?)`;
  - list patterns in a `switch` expression: `switch (posts) { null => …, [] => …, final posts => … }`.
- **Enhanced enums** with fields and methods: `AppLanguage('Español')`, `ActivityFilter.matches(notification)`, `UiMessageAction.label`; `values.asNameMap()` for safe parsing.
- **Extensions:** the DTO ↔ row ↔ domain mappers, `Stream.firstValue`, `BuildContext.appColors`, `BuildContext.prefersStackedLayout`, `AppThemeMode.toThemeMode()`.
- **Streams**
  - `Stream.multi` to emit the current value, then every change (`watchSettings`, `watchTyping`, `watchMessages`, which also counts its watchers);
  - `async*` + `yield*` for the realtime channel (`FakeChatApiService.events`);
  - broadcast `StreamController`s, `sync: true` where ordering matters (the "cache cleared" signal).
- **Grapheme-aware text:** `package:characters` counts what people see, so an emoji is one of the 280 characters.

## 3. Architecture

- **Layers:** `domain/` (pure Dart) ← `data/` (implementations) ← `core/` (infrastructure) ← `features/` (UI). See [ARCHITECTURE.md](ARCHITECTURE.md).
- **Repository pattern:** contracts in `domain/repository`, implementations in `data/repository`, bound by DI (`@LazySingleton(as: …)`).
- **Use cases:** one small callable class per operation (`call()`), so Cubits depend on intent; some carry rules (`SendMessageUseCase` trims and ignores blank text).
- **`Result<T>` instead of exceptions** across the data → domain boundary; `ApiGuard` is the one place that converts `AppException`s, expires the session on a 401, and drops answers for an ended session.
- **The UI reads only the cache.** Repositories write the server's answers to drift; every screen follows drift's streams. That is offline-first, and it keeps every screen consistent.
- **Mappers** live next to the data they map: DTO → row → domain, each in `data/mapper/`.
- **Page / View split:** the Page wires DI and navigation; the View renders state and exposes callbacks, so widget tests need no router or `getIt`.

## 4. State management (flutter_bloc)

| Concept | Where |
|---|---|
| Cubit with an initial state and plain methods | most screens (`FeedCubit`, `ChatDetailCubit`, `SettingsCubit`, …) |
| Bloc with events (`on<E>`) | `AuthBloc`, `LoginBloc`, `SignUpBloc`, `SearchBloc` |
| `droppable()` submits | Login, Sign Up, logout: a double tap makes one request |
| `restartable()` | the session subscription; Search, where a new query cancels the old one *and* its live results |
| A custom transformer | `debounceRestartable` (`search_transformers.dart`): `switchMap` to a delayed event, then `restartable()` |
| `emit.forEach` / `emit.onEach` | `AuthBloc` follows the session; `SearchBloc` follows live results and the "cache cleared" signal |
| freezed states rendered with an exhaustive `switch` | every `*_state.dart` |
| One-time effects in state | `UiMessage` (with an id, and optionally an Undo action), the chat's auto-scroll keyed on the newest message |
| Two inputs combined into one state | the cache stream + what the latest refresh found (pending / succeeded / failed / not found) |
| Read the cache, *then* record the outcome | every list Cubit's `_runRefresh` (no one-frame false states) |
| `isClosed` guard after every `await` | every Cubit with async work |
| Subscribe in the constructor, cancel in `close()` | every Cubit that follows a stream |
| App-scoped and session-scoped Cubits | `AuthBloc` + `SettingsCubit` above `MaterialApp`; `BadgesCubit` in the tab shell |
| Rebuilding on a slice of state | `BlocSelector` (the theme), `context.select` (badges, buttons) |

## 5. Dependency injection (get_it + injectable)

- `@InjectableInit` generates `getIt.init()`; `main()` awaits `configureDependencies()` before `runApp`.
- **Scopes:** `@injectable` (a new instance each time) for use cases and Cubits; `@lazySingleton` for infrastructure and repositories.
- **`@module`** registers types you don't own: the asset bundle, `AppDatabase` and its DAOs, `SharedPreferencesWithCache`, `PackageInfo`, `FlutterSecureStorage`, `Clock`.
- **`@preResolve`:** async factories awaited during `init()`, so preferences and the package info are read synchronously afterwards.
- **`@factoryParam`:** runtime ids (`getIt<ChatDetailCubit>(param1: conversationId)`).
- **`@ignoreParam`:** constructor parameters DI leaves alone (the search debounce and the reply timings, which tests shorten).
- **`@disposeMethod`:** the fake server cancels its reply timers when the container resets.
- **Tests** build the real container with a few swaps, then `getIt.reset()` in `tearDown`.

## 6. Navigation (go_router + go_router_builder)

- **Typed routes:** `@TypedGoRoute`, `@TypedStatefulShellRoute`, `GoRouteData` classes with generated `go()` / `push()` / `location`.
- **The sign-in gate:** a top-level `redirect` calling the pure function `authRedirect(AuthState, Uri)`, re-run by a `refreshListenable` (`StreamListenable` over the `AuthBloc`'s stream); a `?from=` return address survives the gate.
- **`StatefulShellRoute.indexedStack`:** five tabs, each with its own Navigator, kept alive offstage; re-tapping a tab returns it to its start.
- **Root-level routes** for screens reachable from several tabs, pushed above the tab bar; full-screen dialogs (`MaterialPage(fullscreenDialog: true)`).
- **Route-level `redirect`:** `/users/<my id>` → `/profile`; and its limit: pushing a location that redirects into a shell tab would duplicate the shell's page, so `openProfile` uses `go` for that case.
- **`BackToFeedButton`:** a deep-linked screen with nothing below it offers "Go to the feed" instead of a dead Back button.

## 7. UI, Material 3 and accessibility

- **Theming:** `ColorScheme.fromSeed` (`#0F766E`, teal), component themes, `ThemeMode` from an app-scoped Cubit, read before the first frame.
- **`ThemeExtension`** (`AppColors`): semantic colours (`like`, `unread`) with `lerp`, read through `context.appColors`.
- **Design tokens:** `AppSpacing`, `AppRadius`, `AppIconSize`.
- **Widgets used**
  - lists: `ListView.builder` / `.separated` (a reversed one for the chat), `RefreshIndicator`, `NotificationListener<ScrollMetricsNotification>` (load more when the list comes to fit without scrolling);
  - controls: `NavigationBar` with `Badge`s, `SegmentedButton`, `RadioGroup` + `RadioListTile`, `DropdownMenu`, `FilterChip`, `ChoiceChip`, `SwitchListTile`, a custom search field;
  - feedback: `SnackBar` (with an Undo action), `AlertDialog`, `AboutListTile`, `Tooltip`;
  - images: `CachedNetworkImage` with initials or a plain box as fallbacks;
  - animation: one `AnimationController` driving three phase-shifted dots (`TypingIndicator`).
- **`PopScope`:** "Discard post?" and "Discard changes?" guards.
- **Accessibility**
  - tooltips that double as screen-reader labels; `Semantics(label: '3 unread')`, `excludeSemantics` and `MergeSemantics` to read rows as one phrase;
  - tap targets of at least 48 × 48, checked by `androidTapTargetGuideline`;
  - large text: layouts that stack above 130 % (`prefersStackedLayout`), a `Wrap` instead of a row of thirds, `MediaQuery.withNoTextScaling` for the tab bar and `withClampedTextScaling` for badges;
  - "reduce motion" respected (`MediaQuery.disableAnimationsOf`);
  - WCAG AA contrast for every custom pairing, enforced by tests.

## 8. Data and persistence

- **JSON:** `json_serializable` DTOs, `checked: true`, mapped to domain models; a malformed response becomes `DataFormatException`.
- **freezed 4:** `@freezed abstract class` values and `sealed class` unions, `@Default`, `copyWith`, deep equality.
- **drift**
  - tables with foreign keys (`PRAGMA foreign_keys = ON`), `ON DELETE CASCADE`, `textEnum` columns;
  - **JOINs** (`innerJoin`) so an author's row is read with every post and comment;
  - **upserts** (`insertOnConflictUpdate`), never `REPLACE`, because a REPLACE deletes and cascades;
  - **mirroring** a server list in one transaction: upsert what came back, delete the rest (`isNotIn`, `isNotInQuery` subqueries);
  - **ordering** with `CASE WHEN` (delivered messages by time, unsent ones by `rowId`); aggregates (`SUM` of unread counts);
  - **reactive queries:** `watch()` streams re-run when a table they read changes, which is how every screen stays current;
  - **migrations:** `schemaVersion` 4, generated steps (`stepByStep`), exported schemas, and data-integrity tests per step.
- **Secure storage:** `flutter_secure_storage` (Keychain / Keystore) holds the session token; `android:allowBackup="false"`.
- **`SharedPreferencesWithCache`:** created once with an allow-list, then synchronous reads; enum values stored by name and parsed defensively.

## 9. Networking, concurrency and realtime

- **A fake backend behind interfaces:** `FakeServer` (in memory, seeded from assets), `FakeApiClient` (token + simulated network + 401), `NetworkSimulator` (latency, failures). See [API_SIMULATION.md](API_SIMULATION.md).
- **Cursor pagination:** pages after an opaque `<createdAt>|<id>` cursor over the client's `feed_items` window; nothing shifts when a post is created.
- **Optimistic updates with rollback** in repositories; **one request per post at a time** (an in-flight set).
- **A `Lock` (`package:synchronized`):** refresh and load-more take turns; chat messages go out one at a time, in order. Dart has no data races, but every `await` lets other code run.
- **Client-generated ids** make a retried message idempotent on the server.
- **A realtime channel as a `Stream`:** one subscription per session, events handled in order with `asyncMap`, closed at logout, events for an ended session dropped.
- **Timers as a simulation:** `ReplyScheduler` types, then replies, and keeps typing on across overlapping replies.

## 10. Testing

- **Unit tests** for validators, the fake server (against the real seed JSON), the API services, DAOs (`NativeDatabase.memory()`), repositories (on the real fake server) and migrations (generated schema snapshots).
- **`bloc_test`:** `blocTest` with `build` / `setUp` / `seed` / `act` / `expect` / `verify`; fakes with a `Completer` gate to hold a request in flight.
- **Widget tests:** `MockCubit` / `MockBloc` + `whenListen`, a phone-sized surface, semantics finders, `meetsGuideline(...)`.
- **App-level tests** pump the real app on the real DI graph with in-memory stores: sign-in, deep links, expiry, chat replies in fake time.
- **`fake_async`** for exact timing, and real time where a future is born outside the fake zone or a stream switches.
- **Mutation checks:** break the code on purpose and watch the test fail, to prove it can.
- **A global test config** (`flutter_test_config.dart`) for an offline image cache.

## 11. Tooling and repo hygiene

- **CI** (`.github/workflows/flutter-ci.yml`): the FVM-pinned Flutter, `build_runner` + `git diff --exit-code`, format, analyze, test; a newer push cancels the run in progress.
- **Conventional Commits,** one commit per phase.
- **Open-source files:** LICENSE (MIT), CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CHANGELOG (Keep a Changelog), issue and PR templates.
