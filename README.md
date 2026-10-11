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

ConnectHub was built in **strict, reviewable phases**. Each phase ended with:
- a building app (Android + iOS);
- a clean analyzer and passing tests;
- a summary doc;
- exactly one commit.

**All seven phases are complete.**

| Phase | Scope | Status |
|------:|-------|:------:|
| 1 | Foundation: FVM project, design system base, typed routes with a sign-in gate, 5-tab shell, CI | ✅ Done |
| 2 | Fake auth + session: in-memory fake server, secure storage, `AuthBloc`, Login / Sign Up | ✅ Done |
| 3 | Feed + fake network + offline cache: drift v1, cursor paging, optimistic likes and bookmarks | ✅ Done |
| 4 | Post detail, comments and create post; drift v2 with a tested migration | ✅ Done |
| 5 | Search (debounced, live results), offline bookmarks with Undo, profiles and editing; drift v3 | ✅ Done |
| 6 | Chat (ordered sends, retry, typing, realtime replies), Activity with badges, Settings; drift v4 | ✅ Done |
| 7 | Open-source polish: final docs, screenshots, community files, a dark-mode and large-text accessibility pass | ✅ Done |

---

## ✨ Features

- 🔐 **Sign up / sign in** with a fake backend; the session survives restarts
- 📰 A **feed** with pull to refresh, infinite scroll, likes and bookmarks (optimistic, with rollback)
- 💬 **Post details** and **comments** (add, and delete your own); **create a post**
- 🔎 **Search** people and posts (debounced, live results), with recent searches
- 🔖 **Bookmarks** that work offline, with Undo
- 🔔 **Activity**: like / comment / follow / mention notifications with filters, a read state the server owns, links to the post or profile, and a live tab badge
- 📨 **Chat**: messages show at once and go out in order; a failed one says "Not sent · Tap to retry"; the other person types, then replies, over a realtime channel
- 👤 **Profiles**: your own and other people's; edit your own
- ⚙️ **Settings**: appearance (System / Light / Dark, applied from the first frame), unread badges, language, clear cache, developer switches (offline, expire session), log out, About
- ♿ **Accessible**: every screen works in dark mode and at large text sizes, with labelled controls and 48 × 48 tap targets, checked by a test tour of every screen

---

## 📸 Screenshots

| Feed | Post | Chat (dark) | Activity (dark) |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/feed-light.png" width="190" alt="Feed: posts with likes, comments and bookmarks, and unread badges on Chats and Activity"> | <img src="docs/screenshots/post-detail-light.png" width="190" alt="A post with its comments and a comment field"> | <img src="docs/screenshots/chat-typing-dark.png" width="190" alt="A chat in dark mode, with the other person typing"> | <img src="docs/screenshots/activity-dark.png" width="190" alt="Activity in dark mode: filters and unread notifications"> |

More (Login, Search, profiles, Chats, Settings, and large text) in [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md).

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
| Event transformers | `bloc_concurrency` (`droppable` submits, a `restartable` session subscription, debounce + `restartable` search) | 2 |
| Models | `freezed` + `json_serializable` | 2 |
| Session token | `flutter_secure_storage` (Keychain / Android Keystore) | 2 |
| Database | `drift` + `drift_flutter` (SQLite): the offline cache, with foreign keys and exported schema versions | 3 |
| Images | `cached_network_image` (avatars and post images, with fallbacks offline) | 3 |
| Time and formatting | `clock` (an injectable `Clock`), `intl` (dates, compact counts like "4.8K") | 3 |
| Async coordination | `synchronized` (a `Lock`: refresh and load-more take turns, and chat messages go out in order) | 3 |
| Text | `characters` (the 280-character limit counts what people see: an emoji is one) | 4 |
| Stream operators | `stream_transform` (`switchMap` for the search debounce, `combineLatest` for live results) | 5 |
| Preferences | `shared_preferences` (`SharedPreferencesWithCache`, loaded before `runApp`) | 6 |
| App info | `package_info_plus` (the version and build in About) | 6 |
| Testing | `flutter_test`, `bloc_test`, `mocktail`, `fake_async`; `flutter_cache_manager` for an offline image cache in tests | 1+ |
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

**Data flow, offline-first** (every screen since Phase 3):

```
View ─intent─▶ Cubit / Bloc ─▶ UseCase ─▶ Repository ─┬─ read ──▶ drift (cache) ─ watch() ─▶ Cubit ─ state ─▶ View
                                                      └─ write / refresh ─▶ ApiService ─▶ FakeServer (in memory, seeded from assets/json)
                                                                              ▲ token from secure storage
```

**Search, kept live** (Phase 5):

```
AppSearchField ─ keystrokes ─▶ SearchBloc ── debounce 300 ms (switchMap) + restartable ──▶ SearchRepository.search
                                                                                              │ caches people + posts in drift
                                                                                              ▼ answers with their ids
View ◀─ state ◀─ emit.forEach(watchResults(ids)) ◀─ drift (users, posts) ◀── a like or an edit on any screen
                 (the next query's restart ends this subscription)
```

**Chat: ordered sends, a realtime channel** (Phase 6):

```
Send ─▶ ChatRepository.sendMessage ─▶ drift: the message, "sending", with an id made on the client
                                    └▶ Lock (one at a time, in order) ─▶ ChatApiService.sendMessage(clientId)
                                         ─▶ sent (the server's time)  or  failed ("Not sent · Tap to retry")
                                       retry ─▶ the same id ─▶ the server recognizes it: no duplicate

FakeServer ─ ReplyScheduler ─▶ typing started ─▶ reply ─▶ typing stopped     (on the realtime channel)
ChatRepository: events() (one subscription per session, handled in order) ─▶ typing map │ drift (message + conversation)
ChatDetailCubit ◀─ watchMessages (keeps the chat "open": replies stay read) + watchTyping
```

Key rules:
- **Screens read only the cache.** Repositories refresh drift from the API, and the change reaches every screen through drift's streams. Cached posts show at once, even offline.
- **Optimistic writes live in repositories.** A like is written to drift first, then sent; a failure rolls it back and the screen only reports it.
- **The router owns the gate.** Screens never check "am I signed in?" or navigate after a sign-in or a logout. `authRedirect` is a pure function, and `refreshListenable` re-runs it whenever the `AuthBloc`'s state changes.
- **A return address survives the gate.** A deep link (or a screen open when the session expires) travels as `?from=` through the splash, Login and Sign Up. A deliberate logout drops it.
- **Typed routes only:** no string paths in widgets.
- **Details sit above the tabs.** They are reachable from several tabs, so each is one route on the root navigator. The tabs keep their state underneath.
- **My profile is a tab.** `/users/<my id>` redirects to `/profile`, and tapping my own name switches to that tab instead of pushing a copy.
- **App-wide state sits above `MaterialApp`; session state in the shell.** The `AuthBloc` and the `SettingsCubit` (the theme) live above the router; the `BadgesCubit` lives in the tab shell, which exists only while signed in.
- **Widgets render state; logic lives elsewhere.** Each screen is a Page plus a View (from Phase 2 on).
- **Layer boundaries:** `domain/` is pure Dart, and Views never import `data/`.

The layers, every screen's state holder, the error handling and the key decisions are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## 🗂️ Folder Structure

