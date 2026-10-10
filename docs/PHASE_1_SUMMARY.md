# Phase 1 — Foundation

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 1, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions built the same foundation.

---

## 🎯 Phase Goal

Phase 1 lays the **foundation** every later feature stands on. ConnectHub has an auth flow, five tabs and a dozen screens that open above them, so before any social feature it needs:

- a **reproducible toolchain** and strict **static analysis**, with **CI** from the very first commit;
- a layered **folder structure**, so every class has an obvious home;
- a small **design system**, so every screen looks consistent in light and dark mode;
- **type-safe navigation** with three kinds of routes: the auth routes, the tab shell, and the root-level screens pushed above it;
- a **sign-in gate** owned by the router, so no screen ever has to ask "am I signed in?";
- a **composition root** for dependency injection;
- **tests** proving the navigation contract.

Nothing here talks to a backend yet; it's the skeleton. A temporary in-memory "session" lets the gate be built and tested now. Phase 2 swaps it for real auth.

---

## 🧱 What Was Implemented

- **Project & toolchain**
  - Created with `fvm spawn 3.47.6 create --org co.bitfuse.flutter --project-name connect_hub --platforms android,ios`.
  - Pinned with `fvm use 3.47.6`; `.fvmrc` is committed and `.fvm/` is ignored.
  - Migrated to the standalone **`material_ui`** package (`dart fix --apply --code=migrate_design_widgets`). `cupertino_icons` was removed.
  - App display name "ConnectHub" on both platforms.
- **Static analysis and CI**
  - `analysis_options.yaml` comes from MovieExplorer: `flutter_lints` plus the strict modes and extra rules.
  - Generated files are **analyzed**: their lints are silenced by `ignore_for_file: type=lint` headers set in `build.yaml`, but their compile errors still surface.
  - `.github/workflows/flutter-ci.yml` runs on every push to `main` and every pull request: install the FVM-pinned Flutter, regenerate code and fail on a diff, then format, analyze and test.
  - `LICENSE` (MIT © 2026 BitFuse).
- **Folder structure:**
  - `app/`, `core/{common,design_system,navigation,network/{api,dto,fake_server},database,storage}`, `data/`, `domain/`, `features/` (15 screens + `shell/`) and `di/`;
  - folders for later phases are kept in git with `.gitkeep`.
- **Design system** (`core/design_system/`)
  - `AppTheme`: Material 3 light/dark from one seed, the Android edition's teal `#0F766E`, with the `fidelity` variant so the brand color isn't muted.
  - `AppColors` (`ThemeExtension`):
    - `like` for the heart;
    - `unread`, a subtle tint behind unread rows;
    - `copyWith`/`lerp`, plus a `context.appColors` shorthand.
  - Tokens: `AppSpacing`, `AppRadius`, `AppIconSize`.
  - Widgets:
    - `LoadingView`, `ErrorView` and `EmptyStateView`;
    - `AppTextField` (label, error, optional show/hide toggle for passwords), ready for Phase 2's forms.
- **Typed navigation** (`core/navigation/`)
  - **Auth routes:** `/splash`, `/login`, and `/login/signup`, a child of Login, so Back returns there.
  - **Tab shell:** a `@TypedStatefulShellRoute` with five branches (Feed, Search, Bookmarks, Activity, Profile), each with a named navigator key, rendered by `MainShell` with a Material 3 `NavigationBar`.
  - **Root-level screens:** `/posts/:postId` (+ `comments`), `/users/:userId`, `/compose`, `/edit-profile`, `/chats` (+ `:conversationId`) and `/settings`.
    - They are top-level routes, so they open in the root Navigator, **above** the tab bar.
    - `/compose` and `/edit-profile` are **full-screen dialogs**, via `buildPage` → `MaterialPage(fullscreenDialog: true)`.
  - **`authRedirect`:** a pure function of (signed in?, location) that the router runs before building any route.
  - **`createAppRouter`:** `refreshListenable` re-runs the redirect whenever the session changes. It also shows a "Page not found" screen for unknown locations.
- **Temporary session:** `PlaceholderSession`, a `ValueNotifier<bool>` registered in DI.
  - The Login placeholder's "Continue" signs in, and the Profile placeholder's "Log out" signs out.
  - Neither page navigates: the gate does it.
- **Dependency injection:** `configureDependencies()` (`get_it` + `injectable`), awaited in `main()`.
- **Placeholder screens** for all 15 destinations, each saying which phase fills it in. The final app-bar actions are already in place: Chats on the Feed, Settings on the Profile, and the New post FAB.
  - Temporary sample links open root-level screens; they go away as the real screens land.
- **Tests:** 40 tests:
  - the redirect rules;
  - every typed route's location;
  - app-level navigation (the gate, the tabs, the screens above the shell, the dialogs);
  - the theme and the WCAG contrast of its tokens;
  - the shared widgets;
  - a DI smoke test.
- **Docs:** the first `README.md` and this summary.

---

## 💙 Flutter / Dart Concepts Demonstrated

These are only the concepts that are new compared with MovieExplorer's foundation (FVM, `material_ui`, typed routes, `StatefulShellRoute` and `injectable` are covered in that repo's Phase 1).

- **A router-owned auth gate**
  - `GoRouter.redirect` runs before every navigation; returning a location reroutes, returning `null` continues.
  - `refreshListenable` re-runs the redirect when a `Listenable` notifies. A `ValueNotifier` *is* a `Listenable`, so the placeholder session plugs straight in.
  - Signing in or out therefore needs **no navigation code**: change the session, and the router moves the user.
- **A pure redirect function:** `authRedirect` takes plain values and returns a location, so every rule is a one-line unit test, with no widgets and no router.
- **Where a route lives decides where it opens**
  - A route declared inside a shell branch is pushed in that tab's Navigator, so the tab bar stays.
  - A top-level route is pushed in the **root** Navigator, so it covers the tab bar.
  - Back from a root-level screen returns to the tab with its state intact, because the whole shell sits underneath in the root Navigator's stack.
- **Full-screen dialogs with typed routes:** overriding `buildPage` instead of `build` returns `MaterialPage(fullscreenDialog: true)`. The page slides up and the `AppBar` shows a close button automatically: the Material counterpart of an iOS sheet.
- **Child routes for natural Back:** `/login/signup` and `/chats/:conversationId` are children of their list routes, so a deep link builds the parent underneath.
- **injectable and constructor parameters**
  - Every constructor parameter is treated as a dependency, including optional named ones.
  - `PlaceholderSession({bool signedIn = false})` first generated `PlaceholderSession(signedIn: gh<bool>())`, which would throw when resolved, because no `bool` is registered.
  - `@ignoreParam` tells injectable to leave the parameter alone.
  - A **DI smoke test** resolves the real container, so this class of bug fails in CI rather than at app start.
- **Contrast as a tested property:** WCAG relative luminance (`Color.computeLuminance`) checks that text on the `unread` tint keeps 4.5:1 and the heart keeps 3:1 against the surface, in both themes.
- **CI from day one**, including a check that the committed generated code is current.

---

## 🔁 Data Flow (this phase)

The session is the only "data" so far, and it flows into navigation:

```
Tap "Continue" ──▶ PlaceholderSession.signIn()          (value: false → true)
                       │ ValueNotifier notifies its listeners
                       ▼
       GoRouter.refreshListenable ──▶ re-runs redirect
                       │ authRedirect(isSignedIn: true, location: /login) → /feed
                       ▼
                   MainShell (NavigationBar) + FeedPage

Tap "Open a sample post" ──▶ PostDetailRoute(postId: 'p1').push<void>(context)
                       │ a top-level route → the root Navigator
                       ▼
       root stack: [MainShell (all 5 tabs alive), PostDetailPage]   ← the tab bar is covered
       Back ──▶ pops to MainShell, with the Feed still selected
```

