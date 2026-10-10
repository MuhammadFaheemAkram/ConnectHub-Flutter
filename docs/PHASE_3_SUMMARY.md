# Phase 3 — Feed + Fake Network + Offline Cache

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 3, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions solved the same problems.

---

## 🎯 Phase Goal

Phase 3 is the first feature slice built end to end: fake API → repository → drift → Cubit → screen. It makes the Feed real:
- **Offline-first:** the screen renders only the drift cache; the network only refreshes it. Cached posts show at once, also without a connection.
- **Cursor pagination** with infinite scroll, pull to refresh and honest footers.
- **Optimistic likes and bookmarks** that roll back, and say so, when the server refuses.
- **Authenticated endpoints:** every feed request carries the session's token, and a 401 ends the session through the gate built in Phase 2.
- **One user's cache:** logout and expiry wipe it.

It also sets up the cache every later phase extends: drift v1 with foreign keys, upserts, a feed-membership table and an exported schema, ready for tested migrations.

---

## 🧱 What Was Implemented

- **Packages:** `drift`, `drift_flutter`, `cached_network_image`, `intl`, `clock`, `synchronized`; dev: `drift_dev`.
- **Seed data** (`assets/json/`)
  - `feed_posts.json`: the iOS edition's 15 posts plus two by the demo user, `p16` (an offline-first tip, 25 likes) and `p17` (a question about testing time-based logic, 8 likes).
  - `comments.json`: the iOS edition's 11 comments plus `c12` (Linus on `p16`) and `c13` (Alan on `p17`).
  - The demo user's avatar is now `img=68`: in the iOS seed it was Alan Turing's picture too.
- **Fake backend** (`core/network/`)
  - `FakeServer`, feed slice:
    - users, posts with per-user `likedBy` and `bookmarks`, and the comments (counted only; served in Phase 4);
    - **rebasing:** at seeding, every date shifts by the same amount, so the newest record (`c13`) is five minutes old;
    - **derived counts:** `commentCount` is counted from the comments on every response; `likeCount` is the seed's count plus the users who like it;
    - **cursor pages:** newest first, ties by id, pages of 6 (6 / 6 / 5), cursor `<createdAt>|<id>`;
    - `setLiked` / `setBookmarked`, idempotent like HTTP `PUT` / `DELETE`;
    - authors are public profiles: emails are only in the signed-in user's own auth response.
  - `FakeApiClient`: the fake HTTP client. It reads the saved token, crosses the `NetworkSimulator`, and has the server resolve the token (401 if it can't).
  - `FeedApiService` / `FakeFeedApiService`: `getFeed`, `setLiked`, `setBookmarked` (700 ms per page, 350 ms per write).
- **drift v1** (`core/database/`)
  - Tables: `users`, `posts` (→ `users`), `feed_items` (→ `posts`, `ON DELETE CASCADE`), `bookmarks` (→ `posts`, `ON DELETE CASCADE`).
  - `PRAGMA foreign_keys = ON` in `beforeOpen`; dates as UTC ISO-8601 text (`build.yaml`).
  - DAOs: `PostsDao` (upserts, like and bookmark writes), `FeedDao` (the window and its JOIN), `CacheDao` (`clearAll`).
  - `make-migrations` configured; the v1 schema is exported to `drift_schemas/app_database/drift_schema_v1.json`.
- **Domain:** `User`, `Post`; `FeedRepository` (`watchFeed`, `refresh`, `loadMore`), `PostRepository` (`setLiked`, `setBookmarked`); `WatchFeedUseCase`, `RefreshFeedUseCase`, `LoadMoreFeedUseCase`, `LikePostUseCase`, `BookmarkPostUseCase`.
- **Data**
  - `FeedRepositoryImpl`: the window, paged by cursor; refresh and load-more serialized by a `Lock`.
  - `PostRepositoryImpl`: optimistic writes with rollback, one request per post and action at a time.
  - `ApiGuard`: a request now belongs to the session that sent it. An answer that arrives after that session ended is dropped, and a late 401 can't sign out the next user.
  - `SessionRepositoryImpl`: ending a session wipes the cache first, then deletes the token.
- **Design system:** `UserAvatar` (initials fallback), `PostCard`, `RelativeTimeText`; in `core/common`: `RelativeTime`, `compactCount`, `UiMessage`.
- **Feed screen:** `FeedCubit` + `FeedState`, `FeedView` (pull to refresh, infinite scroll, the three footers, the empty and error states, SnackBars), `FeedPage`. Card, author and comment taps open the placeholder routes. The temporary sample links are gone.
- **Tests:** 236 in total (98 new); see Interview Notes and the README.

### Differences from the plan

- **`synchronized` arrives now** rather than in Phase 6: the feed window already needs a `Lock`.
- **Comments are seeded now**, server-side only, so the first screen that shows a comment count shows the derived one. Their endpoints arrive in Phase 4.
- **`UiMessage` has no action yet.** Undo arrives with Bookmarks (Phase 5).
- **`PostDto.bookmarkedAt`** (a time, not a flag), so the cache keeps the server's bookmark time.
- **`FeedApiService` has only this phase's endpoints**; `getPost` / `createPost` come in Phase 4 and `getBookmarks` in Phase 5.
- **`make-migrations` with a single version** only exports the schema. The step-by-step helper and the generated migration tests appear with v2 (Phase 4).

---

## 💙 Flutter / Dart Concepts Demonstrated

- **Offline-first with drift streams**
  - `watch()` re-runs a query whenever a table it reads changes, so every screen showing a post updates when any code writes it.
  - The Cubit subscribes once and renders whatever arrives. Refreshing is a *write*, not a screen update.
- **Upsert vs REPLACE**
  - `insertOnConflictUpdate` = `INSERT … ON CONFLICT DO UPDATE`: the row is updated in place.
  - `InsertMode.insertOrReplace` deletes the old row first, and the delete fires `ON DELETE CASCADE`. A test keeps that behaviour visible.
- **A membership table** (`feed_items`): "which posts are in the feed" is data of its own, separate from "which posts are cached".
- **JOINs into records:** `typedef CachedPost = ({PostRow post, UserRow author, DateTime? bookmarkedAt})` carries a three-table row through the DAO boundary without another class.
- **Transactions and batches:** drift buffers a transaction's change notifications and sends them once at commit, so watchers never see the window empty halfway through a refresh.
- **Cursor (keyset) pagination:** "posts after this one" survives new posts arriving; "skip 6" doesn't.
- **Optimistic updates with rollback**, in the repository:
  - write drift → call the API → take the server's answer, or restore the snapshot;
  - a second tap while a request is out is ignored (`droppable()` for one post);
  - the like's answer updates only the like columns, so it can't clobber an in-flight bookmark.
- **`Lock` from `package:synchronized`:** Dart has no data races, but every `await` lets other code run. Without the lock, a load-more could finish after a refresh and leave a gap.
- **Requests bound to a session:** `ApiGuard` remembers which session sent a request and checks it again when the answer comes back.
- **Deriving state from two inputs:** the cached posts (a stream) plus the refresh outcome decide `loading` / `empty` / `error` / `loaded`. Reading the window once more after a refresh (`watchFeed().first`) avoids an "empty" flash.
- **One-time effects in state:** `UiMessage(id, text)` plus `BlocListener(listenWhen: …)`; the id makes a repeated failure show again.
- **Time:** an injectable `Clock` for services (`Clock.fixed` in tests) and `package:clock`'s zone clock for widgets (`withClock` in tests). `intl` formats "Jul 24" and "4.8K".
- **Infinite scroll:** a `ScrollController` asks for more near the end, and checks again after each page is laid out, so a short list keeps loading.
- **`cached_network_image`** with placeholder and error builders: avatars fall back to initials, images to a tinted box.
- **Testing**
  - A `GatedFeedApi` holds requests "in flight", making the optimistic moment observable.
  - In-memory drift (`NativeDatabase.memory()`), with `closeStreamsSynchronously: true` in widget tests.
  - Regression tests that were checked to fail without their fix (the "empty" flash).
- **Five traps** (now conventions §11.21–11.25): see Interview Notes.

---

## 🔁 Data Flow (this phase)

```
FeedPage ── creates FeedCubit ── load()
   │
   ├─ watchFeed() ─▶ FeedRepository ─▶ FeedDao.watchFeed()   feed_items ⨝ posts ⨝ users ⟕ bookmarks
   │                       ▲                │ emits the window now, then after every write
   │                       │                ▼
   │                       │          FeedCubit ─▶ FeedState ─▶ FeedView (PostCards)
   │                       │
   └─ refresh() ───────────┴─ Lock ─▶ ApiGuard.run(FeedApiService.getFeed)
                                         ─▶ FakeApiClient: token (secure storage) → NetworkSimulator (700 ms) → FakeServer.authenticate
                                         ─▶ FakeServer.getFeed(userId, cursor) ─▶ PostPageDto
                              ◀─ FeedDao.replaceFeed(page) (one transaction) ─▶ drift notifies once

Like ─▶ PostRepository: PostsDao.applyLike (at once) ─▶ API ─▶ writeLike(server's answer) | writeLike(before) + Err ─▶ SnackBar
401 anywhere ─▶ ApiGuard ─▶ SessionRepository.expire() ─▶ CacheDao.clearAll() ─▶ token deleted ─▶ Login
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `assets/json/{feed_posts,comments}.json` | Seed posts and comments (iOS + Flutter additions). |
| `lib/core/network/fake_server/fake_server.dart` | Feed slice: posts, likes, bookmarks, rebasing, cursor pages. |
| `lib/core/network/api/fake_api_client.dart` | Token → network → authenticate, for every authenticated call. |
| `lib/core/network/api/{feed_api_service,fake_feed_api_service}.dart` | The feed endpoints and their fake. |
| `lib/core/network/dto/{post_dto,post_page_dto,comment_dto}.dart` | Wire models. |
| `lib/core/database/app_database.dart` | drift v1, foreign keys on. |
| `lib/core/database/tables/*.dart` | `users`, `posts`, `feed_items`, `bookmarks`. |
| `lib/core/database/daos/{posts,feed,cache}_dao.dart` | Upserts and optimistic writes; the window; the wipe. |
| `drift_schemas/app_database/drift_schema_v1.json` | The exported v1 schema, for migration tests. |
| `lib/domain/model/{user,post}.dart` | Domain models. |
| `lib/domain/repository/{feed,post}_repository.dart` | Contracts. |
| `lib/domain/usecase/{watch_feed,refresh_feed,load_more_feed,like_post,bookmark_post}_use_case.dart` | Use cases. |
| `lib/data/mapper/{user,post}_mappers.dart` | DTO → rows, rows → domain. |
| `lib/data/repository/{feed,post}_repository_impl.dart` | Paging; optimistic writes. |
| `lib/core/common/{ui_message,relative_time,compact_count}.dart` | One-time messages; "5m"; "4.8K". |
| `lib/core/design_system/widgets/{user_avatar,post_card,relative_time_text}.dart` | Shared UI. |
| `lib/features/feed/{feed_page,feed_view}.dart`, `cubit/feed_{cubit,state}.dart` | The Feed screen. |
| `test/helpers/{backend,feed_backend,database_rows,app_harness}.dart`, `fakes/{gated_feed_api,fake_feed_repository,fake_post_repository}.dart` | Test infrastructure. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `FakeApiClient` | `@lazySingleton` | Token, network, authentication for each call | `core/network/api`: the part a `dio` client + interceptor would replace |
| `FeedApiService` / `FakeFeedApiService` | interface / implementation | Feed endpoints | `core/network/api` |
| `PostDto`, `PostPageDto`, `CommentDto` | `json_serializable` | Wire shapes | `core/network/dto` |
| `AppDatabase` | drift database | Schema, version, foreign keys | `core/database`: no Flutter UI or JSON imports |
| `PostsDao`, `FeedDao`, `CacheDao` | drift accessors | Queries and writes, per concern | `core/database/daos` |
| `CachedPost`, `LikeState` | record typedefs | Multi-table rows across the DAO boundary | next to the DAO that produces them |
| `User`, `Post` | freezed | What screens show | `domain/model`: pure Dart |
| `FeedRepository` / `Impl` | contract / implementation | The cached window, refresh, load more | `domain/repository` / `data/repository` |
| `PostRepository` / `Impl` | contract / implementation | Optimistic like and bookmark | same |
| `FeedCubit`, `FeedState`, `LoadMoreStatus` | Cubit / freezed union / enum | The Feed's state | `features/feed/cubit` |
| `UiMessage` | freezed | A one-time SnackBar | `core/common`: every screen uses it |
| `RelativeTime` | pure functions | "5m" / "5 minutes ago" | `core/common`: no Flutter |
| `UserAvatar`, `PostCard`, `RelativeTimeText` | widgets | Shared post UI | `core/design_system/widgets` |

---

## 🌱 Folder Structure Changes

- **New:** `drift_schemas/`, `lib/core/database/{tables,daos}/`, `lib/features/feed/cubit/`.
- **Tests:** `test/core/database/`, `test/features/feed/`, `test/core/common/relative_time_test.dart`, and new helpers and fakes.
- **Removed:** `lib/core/database/.gitkeep`, and the Feed's temporary sample links.

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Demo data | 4 users, 6 posts in Kotlin lists | 15 posts in bundled JSON | the iOS JSON + 2 demo-user posts, served by an in-memory server |
| Dates | recomputed on every fetch | fixed July 2026 | rebased once per launch; gaps kept |
| Cache | Room | SwiftData | drift |
| Writes | `@Insert(onConflict = REPLACE)`: the cascade deleted bookmarks, comments and chat replies | SwiftData upserts by id | `insertOnConflictUpdate`, never REPLACE (a test shows the cascade) |
| What the feed shows | every cached post | every cached post | `feed_items` ⨝ `posts`: only the paged-in window |
| Paging | offset 3 + "Load more" button | offset 6, triggered by `onAppear` | cursor, page 6, infinite scroll with Retry and "all caught up" footers |
| Like / bookmark | Room first, then the API, no rollback | local only | drift first, then the server's answer, or a rollback + SnackBar |
| Comment counts | stored | stored (the seed claims 18 on p1, ships 3) | derived by the server on every response |
| Relative time | a precomputed `timeAgo` string | `RelativeDateTimeFormatter` (abbreviated), injectable `now` | `RelativeTime` + `intl`, an injected `Clock` / zone clock, a spoken form for screen readers |
| Avatars | Coil, but avatars never rendered | `AsyncImage` | `cached_network_image` with an initials fallback |
| Logout | keeps the cache | keeps the cache | wipes the cache, then the token |

The iOS edition is closest in spirit (an observable local store). The Flutter edition adds the pieces both native editions skipped: a server that owns the data, a window table, cursors, and rollback.

---

## 🎤 Interview Notes

**Q: What does "offline-first" mean in this app, concretely?**
A: Screens never render network responses. They subscribe to drift queries. A refresh writes the server's page into drift, and the query re-emits. With no network, the last cached window is still there, and the failure becomes a SnackBar instead of an empty screen.

**Q: Why upsert and never `insertOrReplace`?**
A: SQLite's REPLACE resolves a conflict by deleting the old row and inserting a new one. The delete fires `ON DELETE CASCADE`, so every row that references the post (its feed membership, its bookmark, later its comments) silently disappears. The Android edition lost bookmarks exactly this way. An upsert updates in place.

**Q: Why cursor pagination instead of offsets?**
A: An offset is relative to the list *now*. When a new post arrives at the top, "skip 6" returns the previous page's last post again. A cursor names a position ("after this post"), so new posts land above it and pages never repeat or skip.

**Q: Where does the optimistic update live, and how is it rolled back?**
A: In the repository. It writes drift first and keeps the previous state, calls the API, then writes either the server's answer or the snapshot. The Cubit only shows "Couldn't update the like." A second tap while the first request is out is ignored, so a rollback always restores a state the server had confirmed.

**Q: Dart is single-threaded. Why does the repository need a lock?**
A: Single-threaded isn't the same as atomic: every `await` is a point where other code runs. A load-more that started before a refresh could finish after it and append page 3 to the new page 1. The `Lock` makes them take turns. A test holds the load-more in flight to prove the refresh waits.

**Q: How did you avoid flashing "No posts yet" on the first launch?**
A: drift announces a write *after* the write's future completes. Right after the first refresh, the Cubit's latest list was still the old, empty window, so it briefly concluded "the server has no posts". Now, after a successful refresh, it reads the window once more (`watchFeed().first`, which waits for the re-run query) before deciding. A Cubit test reproduces the flash when the fix is removed.

**Q: Logout with requests still in flight: what can go wrong?**
A: An answer for the old user can arrive after the wipe and be cached for the next user. A late 401 for the old session can even sign out the *new* user. `ApiGuard` records which session sent the request and drops the answer, or skips the expiry, if the session changed meanwhile.

**Q: Which traps did this phase hit?**
A:
- drift's `watch()` emits after the write's future completes, so a state decided right after a refresh can see the old window (§11.21).
- A `DELETE` that removes no rows sends no notification, so code waiting for "the next emission" can wait forever (§11.22).
- `package:drift/drift.dart` exports `isNull` / `isNotNull`, which clash with test matchers; import it with `show` in tests (§11.23).
- With drift's default delayed stream cleanup, a widget test hangs when the database is closed in tear-down; use `closeStreamsSynchronously: true` (§11.24).
- `NumberFormat.compact()` keeps three significant digits ("1.29K"); set `maximumFractionDigits = 1` for "1.3K" (§11.25).

---

## 📝 Learning Checklist

- ✅ Model a cache in drift with foreign keys, JOINs and a membership table
- ✅ Write upserts and know why REPLACE cascades
- ✅ Read the UI only from drift streams (offline-first)
- ✅ Page with cursors, and keep refresh and load-more from interleaving (`Lock`)
- ✅ Implement optimistic updates with rollback in the repository
- ✅ Tie requests to the session that sent them
- ✅ Derive Cubit state from a stream plus an operation's outcome, without flicker
- ✅ Format relative times and compact counts with an injected `Clock` and `intl`
- ✅ Test with an in-memory database, gated fakes and regression tests that fail without the fix
- ⬜ Post detail, comments and create post, with a tested v1 → v2 migration (Phase 4)
- ⬜ Bookmarks offline with Undo, search, profiles (Phase 5)

---

## 🚀 Future Improvements

- **Phase 4:** post detail, comments (served by the server that already counts them) and create post. drift v2 adds `comments`, with the first generated migration test (`make-migrations`).
- **Phase 4, careful:** a created post is added to the top of the window. If that window is empty because the first refresh failed, the cursor must still start from the top.
- **Phase 6:** "Simulate network failure" and "Expire session" in Settings → Developer, to try the offline and 401 paths by hand.
- **Stale pages vs in-flight writes:** a refresh that the server answered *before* a like reached it can briefly show the post unliked, until the like's own answer arrives. Per-post versions (or keeping pending writes on top of fetched pages) would remove that flicker.
- **Paging state across launches:** the cursor lives in memory, because the fake server re-seeds on every launch. With a real backend it could be stored with the window (Android Paging's "remote keys").