```
ConnectHub/
├── .fvmrc                          # pinned Flutter version (3.47.6)
├── .github/                        # workflows/flutter-ci.yml, issue and PR templates
├── analysis_options.yaml           # lints + strict analyzer modes
├── build.yaml                      # lint-free generated files, drift options
├── CHANGELOG.md · CONTRIBUTING.md · CODE_OF_CONDUCT.md · SECURITY.md · LICENSE
├── assets/json/                    # the fake server's seed
├── lib/
│   ├── main.dart                   # binding → configureDependencies() → runApp
│   ├── app/                        # connect_hub_app (AuthBloc + SettingsCubit above the router), theme_mode_mapper
│   ├── core/
│   │   ├── design_system/          # theme/ (AppTheme, AppColors, tokens), widgets/, large_text (the stacking rule)
│   │   ├── common/                 # Result, AppException, UiMessage, validators, relative_time, compact_count, IdGenerator, …
│   │   ├── navigation/             # app_routes (+ .g.dart), app_router, auth_redirect, stream_listenable, back_to_feed_button
│   │   ├── network/                # api/ (contracts, fakes, FakeApiClient), dto/, fake_server/, asset_json_loader
│   │   ├── storage/                # session_storage (flutter_secure_storage), settings_local_data_source (shared_preferences)
│   │   └── database/               # app_database (drift v4), tables/, daos/ (posts, feed, comments, users, bookmarks, search, chat, notifications, cache)
│   ├── data/                       # mapper/, repository/ (auth, session, feed, post, comment, search, bookmark, profile, chat,
│   │                               #   notification, settings, cache, demo tools, ApiGuard)
│   ├── domain/                     # model/ (User, Post, Session, …), repository/, usecase/
│   ├── features/                   # splash, auth, shell, feed, search, bookmarks, activity, profile,
│   │                               # post_detail, comments, create_post, edit_profile, chats, chat_detail, settings
│   └── di/                         # injection.dart (+ .config.dart), app_module.dart
├── drift_schemas/                  # every exported schema version (drift_dev make-migrations)
├── docs/                           # architecture, testing, API simulation, notes, roadmap, screenshots, phase summaries
└── test/                           # mirrors lib/, plus app/ (the accessibility tour), helpers/ and flutter_test_config.dart
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

There is no server. `FakeServer` is an in-memory stand-in that owns the data and its rules: accounts, tokens, profiles, posts, likes, bookmarks, comments, search, chats and notifications.
- **Seed:** it seeds itself on first use from [`assets/json/`](assets/json/): the iOS edition's JSON, plus two posts by the demo user (`p16`, `p17`) and the two comments on them (`c12`, `c13`). Notifications also link to what they are about (a post or a person).
- **Fresh dates:** every seed date is shifted by the same amount at launch, so the newest record is five minutes old and the feed always looks recent. Gaps between records are kept.
- **Server rules:** likes and bookmarks are per user and idempotent; `likeCount` starts from the seed and moves with likes; `commentCount` is always counted from the comments themselves (the iOS seed claims 18 comments on `p1` and ships 3).
- **Paging:** the feed comes newest first in pages of 6, each ending with an opaque cursor (`<createdAt>|<id>`). The 17 posts arrive as 6 / 6 / 5.
- **Posts and comments:** a new post is written by whoever the token belongs to and heads the first page. Comments come oldest first. Only a comment's author may delete it; anyone else gets a 404, as many real APIs answer, so a stranger can't confirm the comment exists. A request that breaks the rules (a blank post, over 280 characters, a bad image URL) is refused like a 400.
- **Search, profiles and bookmarks:** search is case-insensitive "contains": people by name or bio (never you), the most followed first; posts by content or author name, newest first. A profile edit is validated like the client and stored trimmed. Posts and comments store their author's *id*, so a new name shows on everything that person wrote. Bookmarks come back the most recently bookmarked first.
- **Chat:**
  - **Client ids:** a message keeps the id the client made for it. Sending the same id again returns the stored message: a retry can't post it twice.
  - **Replies:** after each message, the other person types (400 ms later), then answers (1.5 s after that): "Good question — let me think about that. 🤔" to a question, otherwise eight canned answers in turn. Typing stops after the *last* pending reply, so quick messages keep one indicator on. A reply raises the unread count.
  - **The realtime channel** (`chatEvents`) pushes typing and replies to the client, per user.
- **Notifications:** newest first; the read state is the server's, so a refresh never resets it.
- **Access:** the app reaches it only through Retrofit-style API services (`AuthApiService`, `FeedApiService`, `CommentApiService`, `SearchApiService`, `UserApiService`, `ChatApiService`, `NotificationApiService` and their `Fake…` implementations), so a real `dio` client could replace them without changing any caller. Settings → Developer goes through one more, `DeveloperToolsService`. `FakeApiClient` plays the HTTP client: it attaches the saved token, crosses the simulated network, and lets the server resolve the token (a 401 if it can't).
- **Transport:** `NetworkSimulator` adds latency (800 ms for sign-in, 700 ms for a feed page, 500 ms for a profile or the notifications, 400 ms for a search or the chats, 350 ms for a like or a message) and can fail every request, as if offline: Settings → Developer → "Simulate network failure" (it starts from `AppConfig.simulateNetworkErrors`).
- **Errors:** the server throws typed `AppException`s:
  - "Incorrect email or password." for a wrong password *or* an unknown email;
  - "An account with this email already exists.";
  - a 401 for a bad token.
- **Tokens:** they look like `fake.<userId>.<random>`. Any token for an existing user is valid, so the demo session survives restarts, unless Settings → Developer → "Expire session" revoked it: the next request then answers 401.
- **In memory:** the server starts from the seed at every launch. Chats you had, likes you made and accounts you created are gone after a restart; the client's cache mirrors that on its next refresh, but keeps the messages it hasn't managed to send.

Every service, latency, seed file, rule and error is listed in [docs/API_SIMULATION.md](docs/API_SIMULATION.md).

## 🔐 How the Session Is Stored

- **Secure storage:** the session (token, user id and email) is stored with `flutter_secure_storage`, which uses the iOS Keychain or the Android Keystore. A token is a credential: it doesn't belong in `shared_preferences`, which are plain files.
- **No Android backup:** `android:allowBackup="false"` keeps it out of cloud backups. Restored Keystore data can't be decrypted on another device anyway.
- **Restore:** `SessionRepository.watchSession()` emits the restored state, then every change: signed in, or signed out with a reason (`none`, `loggedOut`, `expired`). The `AuthBloc` follows it with `emit.forEach`.
- **Expiry:** `ApiGuard` wraps every API call. A 401 expires the session once, for every repository, and Login then says why.

---

## ⚙️ How Settings Are Stored

- **`shared_preferences`, read before the first frame.** Appearance, the badges switch and the language are small, non-secret values the device owns, so they live in `SharedPreferencesWithCache` (not the Keychain, not drift). It is created before `runApp` (`@preResolve` in `AppModule`), so every read after that is synchronous: the app-scoped `SettingsCubit` starts with the saved theme, and a saved Dark never flashes light.
- **Device, not account:** logging out keeps them.
- **The developer switches are not settings.** "Simulate network failure" lives in memory and resets on restart; "Expire session" revokes the token on the fake server.

## 💾 How the Offline Cache Works

The fake server owns the data; drift (SQLite) holds the client's copy of it.

| Data | Source of truth | Client copy |
|---|---|---|
| profiles, posts, likes, bookmarks, comments | the fake server | drift (cache) |
| conversations, messages, notifications (and their read state) | the fake server | drift (cache) |
| messages not sent yet (sending or failed) | the client, until the server accepts them | drift |
| recent searches | the client | drift |
| session (token, user id, email) | the client | `flutter_secure_storage` |
| settings (appearance, badges, language) | the client (the device) | `shared_preferences` |

- **Schema v4:** `users`, `posts` (→ `users`), `feed_items` (the feed window, → `posts`), `bookmarks` (→ `posts`); since Phase 4, `comments` (→ `posts` with `ON DELETE CASCADE`, → `users`); since Phase 5, `recent_searches` (the client's own, keyed by the trimmed, lower-case query); since Phase 6, `conversations` (→ `users`), `messages` (→ `conversations` with `ON DELETE CASCADE`, with a status: sending, sent or failed) and `notifications`. Foreign keys are turned on (`PRAGMA foreign_keys = ON`).
- **Migrations are generated and tested.** Every schema version is exported to [`drift_schemas/`](drift_schemas/) with `drift_dev make-migrations`, which also writes `app_database.steps.dart` (each step sees the schema as it was) and a test that runs every upgrade path, plus data-integrity tests for v1 → v2, v2 → v3 and v3 → v4.
- **The feed is its own table.** `feed_items` lists which cached posts are in the feed. A refresh replaces exactly that list, and posts cached by other screens never leak into the feed.
- **Upserts, never REPLACE.** SQLite's REPLACE deletes the old row first, and the delete cascades: that is how the Android edition silently lost bookmarks. Every write here is `INSERT … ON CONFLICT DO UPDATE` (a test shows what REPLACE would have done).
- **Reads JOIN `users`**, so editing your profile renames you on every post and comment at once, on every screen.
- **Search results stay live.** A search caches what it found and the screen reads it back by id, so a like made anywhere shows in the results.
- **The server's answer decides what stays.** A refresh (of the feed, a post, its comments, the bookmarks or a profile's posts) mirrors the server: it upserts what came back and deletes what the server no longer has, in one transaction. A post that answers 404 leaves the cache, with its comments.
- **Optimistic likes and bookmarks:** drift first, then the server. The server's answer replaces the guess; a failure restores the state from before the tap. A second tap while a request is out is ignored.
- **Chat history is never lost while the server has it.** A refresh mirrors the server's messages but never touches the ones still sending or failed. Delivered messages come in time order, the unsent ones after them in the order they were written, so nothing jumps when the server accepts a message.
- **"Clear cache" (Settings)** deletes the cached copy of the server's data and keeps what can't be fetched again: bookmarked posts and their authors, the signed-in user, unsent messages, recent searches. The screens still open hear a signal and load again, so none of them shows its emptied list as "nothing here".
- **The cache belongs to one user.** Logout and session expiry wipe it (recent searches included) before the token is deleted, and an answer that arrives after the session ended is dropped instead of being cached for the next user. The chat's realtime channel closes with the session.

## 💬 How Chat Works

- **A message shows at once.** `ChatRepository.sendMessage` writes it to drift as "sending", with an id made on the client, and the composer clears.
- **Messages go out in order.** A `Lock` sends one at a time, like an actor's mailbox. Dart has no data races, but every `await` lets another send start, and a slow first request would otherwise land second.
- **A failed send can be retried safely.** The bubble says "Not sent · Tap to retry", and the retry sends the same id. If the server had stored the message and only the answer was lost, it recognizes the id and returns what it has: no duplicate.
- **Replies arrive over a realtime channel.** The repository holds one subscription to `events()` per session and handles events in order:
  - typing started and stopped feed a typing map;
  - a reply is written to drift with the conversation as it now stands.

  Typing stays on from the first pending reply to the last.
- **An open chat stays read.** The repository counts who is watching each conversation. While the chat is on screen, a reply is stored as read and the server is told, so the next refresh can't bring the unread count back.
- **Unsent messages are never lost.** Refreshes, Clear cache and restarts keep them. Delivered messages come in time order, and the unsent ones after them in the order they were written, so nothing jumps when the server accepts one.
- **The list is reversed**, the usual shape for a chat: it starts at the newest message, and scrolls back to it once when a new one arrives.

## ♿ Accessibility

- **Dark mode on every screen:** every colour comes from the theme, and a test checks the WCAG contrast of each custom pairing in both themes.
- **Large text:**
  - text grows with the system setting everywhere;
  - above 130 %, side-by-side controls (the Appearance buttons, Edit profile and Log out) stack (`context.prefersStackedLayout`);
  - the profile counts wrap onto rows instead of breaking words.
- **Two deliberate limits:**
  - the tab labels keep their size, as on iOS's own tab bar (a long press shows the label);
  - unread badges stop growing at 130 %, so they don't cover their icon.
- **Screen readers:**
  - every tappable has a label;
  - a chat row reads as one button ("Grace Hopper, 1 hour ago, …, 2 unread");
  - a badge says "3 unread", not "3";
  - each profile count is its own node.
- **Tested:** an accessibility tour visits every screen and key state, in light and dark at 200 % text. It fails on any overflow, a tap target under 48 × 48, an unlabelled tappable, or text below the contrast guideline.

## ✅ Testing

```bash
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed .
fvm flutter test
```

**737 tests**, in about 35 seconds:
- **Unit tests:**
  - the validators;
  - the fake server and its reply scheduler (in fake time);
  - the DAOs, and every drift upgrade path from v1 to v4.
- **Repositories** on the real fake server with an in-memory database:
  - paging without duplicates;
  - optimistic writes and their rollback;
  - mirroring, and the REPLACE-cascade regression;
  - 20 concurrent chat sends arriving in order, and retries without duplicates;
  - session expiry.
- **Every Cubit and Bloc** (`bloc_test`): loading / empty / error / loaded with no false-empty flash, debounced and restartable search, `droppable()` submits, Undo, reloading after Clear cache.
- **Every view:** widget tests with `MockCubit` / `MockBloc`, including the large-text layouts.
- **App-level flows** on the real DI graph:
  - sign-in, deep links through sign-in, and session expiry;
  - the feed offline;
  - posts and comments, search, bookmarks and profiles;
  - chat with replies, activity, settings and Clear cache.
- **An accessibility tour:** every screen and key state, in light and dark at 200 % text.

The per-area breakdown, the techniques (fakes over mocks, bounded waits, mutation checks) and the gotchas are in [docs/TESTING.md](docs/TESTING.md).

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
| Debounced search | Flow `debounce` + `flatMapLatest` | Combine `debounce` | Bloc event transformer (`switchMap` + `restartable`) |
| Profile edits | Room only, never on posts | UserDefaults only, never on posts | the server, then one `users` row every post JOINs |
| Chat concurrency | coroutines | `actor MessageStore` | a `Lock` + client ids + a realtime `Stream` |
| Settings | DataStore (read asynchronously) | UserDefaults | `SharedPreferencesWithCache`, read before the first frame |
| Accessibility checks | none in the tests | none in the tests | a test tour of every screen, light and dark, at 200 % text |
| CI | added in Phase 7; it watches `main`, but the repo's branch is `master` | added in Phase 7, fixed in a later commit | Phase 1, so every push is checked |

---

## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md): layers, who owns what, every screen's state holder, errors, the realtime channel, key decisions
- [Testing](docs/TESTING.md): what is covered, how the tests are built, and the gotchas
- [API simulation](docs/API_SIMULATION.md): the fake server's services, latencies, seed data, rules, reply algorithm and developer switches
- [Learning notes](docs/LEARNING_NOTES.md): every Flutter / Dart concept in the app
- [Interview notes](docs/INTERVIEW_NOTES.md): questions and answers based on this codebase
- [Screenshots](docs/SCREENSHOTS.md)
- [Roadmap](docs/ROADMAP.md)
- Phase write-ups:
  - [Phase 1 — Foundation](docs/PHASE_1_SUMMARY.md)
  - [Phase 2 — Fake Auth + Session](docs/PHASE_2_SUMMARY.md)
  - [Phase 3 — Feed + Offline Cache](docs/PHASE_3_SUMMARY.md)
  - [Phase 4 — Post Detail, Comments + Create Post](docs/PHASE_4_SUMMARY.md)
  - [Phase 5 — Search, Bookmarks + Profile](docs/PHASE_5_SUMMARY.md)
  - [Phase 6 — Chat, Notifications + Settings](docs/PHASE_6_SUMMARY.md)
  - [Phase 7 — Open-Source Polish](docs/PHASE_7_SUMMARY.md)
- [Changelog](CHANGELOG.md) · [Contributing](CONTRIBUTING.md) · [Code of conduct](CODE_OF_CONDUCT.md) · [Security](SECURITY.md)

---

## 🗺️ Roadmap

All seven phases are done. Natural next steps:
- a real `dio` backend behind the same API service interfaces, with a token refresh and a WebSocket realtime channel;
- automatic retry of unsent messages;
- real translations behind the language setting (`gen-l10n`);
- following people, and photo uploads;
- integration and golden tests;
- an adaptive tablet layout.

See [docs/ROADMAP.md](docs/ROADMAP.md).

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse
