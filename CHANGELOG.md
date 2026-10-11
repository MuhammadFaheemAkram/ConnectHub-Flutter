# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

_All seven build phases are complete. See [`docs/ROADMAP.md`](docs/ROADMAP.md) for what's next._

## [0.7.0] — 2026-10-11 — Phase 7: Open-Source Polish

### Added
- **Docs:**
  - ARCHITECTURE, TESTING, API_SIMULATION (latencies, seed data, login rules, the reply algorithm, developer switches), LEARNING_NOTES, INTERVIEW_NOTES and ROADMAP;
  - SCREENSHOTS, with light, dark and large-text screenshots from the simulator;
  - the Phase 7 summary.
- **Open-source files:** CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, this CHANGELOG, and the GitHub issue and PR templates.
- **An accessibility tour** (39 tests): every screen and key state in light and dark at 200 % text, checked for overflow, 48 × 48 tap targets, labelled tappables and text contrast. Tab labels and badges are also checked at 300 %.
- **`AppSearchField`** for Search and Chats. Material's `SearchBar` wrapped its field in an unlabelled tappable surface.
- **`prefersStackedLayout`**: the one large-text rule. Above 130 % text, side-by-side controls stack.
- `test/flutter_test_config.dart`: an offline image cache for every test.
- 43 tests (737 in total).

### Changed
- **Large text:**
  - Settings' Appearance becomes a radio list;
  - Profile's counts wrap onto rows, and its two buttons stack;
  - the tab labels keep their size (a long press shows them);
  - unread badges stop growing at 130 %.
- **Chats:** `ConversationTile` is a custom row instead of a `ListTile`, whose fixed-height trailing column overflowed at large text. It still reads as one button.
- **Comments:** the author's picture is now a 48 × 48 tap target (was 36), with the layout unchanged.
- **Chat:** "Not sent · Tap to retry" wraps instead of overflowing.
- **Feed:** the list checks for the next page when its size changes without a scroll (a rotation, a resized window, a text-size change). Before, a list that suddenly fit on screen kept its footer spinner forever.
- **Tests:** the shared helpers (`destination`, `appBarTitled`, `tester.selectedTab`) moved into `app_harness.dart`, replacing seven copies.

### Removed
- `EditProfileState.isLoading`, which nothing used.

## [0.6.0] — 2026-10-11 — Phase 6: Chat, Notifications + Settings

### Added
- **The fake server's chats and notifications:**
  - messages keep the client's id, so a retry can't duplicate them;
  - a `ReplyScheduler` types, then replies, over a per-user realtime channel;
  - notifications have a read state the server owns, and link to a post or a profile.
- **drift v4:** `conversations`, `messages` (sending, sent or failed) and `notifications`, with a generated migration step and a v3 → v4 data-integrity test.
- **`ChatRepository`:**
  - messages show at once and go out in order under a `Lock`;
  - a retry keeps the message's id;
  - one realtime subscription per session;
  - typing stays on from the first pending reply to the last;
  - open chats stay read.
- **Screens:**
  - Chats, with a local filter;
  - Chat Detail: bubbles, a typing indicator, "Not sent · Tap to retry", and auto-scroll to new messages;
  - Activity: filters, optimistic mark read and mark all read, links to posts and profiles;
  - a `BadgesCubit` in the shell for the Activity tab and the Feed's Chats button.
- **Settings:**
  - the theme, from `SharedPreferencesWithCache` resolved before `runApp` (no flash);
  - the badges switch and a language label;
  - Clear cache, with a confirmation;
  - Simulate network failure and Expire session;
  - Log out, and About (`package_info_plus`).
- 189 tests (694 in total), including 20 ordered sends, a `Lock` mutation check, and a retry after a lost answer.

### Changed
- Feed, Profile, Search, Activity and the badges load again after Clear cache.
- Every list Cubit records its refresh's outcome only after reading the cache, so no screen shows an empty state for a frame.

## [0.5.0] — 2026-10-11 — Phase 5: Search, Bookmarks + Profile

### Added
- **The fake server's search, profile, profile-update and bookmarks endpoints:** people by name or bio, posts by content or author.
- **drift v3:** `recent_searches` (a normalized key, ten kept, wiped at logout), plus the users, bookmarks and search DAOs.
- **Search:**
  - a `SearchBloc` with a 300 ms debounce and restartable searches;
  - All / People / Posts scopes;
  - results kept live from drift by id;
  - recent searches, saved on submit or on tapping a result.
- **Bookmarks:** the server's list mirrored into drift for offline use, pull to refresh, and remove with an Undo SnackBar (`UiMessage` gains actions).
- **Profile** for me and for others. My own id redirects to the Profile tab, and `openProfile` switches tabs instead of pushing.
- **Edit Profile:** validation, a bio counter and a discard guard. A save renames me everywhere through the `users` JOIN.
- 153 tests (505 in total).

### Fixed
- A refresh failure that beat drift's first read hid the "showing saved posts" message (Feed, Post Detail, Comments).

## [0.4.0] — 2026-10-11 — Phase 4: Post Detail, Comments + Create Post

### Added
- **The fake server's post and comment endpoints:** get and create posts; list, add and delete comments (only the author may delete); server-side rules.
- **drift v2:** a `comments` table and the first migration: the exported schema, generated `stepByStep` steps, and migration tests that include v1 → v2 data integrity.
- **`CommentRepository`:** it mirrors the server, fetches a deep-linked post first, and deletes optimistically with rollback.
- **`PostRepository`** gains `watchPost`, `refreshPost` and `createPost`.
- **Screens:**
  - Post Detail: cached first, never an error flash, and a not-found state;
  - Comments: delete your own, with a confirmation;
  - Create Post: a counter and a discard guard.
- **Post ids reach Cubits** through `@factoryParam`, and Cubits read the cache with `firstValue`.
- 116 tests (352 in total).

## [0.3.0] — 2026-10-11 — Phase 3: Feed + Offline Cache

### Added
- **The fake server's feed:** seeded posts with rebased dates, derived comment counts, per-user likes and bookmarks, and cursor pages of 6.
- **`FakeApiClient`:** every feed request is authenticated (the saved token, the simulated network, a 401 for a bad token).
- **drift v1:** `users`, `posts`, `feed_items` and `bookmarks`, with foreign keys, upserts and the exported schema.
- **`FeedRepository`:** cursor paging, where refresh and load-more take turns.
- **`PostRepository`:** optimistic likes and bookmarks, with rollback.
- **Feed screen:** `FeedCubit`, pull to refresh, infinite scroll with its footers, `PostCard`, `UserAvatar` and relative time.
- 98 tests (236 in total).

### Changed
- API answers are tied to the session that sent them, and logout or expiry wipes the cache.

## [0.2.0] — 2026-10-10 — Phase 2: Fake Auth + Session

### Added
- **Core types:** `Result`, a sealed `AppException` hierarchy, `Validators`, `IdGenerator`, `DemoAccount` and `FormStatus`.
- **An in-memory `FakeServer`** seeded from the iOS `auth_user.json`:
  - the demo account, and sign-up with unique emails;
  - self-describing tokens, and revocation;
  - `NetworkSimulator`, for latency and simulated failures.
- **`AuthApiService`** with a fake implementation; `UserDto` and `AuthResponseDto` via json_serializable.
- **Sessions:**
  - stored in `flutter_secure_storage` (Keychain / Keystore);
  - `SessionRepository` streams the current state, then every change;
  - `ApiGuard` maps calls to `Result`, and expires the session on a 401.
- **An app-wide `AuthBloc`** drives the router's sign-in gate, with the splash and a safe return address.
- **Login and Sign Up:** droppable submits, errors shown after the first submit, a demo-account button and an expiry notice.
- 98 tests (138 in total), including app-level flows on the real DI graph.

### Changed
- Android backup is disabled for the Keystore-backed session.

## [0.1.0] — 2026-10-10 — Phase 1: Foundation

### Added
- **Project setup:**
  - Flutter 3.47.6 pinned with FVM, for Android + iOS;
  - migrated to the standalone `material_ui` package;
  - strict analysis, and GitHub Actions CI (codegen diff check, format, analyze, test).
- **Design system:** Material 3 light/dark themes from the `#0F766E` seed, `AppColors`, spacing/radius/icon tokens and the shared state views.
- **Typed go_router routes:**
  - the auth routes;
  - a five-tab `StatefulShellRoute`;
  - root-level screens above the shell, including full-screen dialogs.
- **The sign-in gate:** a pure `authRedirect`, driven by `refreshListenable`.
- **A `get_it` + `injectable` composition root.**
- 40 tests, the first README, the MIT LICENSE and the Phase 1 summary.
