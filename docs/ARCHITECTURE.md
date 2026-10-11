# Architecture

ConnectHub uses a layered **clean architecture with MVVM-style presentation**: Cubits and Blocs play the ViewModel role. Data flows one way. Widgets send intents down; immutable state flows back up, and the screens read only the local cache.

```
┌───────────────────────────────── presentation (features/) ─────────────────────────────────┐
│  Page (DI + navigation) ─▶ View (renders state, forwards intents) ─▶ Cubit / Bloc           │
└──────────────────────────────────────────────┬─────────────────────────────────────────────┘
                                               │ use cases (domain/usecase)
┌──────────────────────────────────────────────▼─────────────────────────────────────────────┐
│  domain/ (pure Dart)  User · Post · Comment · Conversation · Message · AppNotification ·    │
│                       AppSettings · Result-returning repository contracts                   │
└──────────────────────────────────────────────┬─────────────────────────────────────────────┘
                                               │ implemented by
┌──────────────────────────────────────────────▼─────────────────────────────────────────────┐
│  data/  repositories (+ ApiGuard) · mappers                                                  │
└────────┬───────────────────────────────┬──────────────────────────┬─────────────────────────┘
         │ core/network                  │ core/database            │ core/storage
         ▼                               ▼                          ▼
  API services ─▶ FakeServer       drift (SQLite): the cache    secure storage (session)
  (in memory, seeded from          connect_hub.sqlite           SharedPreferencesWithCache
   assets/json)                                                  (settings)
```

The everyday data flow:

```
View ─intent─▶ Cubit / Bloc ─▶ UseCase ─▶ Repository ─┬─ read ──▶ drift (cache) ─ watch() ─▶ Cubit ─ state ─▶ View
                                                      └─ write / refresh ─▶ ApiService ─▶ FakeServer (in memory, seeded from assets/json)
                                                                              ▲ token from secure storage
```

---

## Layers and their rules

| Layer | Contains | May import | Must not import |
|---|---|---|---|
| `domain/` | entities (freezed), repository contracts, use cases | `core/common` (`Result`, `AppException`) | Flutter, drift, JSON, `data/` |
| `data/` | repository implementations, `ApiGuard`, mappers | `domain/`, `core/*` | features |
| `core/network` | API contracts, fake services, `FakeApiClient`, `FakeServer`, `ReplyScheduler`, DTOs | `core/common`, JSON packages | `material_ui`, drift |
| `core/database` | `AppDatabase`, tables, DAOs, migration steps | drift | `material_ui`, JSON packages |
| `core/storage` | `SessionStorage` (secure storage), `SettingsLocalDataSource` (preferences) | the storage plugins | everything above it |
| `core/design_system` | themes, tokens, shared widgets, the large-text rule | `material_ui`, `domain/model` | features, routes |
| `core/navigation` | typed routes, router, the sign-in gate | features' Pages | |
| `features/<feature>` | Page, View, Cubit/Bloc, state | `domain/`, design system, routes | `data/` |
| `di/` | composition root | everything | |

Only `core/network/` touches the fake backend. Settings → Developer reaches it through one more interface, `DeveloperToolsService`, like any other service.

---

## Who owns what

| Data | Source of truth | Client copy | Notes |
|---|---|---|---|
| profiles, posts, likes, bookmarks, comments | the fake server | drift | a refresh mirrors the server (upsert + delete what's gone) |
| conversations, delivered messages, notifications (and read state) | the fake server | drift | the read state is the server's, so a refresh never resets it |
| messages not sent yet (sending / failed) | the client, until the server accepts one | drift | never deleted by a refresh, by "Clear cache" or by a restart |
| the feed window (which posts, in which order) | the client | drift (`feed_items`) | a refresh replaces it; load-more appends after a cursor |
| recent searches | the client | drift | normalized key, ten kept, wiped at logout |
| session (token, user id, email) | the client | `flutter_secure_storage` | a credential: Keychain / Keystore |
| settings (appearance, badges, language) | the client (the device) | `shared_preferences` | survive logout |

**Screens read only drift.** Repositories write the server's answers into drift, and every screen that shows those rows updates through drift's `watch()` streams. That is what makes the app offline-first, keeps every screen consistent (a like on Post Detail shows on the Feed, in Search and on Profile), and keeps the UI independent of the network.

---

## State management

| Screen | Holder | Scope | Why |
|---|---|---|---|
| sign-in gate | **`AuthBloc`** | app (above `MaterialApp`) | the session is a stream (`restartable()` subscription); logout is `droppable()` |
| theme | `SettingsCubit` | app (above `MaterialApp`) | `MaterialApp.themeMode` reads it; first state read synchronously |
| Login, Sign Up | **`LoginBloc`, `SignUpBloc`** | screen | `droppable()` submits: a double tap makes one request |
| unread badges | `BadgesCubit` | session (the tab shell) | lives only while signed in; follows two counts and a setting |
| Feed | `FeedCubit` | tab | cache stream + refresh + cursor paging + optimistic writes |
| Search | **`SearchBloc`** | tab | debounce (`switchMap`) + `restartable()`; live results through `emit.forEach` |
| Bookmarks | `BookmarksCubit` | tab | offline list, Undo |
| Activity | `ActivityCubit` | tab | filters, optimistic mark read |
| Profile, someone's profile | `ProfileCubit` (`@factoryParam userId`) | tab / screen | one Cubit for mine and others' |
| Post Detail, Comments | `PostDetailCubit`, `CommentsCubit` (`@factoryParam postId`) | screen | no error flash before the first read |
| Create Post, Edit Profile | `CreatePostCubit`, `EditProfileCubit` | screen | validated forms with a discard guard |
| Chats, Chat | `ChatsCubit`, `ChatDetailCubit` (`@factoryParam conversationId`) | screen | local filter; messages + typing + sends |
| Settings actions | `SettingsToolsCubit` | screen | Clear cache, developer switches |

The rule: **Cubit by default; Bloc when explicit events and transformers add value.** States are freezed values, rendered with an exhaustive `switch`. One-time effects (a SnackBar, closing a page, scrolling to a new message) live in state too: a `UiMessage` with an id, or a value a `BlocListener` reacts to once.

### How a list screen decides what to show

Every list Cubit combines two inputs: the cached rows (a stream) and what the latest refresh found (pending / succeeded / failed / not found). An empty cache therefore means "still loading", "the server has nothing" or "couldn't load", depending on the second.

Two details keep the screen honest:
- After a refresh, the Cubit reads the cache as it is *now* (`firstValue`), because drift reports the refresh's own writes a moment later. It records the outcome only after that read, so a stale value delivered meanwhile can't flash "No posts yet" or an error.
- The failure branch reads the cache too: a fast failure can beat drift's first read, and cached rows must stay on screen with a SnackBar instead of a silent failure.

---

## Error handling

- **One vocabulary:** data sources throw subtypes of a sealed `AppException`. Each carries a user-facing `message`:
  - `NetworkException` (offline);
  - `NotFoundException` (404);
  - `UnauthorizedException` (401);
  - `InvalidCredentialsException` (one message for a wrong email *or* password);
  - `EmailTakenException`;
  - `DataFormatException`, `UnknownException`.
- **`Result<T>` across the data → domain boundary.** Repositories return `Ok` / `Err`; callers handle both with an exhaustive `switch`.
- **`ApiGuard`** wraps every API call:
  - a 401 expires the session once, for every repository (the role of an HTTP interceptor);
  - an answer that arrives after the session that sent it has ended is dropped, so it can't be cached for the next user;
  - an unexpected exception is logged and becomes `UnknownException`.
- **On screen:** with nothing cached, a full-screen error with "Try again"; with cached data on screen, it stays, and a SnackBar says what failed (no silent errors).

---

## Writes: optimistic, ordered, idempotent

| Write | Strategy | Detail |
|---|---|---|
| like, bookmark | optimistic | drift first, then the server; the server's answer replaces the guess; a failure restores the state from before; one request per post at a time |
| comment delete, mark read, mark all read | optimistic | rolled back on failure |
| comment add, create post, edit profile | pessimistic | a spinner; the server's answer is cached; a failure keeps the input |
| chat message | optimistic + ordered + idempotent | the row shows at once ("Sending…"); a `Lock` sends one at a time, in order; the id is made on the client, so a retry can't post twice |
| feed refresh / load-more | serialized | a `Lock` makes them take turns over the same window |

---

## The realtime chat channel

- `ChatApiService.events()` is a `Stream<ChatEventDto>`: typing started, a reply (with the conversation as it now stands), typing stopped. The fake service authenticates like any request, then `yield*`s the server's events for that user.
- `ChatRepositoryImpl` opens one subscription per session, on first use, and handles events one at a time (`asyncMap`), so "typing stopped" waits until the reply before it is in the cache.
- The subscription closes when the session ends, and an event for an ended session is dropped.
- `watchMessages` counts its watchers: while a chat is on screen, its replies are stored as read, and the server is told.

---

## Session lifecycle

```
launch ─▶ SessionRepository.restore (secure storage) ─▶ SignedIn / SignedOut(reason)
                         │ watchSession(): the current state, then every change
                         ▼
AuthBloc (emit.forEach) ─▶ authenticated / unauthenticated(message) ─▶ router re-runs authRedirect
logout / 401 expiry ─▶ CacheDao.clearAll (the user's cache) ─▶ delete the token ─▶ SignedOut
```

The tab shell exists only while signed in, so session-scoped state (the badges, the chat channel's lifetime) lives there or follows `watchSession()`.

---

## Navigation

- **go_router with typed routes** (`go_router_builder`). Widgets navigate with `PostDetailRoute(postId: id).push(context)`; shared widgets take callbacks and never know about routes.
- **The gate:** `redirect: authRedirect(AuthBloc.state, location)`, a pure function, re-run by a `refreshListenable` over the `AuthBloc`'s stream. Unknown session → `/splash`; signed out → `/login?from=…`; signed in on an auth route → `from` (if it is a safe in-app path) or `/feed`.
- **Tabs:** a `StatefulShellRoute.indexedStack` with five branches (Feed, Search, Bookmarks, Activity, Profile), each with its own Navigator, kept alive offstage.
- **Root-level screens** (`/posts/:id` + `/comments`, `/users/:id`, `/compose`, `/edit-profile`, `/chats` + `/:conversationId`, `/settings`) are pushed above the tab bar: they are reachable from several tabs, and the chat composer and forms shouldn't sit above a tab bar.
- **My profile is a tab:** `/users/<my id>` redirects to `/profile`; `openProfile` switches tabs for my id and pushes everyone else's.

---

## Dependency injection

`get_it` + `injectable`. `configureDependencies()` is generated and awaited in `main()` before `runApp`.

| Registration | Used for |
|---|---|
| `@preResolve` + `@lazySingleton` | `SharedPreferencesWithCache`, `PackageInfo`: read synchronously afterwards |
| `@lazySingleton` | the fake server, network simulator, services, `AppDatabase` and DAOs, repositories, `ApiGuard` |
| `@injectable` (factory) | use cases, Cubits and Blocs (each screen owns its instance; `BlocProvider` closes it) |
| `@factoryParam` | ids for Post Detail, Comments, Profile, Edit Profile, Chat |
| `@ignoreParam` | test hooks with defaults (the search debounce, the reply timings) |

`getIt` appears only in `main.dart`, the app root, the shell and Pages. Everything else receives its dependencies through its constructor.

---

## Persistence

- **drift v4** (`connect_hub.sqlite`), foreign keys on:
  - `users`;
  - `posts` (→ `users`), `feed_items` (→ `posts`), `bookmarks` (→ `posts`);
  - `comments` (→ `posts`, cascade; → `users`), `recent_searches`;
  - `conversations` (→ `users`), `messages` (→ `conversations`, cascade), `notifications`.
- **Writes are upserts** (`INSERT … ON CONFLICT DO UPDATE`), never `REPLACE`: a `REPLACE` deletes the row first, and the delete would cascade.
- **Reads JOIN `users`**, so one profile edit renames the author everywhere.
- **Migrations** are generated (`make-migrations`), each schema version is exported to `drift_schemas/`, and every upgrade path is tested, with data-integrity tests for v1 → v2 → v3 → v4.
- **Preferences** live in `SharedPreferencesWithCache` (an allow-list of three keys); the **session** in `flutter_secure_storage`.

---

## Accessibility

- Every icon button has a tooltip (its screen-reader label); unread counts read as "3 unread"; notification rows announce "Unread. Like.".
- Tap targets are at least 48 × 48, including the small avatars on comments.
- **Large text:** text grows with the user's setting everywhere. Side-by-side controls (two buttons, three segments) stack above 130 % (`prefersStackedLayout`). The tab bar keeps its label size, as on iOS's own tab bar; a long press shows the label. Unread badges stop growing at 130 %.
- Animations stop when the system asks (`MediaQuery.disableAnimationsOf`).
- Colours on custom fills meet WCAG AA, checked by tests; an app-level test tours every screen at 200 % text in both themes with Flutter's tap-target, label and contrast guidelines.

---

## Key decisions

| Decision | Alternative | Why |
|---|---|---|
| An in-memory `FakeServer` behind API interfaces | fake repositories / a persisted fake backend | the data layer is real; a `dio` client would replace only the services; the server restarting clean shows how the client's cache mirrors it |
| Screens read only drift | screens holding network results | offline-first, one source of truth, every screen consistent |
| Cursor pagination over `feed_items` | offset pages | new posts don't shift pages; nothing is fetched twice |
| Optimistic writes in repositories | in Cubits | one rollback path for every screen that likes or bookmarks |
| A `Lock` + client ids for chat sends | fire-and-forget | order survives slow requests; retries are safe |
| The router owns the sign-in gate | screens navigating after login/logout | one pure, unit-tested rule; deep links survive sign-in |
| Root-level detail routes | per-tab child routes (MovieExplorer) | reachable from five tabs; full-screen chat and forms |
| `SharedPreferencesWithCache` via `@preResolve` | async reads | the saved theme applies on the first frame |
| freezed + exhaustive `switch` | hand-written states | value equality, `copyWith`, compiler-checked rendering |
| Generated files committed | generating in CI | clone-and-run; CI fails if they are stale |

See the per-phase write-ups in this folder for the reasoning behind each piece.
