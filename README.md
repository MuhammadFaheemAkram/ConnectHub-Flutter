# 💬 ConnectHub (Flutter)

[![Flutter CI](https://github.com/MuhammadFaheemAkram/ConnectHub-Flutter/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/MuhammadFaheemAkram/ConnectHub-Flutter/actions/workflows/flutter-ci.yml)
![Flutter 3.47.6](https://img.shields.io/badge/Flutter-3.47.6-02569B?logo=flutter)
![Dart 3.13](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A learning-focused, production-inspired **Flutter** social app: a simplified LinkedIn/Twitter-style feed with messaging. It is built with **Flutter 3.47**, **Dart 3.13** and a clean, layered architecture.

Everything is backed by a **fake, in-memory backend**, so the app runs with **no API key and no server**. The point is *how an app talks to a backend*, not the backend itself.

> **Why this repo exists**
>
> It is the Flutter edition of an app that also exists natively for [Android](https://github.com/MuhammadFaheemAkram/ConnectHub) and [iOS](https://github.com/MuhammadFaheemAkram/iConnectHub). Those editions are references for the features; this one focuses on concepts and architecture:
> - an **auth flow** driven by the router (`redirect` + `refreshListenable`);
> - **Bloc** where events earn their place (session, auth forms, search) and **Cubit** everywhere else;
> - an **offline-first cache** in drift, with optimistic updates, rollback and cursor pagination;
> - a **realtime chat** with a simulated reply and a typing indicator;
> - code-generated DI (`get_it` + `injectable`), typed `go_router` navigation, and a real test suite.
>
> Each phase ships with a beginner-to-intermediate friendly write-up in [`docs/`](docs/) that also shows how the Android and iOS editions solved the same problem.

---

## 📋 Project Status

ConnectHub is built in **strict, reviewable phases**. Each phase ends with:
- a building app (Android + iOS);
- a clean analyzer and passing tests;
- a summary doc;
- exactly one commit.

| Phase | Scope | Status |
|------:|-------|:------:|
| 1 | Foundation: FVM project, design system base, typed routes with a sign-in gate, 5-tab shell, CI | ✅ Done |
| 2 | Fake auth + session (secure storage, `AuthBloc`, Login / Sign Up) | ⏳ Next |
| 3 | Feed + fake network + offline cache (drift) | ⬜ |
| 4 | Post detail + comments + create post | ⬜ |
| 5 | Search + bookmarks + profile | ⬜ |
| 6 | Chat + notifications + settings | ⬜ |
| 7 | Open-source polish and final docs | ⬜ |

---

## ✨ Features (target scope)

- 🔐 **Sign up / sign in** with a fake backend; the session survives restarts
- 📰 A **feed** with pull to refresh, infinite scroll, likes and bookmarks (optimistic, with rollback)
- 💬 **Post details** and **comments** (add, and delete your own); **create a post**
- 🔎 **Search** people and posts (debounced), with recent searches
- 🔖 **Bookmarks** that work offline
- 🔔 **Activity**: like / comment / follow / mention notifications, with read state and a live badge
- 📨 **Chat** with a simulated reply and a typing indicator
- 👤 **Profiles**: your own and other people's; edit your own
- ⚙️ **Settings**: appearance (System / Light / Dark), badges, language, clear cache, developer tools

---

## 🧰 Tech Stack

| Area | Choice | Since |
|------|--------|:-----:|
| Toolchain | Flutter 3.47.6 · Dart 3.13, pinned per project with [FVM](https://fvm.app) (`.fvmrc`) | 1 |
| Platforms | Android · iOS 15+ | 1 |
| UI | [`material_ui`](https://pub.dev/packages/material_ui): Material 3 as a standalone package | 1 |
| Navigation | `go_router` + `go_router_builder` (typed routes, `StatefulShellRoute`, sign-in `redirect`) | 1 |
| Dependency injection | `get_it` + `injectable` (a code-generated composition root) | 1 |
| State management | `flutter_bloc` (Blocs for the session, auth forms and search; Cubits elsewhere) | 2 |
| Models | `freezed` + `json_serializable` | 2 |
| Session token | `flutter_secure_storage` (Keychain / Android Keystore) | 2 |
| Database | `drift` (SQLite), with migrations | 3 |
| Images | `cached_network_image` | 3 |
| Preferences | `shared_preferences` (`SharedPreferencesWithCache`) | 6 |
| Testing | `flutter_test`, `bloc_test`, `mocktail` | 1+ |
| Lints / CI | `flutter_lints` + strict analyzer modes; GitHub Actions | 1 |

---

## 🏛️ Architecture

A clean, layered architecture with a one-directional data flow:

```
lib/
├── app/        → root widget (MaterialApp.router, themes)
├── core/       → design system, navigation, network (fake API), database, storage, common
├── data/       → repository implementations + mappers
├── domain/     → entities, repository contracts, use cases (pure Dart)
├── features/   → one folder per screen (Page + View + Cubit/Bloc)
└── di/         → composition root (get_it + injectable)
```

**Navigation and the sign-in gate** (Phase 1):

```
GoRouter ── redirect: authRedirect(session, location)   ◀── refreshListenable: the session
  │
  ├─ auth routes      /splash, /login, /login/signup         (the only ones reachable while signed out)
  │
  ├─ tab shell        StatefulShellRoute ── MainShell (NavigationBar)
  │                     /feed · /search · /bookmarks · /activity · /profile
  │
  └─ root-level       /posts/:postId (+ /comments), /users/:userId, /compose, /edit-profile,
     screens          /chats (+ /:conversationId), /settings      → pushed above the tab bar
```

Key rules:
- **The router owns the gate.** Screens never check "am I signed in?". `authRedirect` is a pure function, and when the session changes, `refreshListenable` re-runs it.
- **Typed routes only:** no string paths in widgets.
- **Details sit above the tabs.** They are reachable from several tabs, so each is one route on the root navigator. The tabs keep their state underneath.
- **Widgets render state; logic lives elsewhere.** Each screen is a Page plus a View (from Phase 2 on).
- **Layer boundaries:** `domain/` is pure Dart, and Views never import `data/`.

---

## 🗂️ Folder Structure

```
ConnectHub/
├── .fvmrc                          # pinned Flutter version (3.47.6)
├── .github/workflows/flutter-ci.yml
├── analysis_options.yaml           # lints + strict analyzer modes
├── build.yaml                      # lint-free generated files
├── lib/
│   ├── main.dart                   # binding → configureDependencies() → runApp
│   ├── app/connect_hub_app.dart
│   ├── core/
│   │   ├── design_system/          # theme/ (AppTheme, AppColors, tokens) + widgets/
│   │   ├── navigation/             # app_routes (+ .g.dart), app_router, auth_redirect, placeholder_session
│   │   └── common/ network/ database/ storage/   # filled in Phases 2–6
│   ├── data/  domain/              # Phase 2+
│   ├── features/                   # splash, auth, shell, feed, search, bookmarks, activity, profile,
│   │                               # post_detail, comments, create_post, edit_profile, chats, chat_detail, settings
│   └── di/                         # injection.dart (+ .config.dart)
└── test/                           # mirrors lib/, plus helpers/
```

---

## ▶️ How to Run

Prerequisites:
- [FVM](https://fvm.app);
- Xcode, for iOS;
- the Android SDK, with Java 17+ (Android Studio's bundled JDK works).

```bash
fvm install            # installs the version pinned in .fvmrc (3.47.6)
fvm flutter pub get
fvm flutter run        # pick an Android emulator or an iOS simulator
```

Generated code (`*.g.dart`, `*.config.dart`) is committed, so the app runs straight after cloning. After changing annotated code, regenerate it:

```bash
fvm dart run build_runner build
```

In Phase 1, sign-in is a placeholder: **Continue** on the Login screen signs in, and **Log out** on the Profile tab signs out.

---

## ✅ Testing

```bash
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed .
fvm flutter test
```

**40 tests** after Phase 1:
- **The sign-in gate:**
  - every rule of `authRedirect`;
  - the real app: signing in and out, deep links while signed out, Sign Up over Login.
- **Navigation:**
  - the five tabs;
  - the root-level screens cover the tab bar, and Back returns to the same tab;
  - the full-screen dialogs;
  - every typed route's location.
- **Design system:**
  - the themes and `AppColors`, including WCAG contrast checks;
  - the state views and `AppTextField`.
- **DI:** a smoke test that resolves the real container.

CI (`.github/workflows/flutter-ci.yml`) runs on every push to `main` and every pull request. It installs the FVM-pinned Flutter, checks that the committed generated code is up to date, then runs format, analyze and test.

---

## 📱 Same App on Other Platforms

| Edition | Stack | Repo |
|---------|-------|------|
| Android | Kotlin · Jetpack Compose · Hilt · Room · DataStore | [MuhammadFaheemAkram/ConnectHub](https://github.com/MuhammadFaheemAkram/ConnectHub) |
| iOS | Swift 6 · SwiftUI · SwiftData · actors | [MuhammadFaheemAkram/iConnectHub](https://github.com/MuhammadFaheemAkram/iConnectHub) |
| **Flutter** | Dart · Flutter · Bloc · drift | this repo |

| Concept | Android | iOS | Flutter |
|---|---|---|---|
| UI | Jetpack Compose | SwiftUI | widgets + `material_ui` |
| Screen state | ViewModel + StateFlow | `@Observable` view models | Cubit / Bloc |
| Session gate | splash + nav graphs | `RootView` phase switch | go_router `redirect` + `refreshListenable` |
| Tabs | `NavigationBar` + drawer | `TabView` | `StatefulShellRoute` + `NavigationBar` |
| DI | Hilt | `AppEnvironment` | `get_it` + `injectable` |
| Cache | Room | SwiftData | drift |
| Session token | DataStore | UserDefaults | `flutter_secure_storage` |

---

## 📚 Documentation

- [Phase 1 — Foundation](docs/PHASE_1_SUMMARY.md)

---

## 🗺️ Roadmap

The remaining phases are listed in the status table above. Each one adds a feature slice end to end: fake API, repository, drift, Cubit/Bloc, screen and tests.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse
