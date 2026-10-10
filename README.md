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
| 2 | Fake auth + session: in-memory fake server, secure storage, `AuthBloc`, Login / Sign Up | ✅ Done |
| 3 | Feed + fake network + offline cache: drift v1, cursor paging, optimistic likes and bookmarks | ✅ Done |
| 4 | Post detail + comments + create post | ⏳ Next |
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
| Event transformers | `bloc_concurrency` (`droppable` submits, a `restartable` session subscription) | 2 |
| Models | `freezed` + `json_serializable` | 2 |
| Session token | `flutter_secure_storage` (Keychain / Android Keystore) | 2 |
| Database | `drift` + `drift_flutter` (SQLite): the offline cache, with foreign keys and exported schema versions | 3 |
| Images | `cached_network_image` (avatars and post images, with fallbacks offline) | 3 |
| Time and formatting | `clock` (an injectable `Clock`), `intl` (dates, compact counts like "4.8K") | 3 |
| Async coordination | `synchronized` (a `Lock`, so refresh and load-more take turns) | 3 |
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

**Navigation and the sign-in gate:**

```
GoRouter ── redirect: authRedirect(AuthBloc.state, location)   ◀── refreshListenable: AuthBloc.stream
  │
  ├─ auth routes      /splash, /login, /login/signup         (the only ones reachable while signed out)
  │
  ├─ tab shell        StatefulShellRoute ── MainShell (NavigationBar)
  │                     /feed · /search · /bookmarks · /activity · /profile
  │
  └─ root-level       /posts/:postId (+ /comments), /users/:userId, /compose, /edit-profile,
     screens          /chats (+ /:conversationId), /settings      → pushed above the tab bar
```

**Signing in** (Phase 2):

```
LoginView ── LoginSubmitted ──▶ LoginBloc (droppable) ──▶ LoginUseCase ──▶ AuthRepository
                                                                  │  ApiGuard.run(...)
                                                                  ▼
                                    FakeAuthApiService ── NetworkSimulator (latency, failures)
                                                                  │
                                                                  ▼
                                                    FakeServer (in memory) ─▶ token + profile
AuthRepository ─▶ SessionRepository.save ─▶ SessionStorage (Keychain / Keystore)
                         │ emits SignedIn
                         ▼
     AuthBloc ─▶ authenticated ─▶ router re-runs the gate ─▶ the Feed (or the return address)
```

**The feed, offline-first** (Phase 3):

```
View ─intent─▶ FeedCubit ─▶ UseCase ─▶ FeedRepository ─┬─ read ──▶ drift (cache) ─ watch() ─▶ FeedCubit ─ state ─▶ View
                                                       └─ refresh / load more ─▶ FeedApiService ─▶ FakeServer (in memory)
                                                                                    ▲ token from secure storage
```

Key rules:
- **Screens read only the cache.** Repositories refresh drift from the API, and the change reaches every screen through drift's streams. Cached posts show at once, even offline.
- **Optimistic writes live in repositories.** A like is written to drift first, then sent; a failure rolls it back and the screen only reports it.
- **The router owns the gate.** Screens never check "am I signed in?" or navigate after a sign-in or a logout. `authRedirect` is a pure function, and `refreshListenable` re-runs it whenever the `AuthBloc`'s state changes.
- **A return address survives the gate.** A deep link (or a screen open when the session expires) travels as `?from=` through the splash, Login and Sign Up. A deliberate logout drops it.
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
│   │   ├── common/                 # Result, AppException, UiMessage, validators, relative_time, compact_count, IdGenerator, …
│   │   ├── navigation/             # app_routes (+ .g.dart), app_router, auth_redirect, stream_listenable, back_to_feed_button
│   │   ├── network/                # api/ (contracts, fakes, FakeApiClient), dto/, fake_server/, asset_json_loader
│   │   ├── storage/                # session_storage (flutter_secure_storage)
│   │   └── database/               # app_database (drift v1), tables/, daos/ (posts, feed, cache)
│   ├── data/                       # mapper/, repository/ (auth, session, feed, post, ApiGuard)
│   ├── domain/                     # model/ (User, Post, Session, …), repository/, usecase/
│   ├── features/                   # splash, auth, shell, feed, search, bookmarks, activity, profile,
│   │                               # post_detail, comments, create_post, edit_profile, chats, chat_detail, settings
│   └── di/                         # injection.dart (+ .config.dart), app_module.dart
├── drift_schemas/                  # every exported schema version (drift_dev make-migrations)
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

**Signing in:** tap **Use demo account**, then **Sign in** (`demo@connecthub.app` / `connecthub`). You can also create an account. The fake server lives in memory, so accounts you create last until the app restarts. The demo account always exists, so its session survives restarts.

---

## 🌐 How the Fake Backend Works

There is no server. `FakeServer` is an in-memory stand-in that owns the data and its rules: accounts, tokens, posts, likes and bookmarks now; comments and chats in later phases.
- **Seed:** it seeds itself on first use from [`assets/json/`](assets/json/): the iOS edition's JSON, plus two posts by the demo user (`p16`, `p17`) and the two comments on them (`c12`, `c13`).
- **Fresh dates:** every seed date is shifted by the same amount at launch, so the newest record is five minutes old and the feed always looks recent. Gaps between records are kept.
- **Server rules:** likes and bookmarks are per user and idempotent; `likeCount` starts from the seed and moves with likes; `commentCount` is always counted from the comments themselves (the iOS seed claims 18 comments on `p1` and ships 3).
- **Paging:** the feed comes newest first in pages of 6, each ending with an opaque cursor (`<createdAt>|<id>`). The 17 posts arrive as 6 / 6 / 5.
- **Access:** the app reaches it only through Retrofit-style API services (`AuthApiService`, `FeedApiService` and their `Fake…` implementations), so a real `dio` client could replace them without changing any caller. `FakeApiClient` plays the HTTP client: it attaches the saved token, crosses the simulated network, and lets the server resolve the token (a 401 if it can't).
- **Transport:** `NetworkSimulator` adds latency (800 ms for sign-in, 700 ms for a feed page, 350 ms for a like) and can fail every request, as if offline (`AppConfig.simulateNetworkErrors`).
- **Errors:** the server throws typed `AppException`s:
  - "Incorrect email or password." for a wrong password *or* an unknown email;
  - "An account with this email already exists.";
  - a 401 for a bad token.
- **Tokens:** they look like `fake.<userId>.<random>`. Any token for an existing user is valid, so the demo session survives restarts.

## 🔐 How the Session Is Stored

- **Secure storage:** the session (token, user id and email) is stored with `flutter_secure_storage`, which uses the iOS Keychain or the Android Keystore. A token is a credential: it doesn't belong in `shared_preferences`, which are plain files.
- **No Android backup:** `android:allowBackup="false"` keeps it out of cloud backups. Restored Keystore data can't be decrypted on another device anyway.
- **Restore:** `SessionRepository.watchSession()` emits the restored state, then every change: signed in, or signed out with a reason (`none`, `loggedOut`, `expired`). The `AuthBloc` follows it with `emit.forEach`.
- **Expiry:** `ApiGuard` wraps every API call. A 401 expires the session once, for every repository, and Login then says why.

---

## 💾 How the Offline Cache Works

The fake server owns the data; drift (SQLite) holds the client's copy of it.

| Data | Source of truth | Client copy |
|---|---|---|
| profiles, posts, likes, bookmarks | the fake server | drift (cache) |
| session (token, user id, email) | the client | `flutter_secure_storage` |

- **Schema v1:** `users`, `posts` (→ `users`), `feed_items` (the feed window, → `posts`) and `bookmarks` (→ `posts`), with foreign keys turned on (`PRAGMA foreign_keys = ON`). Every schema version is exported to [`drift_schemas/`](drift_schemas/) with `drift_dev make-migrations`, so later phases ship tested migrations.
- **The feed is its own table.** `feed_items` lists which cached posts are in the feed. A refresh replaces exactly that list, and posts cached by other screens never leak into the feed.
- **Upserts, never REPLACE.** SQLite's REPLACE deletes the old row first, and the delete cascades: that is how the Android edition silently lost bookmarks. Every write here is `INSERT … ON CONFLICT DO UPDATE` (a test shows what REPLACE would have done).
- **Reads JOIN `users`**, so renaming a person renames every post they wrote at once.
- **Optimistic likes and bookmarks:** drift first, then the server. The server's answer replaces the guess; a failure restores the state from before the tap. A second tap while a request is out is ignored.
- **The cache belongs to one user.** Logout and session expiry wipe it before the token is deleted, and an answer that arrives after the session ended is dropped instead of being cached for the next user.

## ✅ Testing

```bash
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed .
fvm flutter test
```

**236 tests** after Phase 3:
- **Feed** (Phase 3):
  - the fake server's feed slice: rebased dates, derived comment counts, pages 6 / 6 / 5 with no overlap, idempotent likes, per-user bookmarks;
  - drift: the feed JOIN and its order, window replace and append, foreign keys, and the REPLACE-cascade regression;
  - `FeedRepository` / `PostRepository` on the real fake server: paging, refresh and load-more taking turns, optimistic writes with rollback;
  - `FeedCubit` (`bloc_test`): loading / empty / error / loaded with no "empty" flash, refresh failures, load-more states, failure messages;
  - the Feed view (`MockCubit`), `PostCard`, `UserAvatar` and relative time;
  - app-level: likes, a failed refresh offline, a real 401 ending the session, logout wiping the cache.
- **Auth** (Phase 2):
  - the validators;
  - the fake server (accounts, tokens, restarts) and the fake API;
  - secure session storage;
  - `SessionRepository` (current state, then changes; a sign-in during the restore wins);
  - `AuthRepository` and `ApiGuard`.
- **Blocs** (`bloc_test`):
  - `AuthBloc`;
  - `LoginBloc` / `SignUpBloc`: quiet errors until the first submit, then live, plus trimming and `droppable()` double submits.
- **Views** (`MockBloc`): the Login and Sign Up forms.
- **The gate:**
  - every rule of `authRedirect`, including unsafe return addresses;
  - app-level flows on the real stack: demo sign-in, a wrong password, sign-up, logout with confirmation, a deep link through sign-in, an expired session.
- **Navigation:** the five tabs, the root-level screens above the shell, the full-screen dialogs, typed locations.
- **Design system:** themes and contrast, and the shared widgets.
- **DI:** a smoke test of the real container.

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
| Session gate | splash + nav graphs | `RootView` phase switch | `AuthBloc` + go_router `redirect` + `refreshListenable` |
| Tabs | `NavigationBar` + drawer | `TabView` | `StatefulShellRoute` + `NavigationBar` |
| DI | Hilt | `AppEnvironment` | `get_it` + `injectable` |
| Cache | Room | SwiftData | drift |
| Session token | DataStore | UserDefaults | `flutter_secure_storage` |
| Pagination | offset, "Load more" | offset, `onAppear` | cursor, infinite scroll |
| Optimistic like | Room first, no rollback | local only | drift first, rolled back on failure |

---

## 📚 Documentation

- [Phase 1 — Foundation](docs/PHASE_1_SUMMARY.md)
- [Phase 2 — Fake Auth + Session](docs/PHASE_2_SUMMARY.md)
- [Phase 3 — Feed + Offline Cache](docs/PHASE_3_SUMMARY.md)

---

## 🗺️ Roadmap

The remaining phases are listed in the status table above. Each one adds a feature slice end to end: fake API, repository, drift, Cubit/Bloc, screen and tests.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse
