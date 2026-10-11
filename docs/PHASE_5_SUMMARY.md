# Phase 5 — Search + Bookmarks + Profile

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 5, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions solved the same problems.

---

## 🎯 Phase Goal

Phase 5 fills three tabs:
- **Search:** people and posts from the server. Typing is debounced, a stale search is cancelled, chips choose All / People / Posts, and the results stay **live**: a like made anywhere shows in them at once.
- **Bookmarks:** the saved posts work offline, refresh from the server, and a removed bookmark can be undone from the SnackBar.
- **Profiles:** mine on the Profile tab (with Edit profile and Log out), anyone else's pushed above the tabs, each with a header and the person's posts.
- **Edit profile:** a validated form with a discard guard. A save renames me on every post and comment I wrote, on every screen, because they all JOIN one row.

It also ships the second schema change, and the first for data the *client* owns: drift v3 adds `recent_searches`, with a generated and tested migration.

---

## 🧱 What Was Implemented

- **Packages:** `stream_transform` (`switchMap`, `combineLatest`); dev: `fake_async`.
- **Fake backend** (`core/network/`)
  - `FakeServer`:
    - `search`: case-insensitive "contains"; people by name or bio (never the viewer), the most followed first; posts by content or author name, newest first;
    - `getUser` and `getUserPosts` (all of them, newest first; 404 for an unknown user);
    - `updateMe`: validated like the client, stores trimmed values. Posts and comments store their author's *id*, so the new name shows on everything the user wrote;
    - `getBookmarks`: the viewer's own, the most recently bookmarked first.
  - DTOs: `SearchResponseDto`, `UpdateProfileRequestDto` (`toJson` only, `avatarURL`).
  - Services: `SearchApiService` / `FakeSearchApiService` (400 ms), `UserApiService` / `FakeUserApiService` (500 ms reads, 350 ms update), and `FeedApiService.getBookmarks` (500 ms).
- **drift v3** (`core/database/`)
  - `recent_searches`: the normalized query (trimmed, lower-case) as the key, the text as typed, `searchedAt`.
  - New DAOs: `UsersDao` (one profile), `BookmarksDao` (the list, mirroring a refresh), `SearchDao` (caching results, reading them back by id, the recent-search rules).
  - `PostsDao` gains `watchPostsByAuthor` and `replacePostsByAuthor` (a profile's posts, mirrored).
  - `CacheDao.clearAll` wipes `recent_searches` too: they are the signed-in user's.
  - `schemaVersion` 3; `make-migrations` exported `drift_schema_v3.json` and regenerated the steps. The new `from2To3` step creates the table, and a hand-written v2 → v3 data-integrity test sits next to the generated upgrade paths.
- **Domain:** `SearchScope`, `SearchHits`, `SearchResults`; `SearchRepository`, `BookmarkRepository`, `ProfileRepository`; 12 use cases (Search 5, Bookmarks 2, Profile 5).
- **Data**
  - `SearchRepositoryImpl`: caches what the server found and returns the ids; `watchResults` reads them back with two live queries merged by `combineLatest`, in the server's order.
  - `BookmarkRepositoryImpl`: mirrors the server's bookmarks; adding and removing stay `PostRepository.setBookmarked`, the optimistic write every screen uses.
  - `ProfileRepositoryImpl`: refreshes a profile and mirrors the user's posts (a 404 removes their cached ones); `updateProfile` waits for the server, then upserts my row.
- **`UiMessage`** gains an optional action (`UiMessageAction.undo`). State stays plain data; the View maps the action to a Cubit method.
- **Screens**
  - Search: `SearchBloc` (debounce + restartable, scopes, live results, recent searches), with idle, loading, results, no-matches and error states.
  - Bookmarks: `BookmarksCubit` (offline list, pull to refresh, remove + Undo).
  - Profile: `ProfileCubit` (`@factoryParam userId`), one Cubit for mine and others'; Log out (with confirmation) moved here from the placeholder.
  - Edit profile: `EditProfileCubit` (`@factoryParam userId`), a full-screen dialog, Name / Bio (`n/160`) / Avatar URL, "Discard changes?".
- **Navigation:** `UserProfileRoute.redirect` sends my own id to `/profile`, and `openProfile` (used by every screen) switches to the Profile tab for my id and pushes everyone else's.
- **Validators:** bio (at most 160 characters as people count them); the avatar URL uses the image-URL rule.
- **Also fixed:** a refresh failure that beats drift's first read no longer hides "Showing saved posts" (Feed, Post Detail, Comments, and the new screens), with a regression test (§11.32).
- **Tests:** 505 in total (153 new).

### Differences from the plan

- **No `GET /me` and no `WatchCurrentUserUseCase`.** The Profile tab and Edit profile get the session's user id from the `AuthBloc` and pass it with `@factoryParam`, like every other id. `GET /users/{id}` serves my own profile too, and the one private field `/me` would add (the email) is already in the session. So Profile has 5 use cases, not 6.
- **Undo bookmarks the post again**, so it comes back at the top: a bookmark's time is the server's, and this one is new.
- **"Refresh when the tab opens"** means the first time. The shell keeps the tab alive, and bookmarks made elsewhere reach it through drift.
- **Save is also disabled while nothing has changed.**
- **`fake_async` tests only the real 300 ms debounce timing.** Behaviour that switches streams (restartable, "drops the pending search") is tested in real time with a short debounce: `switchMap` stalls in a synchronous fake-time body (§11.29).
- **iOS autocorrect in the search field:** Material's `SearchBar` exposes no `autocorrect` switch, so iOS may change "ada" to "Ada" as focus leaves. The search is case-insensitive, so the results don't change.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **Composed event transformers**
  - `debounceRestartable`: `switchMap` to a delayed value is the debounce, and `restartable()` cancels the running handler. Blank queries, submits and retries skip the delay (`immediate`) but go through the same pipeline, so they too replace whatever was in flight.
  - **A search is a request, then a subscription.** The handler awaits the request, then stays on `emit.forEach` over the cached results. The next query's restart ends that subscription, so a stale query can never overwrite the screen.
  - `emit.isDone` after an `await`: once a newer query has restarted the handler, nothing after it belongs to the screen.
  - "The same query came back" (`ada` → `ad` → `ada`) skips the *request* but follows the results again: the restart ended the subscription that kept them live (§11.16, extended).
- **Live results by id:** `search` caches what it found and returns ids; `watchResults` reads those rows back. A like on Post Detail is a drift write, and the results re-emit. `combineLatest` merges the people and posts queries, and the repository restores the server's order (SQL returns rows in no particular order).
- **Client-owned data in the database:** recent searches are keyed by the normalized query. An upsert moves a repeat to the top with its latest spelling, and a `DELETE … WHERE key NOT IN (SELECT … LIMIT 10)` (`isNotInQuery`) keeps ten.
- **Mirroring with `isNotIn`:** a bookmarks refresh deletes the bookmark rows the server no longer has (the posts stay cached); a profile refresh deletes that author's cached posts the server left out.
- **One write, every screen:** `updateProfile` upserts one `users` row. The Feed, Search, Bookmarks, Profile, Post Detail and Comments all JOIN it, so they all re-render with the new name.
- **Undo, honestly:** remove → SnackBar with an action → `undoRemove()`. Undo first awaits the removal, because a second request for the same post while one is in flight is dropped (one request per post).
- **One Cubit, two kinds of profile:** `ProfileCubit` takes a user id; only the View's buttons differ (`isMine`). The header and the posts are combined into one value, so the header never shows with the posts unread ("No posts yet" would flash).
- **go_router:** a route-level `redirect` on `GoRouteData` handles deep links, but `push` can't land in a tab (the shell's page would be pushed twice). `openProfile` decides between `go` and `push`.
- **Accessibility:** each count is its own semantics node (`container: true`), read as "4.8K Followers".
- **Testing**
  - `fake_async` for exact timing; real time with a short debounce for anything that switches streams.
  - Mutation checks: swapping `restartable()` for `concurrent()` fails two Search tests; marking posts fetched too early fails the Profile regression test; the old failure path fails the Feed regression test.
  - App flows that start from a cache (`pumpConnectHub(beforeLaunch: …)`).
- **Four new traps** (conventions §11.29–11.32)
  - `switchMap` (and so `restartable()`) stalls in a synchronous `fakeAsync` body.
  - Pushing a location that redirects into a `StatefulShellRoute` tab crashes the Navigator (duplicate page keys).
  - A mocked Bloc's state is read once by `BlocBuilder`: one state per widget test.
  - A fast failure can beat drift's first read, so the failure branch must read the cache too.

---

## 🔁 Data Flow (this phase)

```
Search
SearchView ─ typing ─▶ SearchQueryChanged ─▶ debounce 300 ms (switchMap) ─▶ restartable handler
   submit / recent tap ─▶ SearchSubmitted ─▶ save recent + SearchQueryChanged(immediate)
handler: emit loading ─▶ SearchUseCase ─▶ SearchRepository.search ─▶ API search ─▶ SearchDao.cacheResults
         ─▶ ids (SearchHits) ─▶ emit.forEach(watchResults(ids)) ─── live until the next query restarts it
watchResults: watchUsers(ids) ─┐
              watchPosts(ids) ─┴─ combineLatest ─▶ server order ─▶ SearchResults ─▶ state ─▶ View (scope filter)

Bookmarks
open / pull ─▶ refreshBookmarks ─▶ API getBookmarks ─▶ BookmarksDao.replaceBookmarks (mirror)
remove ─▶ setBookmarked(false) (drift at once) ─▶ SnackBar "Removed from bookmarks" · Undo
Undo ─▶ await the removal ─▶ setBookmarked(true) ─▶ back at the top (a new bookmark time)

Profile
/profile ─▶ ProfilePage (my id from AuthBloc) ─┐
/users/:id ─▶ ProfilePage(id) ─────────────────┴▶ ProfileCubit(id)
   watchUser ⊕ watchUserPosts (combineLatest) ─▶ header + posts
   refreshUser ∥ refreshUserPosts ─▶ upsert user │ mirror posts │ 404 ─▶ "This profile isn't available."

Edit profile
Save ─▶ UpdateProfileUseCase (trims) ─▶ API PATCH /me ─▶ UsersDao.upsertUser ─▶ every JOIN re-emits ─▶ page closes
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `lib/core/database/tables/recent_searches_table.dart` | The v3 table. |
| `lib/core/database/daos/{users,bookmarks,search}_dao.dart` | One profile; the bookmarks list; search results and recent searches. |
| `drift_schemas/app_database/drift_schema_v3.json`, `test/drift/app_database/generated/schema_v3.dart` | The exported v3 schema and its test snapshot. |
| `lib/core/network/api/{search,user}_api_service.dart`, `fake_{search,user}_api_service.dart` | The search and profile endpoints. |
| `lib/core/network/dto/{search_response,update_profile_request}_dto.dart` | The search answer and the profile request body. |
| `lib/domain/model/{search_scope,search_hits,search_results}.dart` | Search models. |
| `lib/domain/repository/{search,bookmark,profile}_repository.dart` | Contracts. |
| `lib/domain/usecase/*` (12 files) | Search, bookmarks and profile use cases. |
| `lib/data/repository/{search,bookmark,profile}_repository_impl.dart` | The repositories. |
| `lib/features/search/{bloc/,search_page,search_view}` | Search: events, state, the transformer, the Bloc, Page, View. |
| `lib/features/bookmarks/**`, `lib/features/profile/**`, `lib/features/edit_profile/**` | The other three screens: Cubit, state, Page, View. |
| `test/helpers/fakes/{fake_search,fake_bookmark,fake_profile}_repository.dart` | Scriptable fakes for the Bloc and Cubit tests. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `RecentSearches` / `RecentSearchRow` | drift table / row | Recent searches | `core/database/tables` |
| `UsersDao`, `BookmarksDao`, `SearchDao` | drift accessors | Profiles, bookmarks, search caching and recents | `core/database/daos` |
| `Schema3`, `from2To3` | generated / step | The v3 schema and its migration | `app_database.steps.dart` / `app_database.dart` |
| `SearchApiService`, `UserApiService` (+ fakes) | interfaces / implementations | Endpoints | `core/network/api` |
| `SearchResponseDto`, `UpdateProfileRequestDto` | `json_serializable` | Wire shapes | `core/network/dto` |
| `SearchScope`, `SearchHits`, `SearchResults` | enum / freezed | Search in domain terms | `domain/model` |
| `SearchRepository`, `BookmarkRepository`, `ProfileRepository` (+ `Impl`) | contracts / implementations | Search, bookmarks, profiles | `domain/repository` / `data/repository` |
| `UiMessageAction` | enum | A message's button (Undo) | `core/common` (next to `UiMessage`) |
| `SearchBloc`, `SearchEvent`s, `SearchState` | Bloc / sealed events / freezed class | Search | `features/search/bloc` |
| `debounceRestartable` | `EventTransformer` | Debounce + restartable | `features/search/bloc` |
| `BookmarksCubit` / `BookmarksState` | Cubit / freezed class | Bookmarks (one class: the Undo message outlives the list) | `features/bookmarks/cubit` |
| `ProfileCubit` / `ProfileState` | Cubit / freezed union | Any profile | `features/profile/cubit` |
| `EditProfileCubit` / `EditProfileState` | Cubit / freezed with getters | The form | `features/edit_profile/cubit` |
| `openProfile` | function | Push someone else's profile, switch to my tab | `core/navigation/app_routes.dart` |

---

## 🌱 Folder Structure Changes

- **New:** `lib/features/search/bloc/`, `lib/features/{bookmarks,profile,edit_profile}/cubit/`, and their `test/features/…` counterparts.
- **Replaced:** the Search, Bookmarks, Profile and Edit profile placeholders are real screens now.

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Debounce | Flow `debounce(350)` + `distinctUntilChanged` | Combine `debounce(300 ms)` + `removeDuplicates` | an event transformer: `switchMap` to a delayed event, 300 ms |
| Stale searches | `flatMapLatest` cancels them | not cancelled (a new `Task` each time) | `restartable()` cancels the request *and* its live results |
| What it searches | posts with Room `LIKE`; people from a hard-coded list | the cached posts, filtered in memory; people = their authors, by name | the fake server; people by name or bio, posts by content or author |
| Scopes | – | – | All / People / Posts chips, filtering without a new request |
| Recent searches | Room; saved on **every** debounced query, case-sensitive, 10 when read | UserDefaults; saved on submit and recent tap, case-insensitive, 8 | drift; saved on submit or result tap, case-insensitive, trimmed, 10 kept |
| Live results | yes (a Room flow) | a snapshot | yes (drift by id, `combineLatest`) |
| Buttons in results | drawn but not wired; people rows not tappable | none | like, bookmark, comments and author all work |
| Bookmarks | a Room table; removing there is local only | an `isBookmarked` flag | the server's, cached in drift and mirrored on refresh |
| Bookmarks order | by bookmark time | by post date | by bookmark time (the server's) |
| Undo / refresh | – / – | – / – | SnackBar Undo / on open and pull to refresh |
| My profile | the hard-coded "user-alex" | UserDefaults, seeded from the session, kept across logouts | the session's user, from the server, wiped at logout |
| Others' profiles | – | from the first cached post's author | fetched by id, with their posts mirrored |
| Unknown profile | – (only its own; a missing row loads forever) | an endless spinner | "This profile isn't available." |
| Counts | "1.2k" (truncated), no Posts count | compact, with a Posts count | `NumberFormat.compact` ("4.8K"), with a Posts count |
| Edit profile save | Room only | UserDefaults only | the server, then the cache |
| New name on posts | never (authors copied into each post) | never (authors copied) | everywhere at once (authors JOINed) |
| Discard changes / log out confirmation | – / – | – / – | "Discard changes?" / "Log out?" |

The closest match is iOS's recent searches, which already saved on submit and deduplicated case-insensitively. The Flutter edition adds what both editions skipped: a server that owns bookmarks and profiles, results that stay live, a real Undo, and edits that reach every screen.

---

## 🎤 Interview Notes

**Q: Why is Search a Bloc when everything else is a Cubit?**
A: Typing is a stream of events that needs shaping: debounced, with stale searches cancelled. An event transformer says that in one line (`debounceRestartable`). A Cubit would need hand-written timers and cancellation bookkeeping.

**Q: How do the results stay live, and why doesn't an old query overwrite a new one?**
A: The handler doesn't stop after the request: it stays on `emit.forEach` over the cached results, so every drift change re-emits them. When the next query arrives, `restartable()` cancels the handler, which ends that subscription. The old query can't emit any more.

**Q: Why does `search` return ids instead of results?**
A: The results are read back from the cache by id, like every other screen reads drift. A like on Post Detail changes the cached post, so the search results change too, with no event bus or refresh.

**Q: When is a recent search saved?**
A: On a keyboard submit or when a result is opened, never per keystroke. Otherwise "a", "ad" and "ada" would all become history, as on Android. It is trimmed, deduplicated ignoring case (the latest spelling wins), and only the ten newest are kept.

**Q: How does Undo work, and what can go wrong?**
A: Remove is the normal optimistic bookmark write, and the SnackBar's Undo bookmarks the post again. The catch: only one request per post runs at a time, so an Undo tapped while the removal is still in flight would be dropped. Undo therefore waits for the removal first.

**Q: Why can't `/users/<my id>` simply redirect to `/profile` when it is pushed?**
A: `/profile` lives inside the tab shell. Pushing it onto the root navigator would put the shell's page on the stack a second time, and the Navigator rejects duplicate page keys. The redirect works for `go` and deep links; for taps, `openProfile` switches tabs with `go`.

**Q: How does editing my name update posts everywhere?**
A: Posts and comments store the author's id and JOIN the `users` table on every read. Saving the profile upserts one row, and every query that JOINs it re-emits. Both native editions copied the author into each post, so an edit never reached them.

**Q: Why not test the debounce with `fake_async` everywhere?**
A: `switchMap` awaits the cancel of the stream it switches away from. That future completes on the real event loop, which a synchronous `fakeAsync` body never reaches, so the pipeline stalls after the first switch. `fake_async` checks the exact 300 ms on a single query; switching is tested in real time.

**Q: What made "Couldn't refresh. Showing saved bookmarks." disappear in a test?**
A: With zero latency, the refresh failed before drift had delivered the cache, so "is anything on screen?" saw nothing. The failure branch now reads the cache as it is at that moment (`firstValue`), as the success branch already did. The same fix went into the Feed, Post Detail and Comments; a Feed regression test fails without it.

---

## 📝 Learning Checklist

- ✅ Compose event transformers: debounce + restartable, with immediate events through the same pipeline
- ✅ Keep results live with `emit.forEach`, and end them with a restart
- ✅ Read cached results by id; merge streams with `combineLatest`
- ✅ Store client-owned data in drift with a normalized key and a limit
- ✅ Mirror server lists (bookmarks, a profile's posts) with `isNotIn`
- ✅ Offer Undo through a message action, and handle the in-flight race
- ✅ One write that updates every screen (the JOINed author)
- ✅ Route-level redirects, and their limit inside a shell
- ✅ Test timing with `fake_async`, and know when it can't be used
- ⬜ Chat, notifications and settings (Phase 6)
- ⬜ Open-source polish and final docs (Phase 7)

---

## 🚀 Future Improvements

- **Phase 6:** Settings → "Clear cache" keeps bookmarks, the signed-in user and recent searches (the spec's list), and its Developer switch can show Search and Bookmarks offline.
- **Follow / unfollow** on other people's profiles (read-only today).
- **Paging search results and a profile's posts** with cursors, like the feed.
- **Deleting one recent search** (swipe) as well as clearing them all.
- **A search field without autocorrect** (a custom field), if the iOS behaviour bothers users.