The full data flow (`View → Cubit/Bloc → UseCase → Repository → fake API / drift`) arrives with real features in Phase 2+.

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `.fvmrc` | Pins Flutter 3.47.6 for this project. |
| `analysis_options.yaml` | Lints + strict analyzer modes; generated files stay analyzed. |
| `build.yaml` | `ignore_for_file: type=lint` headers on generated parts. |
| `.github/workflows/flutter-ci.yml` | CI: codegen check, format, analyze, test. |
| `lib/main.dart` | Bootstrap: binding → `configureDependencies()` → `runApp`. |
| `lib/app/connect_hub_app.dart` | Root widget: owns the router, builds `MaterialApp.router`. |
| `lib/core/design_system/theme/*.dart` | `AppTheme`, `AppColors`, spacing/radius/icon tokens. |
| `lib/core/design_system/widgets/*.dart` | `LoadingView`, `ErrorView`, `EmptyStateView`, `AppTextField`. |
| `lib/core/navigation/app_routes.dart` (+ `.g.dart`) | Every typed route: auth, shell, root-level. |
| `lib/core/navigation/app_router.dart` | `createAppRouter`: redirect + `refreshListenable` + not-found page. |
| `lib/core/navigation/auth_redirect.dart` | The pure sign-in gate. |
| `lib/core/navigation/placeholder_session.dart` | TEMPORARY session (replaced in Phase 2). |
| `lib/features/shell/main_shell.dart` | The `NavigationBar` around the five tabs. |
| `lib/features/**/<name>_page.dart` | Splash, plus placeholders for the other 14 screens. |
| `lib/di/injection.dart` (+ `.config.dart`) | The `get_it` + `injectable` composition root. |
| `test/core/navigation/*_test.dart` | Redirect rules, route locations, app-level navigation. |
| `test/di/injection_test.dart` | Smoke test of the real container. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `AppTheme` | `abstract final class` | Builds the light/dark `ThemeData` | `core/design_system`: shared by every screen |
| `AppColors` | `ThemeExtension` | `like` / `unread` semantic colors | travels with the theme, switches light/dark |
| `AppTextField` | `StatefulWidget` | Labelled input with error + password toggle | `core/design_system`: used by every form |
| `MainShellRoute` + 5 branch/route classes | typed routes | The tab shell | `core/navigation` |
| `PostDetailRoute`, `ChatRoute`, … | typed routes | Root-level screens above the shell | `core/navigation` |
| `authRedirect` | top-level function | The sign-in gate | `core/navigation`: the router's policy |
| `PlaceholderSession` | `ValueNotifier<bool>` | Temporary session for Phase 1 | `core/navigation`, until `AuthBloc` replaces it |
| `MainShell` | `StatelessWidget` | Hosts the `NavigationBar` | `features/shell`: Phase 6 provides session-scoped state here |

---

## 🌱 Folder Structure Changes

- Everything is new.
- Folders for later phases (`core/common`, `core/network/{api,dto,fake_server}`, `core/database`, `core/storage`, `data/*`, `domain/*`) are kept with `.gitkeep`.
- Every feature folder already exists, each with a placeholder page.

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Session gate | a `splash` route, then `auth_graph` or `main_graph` with `popUpTo` | `RootView` switches on `RootViewModel.phase` | go_router `redirect` + `refreshListenable` |
| Tabs | `NavigationBar` on the 5 tab routes of an inner `NavHost` (+ a drawer) | `TabView` with five `NavigationStack`s | `StatefulShellRoute` (5 branches) + `NavigationBar` |
| Detail screens | destinations in the inner `NavHost`; the bar is hidden | pushed inside the current tab's stack | top-level routes on the root Navigator, above the bar |
| Create Post / Edit Profile | separate destinations | `.sheet` | `fullscreenDialog` pages |
| Chats / Settings entry | the drawer | toolbar buttons | app-bar actions |
| Theme | Material 3 teal (`Color.kt`) | indigo `Theme.brand` | `ColorScheme.fromSeed(#0F766E)` + `AppColors` |
| Composition root | Hilt modules | `AppEnvironment` | `get_it` + `injectable` |
| CI | `android-ci.yml`, added in the last phase, on the wrong branch | `ios-ci.yml`, added in the last phase | `flutter-ci.yml` in Phase 1 |

The biggest conceptual difference is **who decides auth navigation**:
- **Android:** the splash ViewModel picks a graph *once* at startup, and screens navigate on success or logout with `popUpTo`.
- **iOS:** the root view model observes the session stream and swaps whole view trees.
- **Flutter:** the iOS idea, done declaratively by the router: the session is a `Listenable`, and a pure `redirect` maps (session, location) to where the user may be. No screen navigates for auth reasons.

---

## 🎤 Interview Notes

**Q: How does go_router's `redirect` work, and what is `refreshListenable` for?**
A: `redirect` runs before every navigation (and initial route). It returns a new location to reroute, or `null` to continue. On its own it only runs when someone navigates. `refreshListenable` makes the router re-run it whenever a `Listenable` changes, so a session change moves the user immediately, with no navigation call.

**Q: Why make the redirect a pure function?**
A: Navigation policy is easy to get subtly wrong: deep links, `/`, a path that merely starts with "login". A function of plain inputs can be tested row by row, without pumping widgets. The router just calls it.

**Q: Why put Post Detail at the top level of the route tree instead of inside a tab?**
A: It's reachable from several tabs. Inside the tabs, go_router_builder needs one route class per tab (MovieExplorer had three copies). As one top-level route it opens in the root Navigator, above the tab bar. That also suits full-screen screens such as a chat composer. Back still returns to the tab with its state, because the shell is underneath it in the root stack.

**Q: How do you present a screen as a full-screen dialog with typed routes?**
A: Override `buildPage` and return `MaterialPage(fullscreenDialog: true, key: state.pageKey, child: …)`. The route slides up and the `AppBar` shows a close button instead of Back.

**Q: Why did the DI container need `@ignoreParam`?**
A: injectable generates a call that resolves *every* constructor parameter from the container, including optional ones with defaults. A `bool signedIn = false` parameter became `gh<bool>()`, which throws at runtime because no `bool` is registered. `@ignoreParam` excludes it. A smoke test that resolves the real container now catches that class of mistake in CI.

**Q: Why test color contrast?**
A: Colors look fine until a tweak or the dark theme makes text unreadable; MovieExplorer shipped one such case before a manual pass caught it. Computing WCAG contrast from `Color.computeLuminance()` turns accessibility into a regression test.

**Q: Why CI in the first phase?**
A: Every push gets the same gate: format, analyze, test, and "is the committed generated code current?". Problems surface when they're introduced, not at the end. The Android edition's CI, added last, never ran because it targeted the wrong branch.

---

## 📝 Learning Checklist

- ✅ Pin a Flutter version per project with FVM, and migrate to `material_ui`
- ✅ Build Material 3 light/dark themes from a seed, with a `ThemeExtension` for app tokens
- ✅ Test WCAG contrast of theme tokens
- ✅ Gate navigation on a session with `redirect` + `refreshListenable`
- ✅ Write the gate as a pure, unit-tested function
- ✅ Combine a `StatefulShellRoute` with root-level routes above it
- ✅ Present full-screen dialogs from typed routes (`buildPage`)
- ✅ Set up a `get_it` + `injectable` composition root, with a smoke test
- ✅ Set up CI that checks codegen, format, analysis and tests
- ⬜ Model the session with an event-driven `AuthBloc` and secure storage (Phase 2)
- ⬜ Build validated forms with Blocs and `droppable()` (Phase 2)
- ⬜ Cache the feed offline in drift with optimistic updates (Phase 3)
- ⬜ Debounce search, persist settings, run a realtime chat (Phases 5–6)

---

## 🚀 Future Improvements

- **Phase 2:** an in-memory fake auth server, the session in secure storage, `AuthBloc` driving the same gate, the splash while restoring, Login/Sign Up forms, and a `from` return address so a deep link survives signing in. It also removes `PlaceholderSession`.
  - Once `from` can land the user directly on a root-level screen, that screen has nothing underneath to go back to. Root-level screens then need a "back to the Feed" fallback.
- **Phases 3–6** replace the placeholders one by one, and remove the temporary sample links.
- **Adaptive layout:** a `NavigationRail` on tablets would be a natural extension of the shell (out of scope).
