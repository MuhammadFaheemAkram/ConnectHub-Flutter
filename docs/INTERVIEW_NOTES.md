# Interview Notes

Questions you could be asked about this app, with short answers grounded in its code. Use them to rehearse explaining a real Flutter codebase end to end. Each phase write-up has more questions on its own topic.

---

## Architecture

**Q: Walk me through the architecture.**
A: Three layers plus infrastructure:
- **domain/** is pure Dart: entities, repository contracts, use cases.
- **data/** implements the contracts: repositories, `ApiGuard`, mappers.
- **core/** holds infrastructure: the fake backend behind API interfaces, drift, secure storage and preferences, the design system, navigation.
- **features/** has a Page, a View and a Cubit/Bloc per screen.

Dependencies point inwards. The key rule: screens read only the drift cache. Repositories refresh it from the API, and drift's streams carry every change to every screen.

**Q: Why do screens read only the cache, never the network?**
A: Three wins:
- offline-first: cached posts show at once, even with no connection;
- one source of truth: a like on Post Detail updates the Feed, Search and Profile, because they all watch the same rows;
- the UI never deals with requests.

The cost is a mirroring strategy: each refresh upserts what the server returned and deletes what it no longer has, in one transaction.

**Q: Why is there a fake server instead of fake repositories?**
A: So the data layer is real. Repositories, mapping, caching, optimistic writes and the 401 handling all run against API interfaces. A `dio` implementation of those interfaces would replace only the fake services. Keeping the server in memory also shows the cache mirroring it: after a restart, the next refresh brings the client back in line.

**Q: Why does every repository call go through `ApiGuard`?**
A: It is the one place that ties requests to the session:
- a 401 expires the session once, for every repository (the role of an HTTP interceptor);
- an answer that arrives after its session ended is dropped, so it can't be cached for the next user;
- unexpected exceptions become a generic error.

## Auth and navigation

**Q: How does the app decide between Login and the Feed?**
A: The router owns it. A top-level `redirect` calls `authRedirect(AuthState, Uri)`, a pure function, and a `refreshListenable` re-runs it whenever the `AuthBloc`'s state changes. Screens never navigate after a sign-in or logout. Because it's pure, every rule (unknown session → splash, signed out → login with a return address, signed in on an auth route → `from` or `/feed`) is a one-line unit test.

**Q: What happens to a deep link while signed out?**
A: The gate sends `/posts/p3` to `/login?from=%2Fposts%2Fp3`. After sign-in, the same function sends the user to `from`, if it is a safe in-app path. A deliberate logout drops the return address.

**Q: Where does the token live, and why not in preferences?**
A: In `flutter_secure_storage` (Keychain / Keystore): a token is a credential, and preferences are plain files. Settings live in `SharedPreferencesWithCache`, and the server's data in drift: each store fits what it holds.

**Q: Why are detail screens on the root navigator here?**
A: They're reachable from five tabs, so each is one route instead of five per-tab copies, and full-screen screens (the chat composer, the forms) shouldn't sit above a tab bar. The tabs keep their state underneath, in a `StatefulShellRoute.indexedStack`.

## State management

**Q: Cubit or Bloc: how did you choose?**
A: Cubit by default. Bloc where event transformers earn their place:
- the session (`restartable()` subscription);
- the auth forms (`droppable()` submit, so a double tap makes one request);
- Search (debounce + `restartable()`).

**Q: How does a list screen avoid flashing "No posts yet" while it loads?**
A: The state combines two inputs: the cached rows and what the latest refresh found. An empty cache is "loading" while the refresh is pending, "empty" only once it succeeded, and an error only if it failed. Two subtleties:
- after the refresh, the Cubit reads the cache as it is now, because drift reports the refresh's own writes a moment later;
- it records the outcome only *after* that read, so a stale value delivered in between can't meet the new outcome.

**Q: How is search debounced, and why `restartable`?**
A: `debounceRestartable` maps each keystroke to a delayed event with `switchMap`, then `restartable()` cancels the running handler when a newer query arrives. The handler awaits the request, then stays on `emit.forEach` over the cached results, so the results stay live (a like anywhere shows in them) until the next query's restart ends that subscription.

## Offline cache and writes

**Q: Why upserts and never `REPLACE`?**
A: SQLite's `REPLACE` deletes the old row first, and the delete cascades. The Android edition lost bookmarks, comments and chat replies that way on every refresh. `INSERT … ON CONFLICT DO UPDATE` updates in place.

**Q: How does an optimistic like work, and what if it fails?**
A: The repository writes the new state to drift at once, so every screen updates, then calls the server. The server's answer replaces the guess (its count wins); a failure restores the state from before the tap, and the screen shows a SnackBar. A second tap while a request for that post is out is ignored.

**Q: Why cursor pagination?**
A: Offset pages shift when a new post arrives at the top, duplicating or skipping posts. Here, load-more asks for posts older than an opaque cursor (`<createdAt>|<id>`), and the client keeps its window of the feed in its own table (`feed_items`), so a refresh replaces it and posts cached by other screens never leak in.

**Q: What does "Clear cache" delete, and how do the screens cope?**
A: The cached copy of the server's data. It keeps what can't be fetched again or isn't the server's: bookmarked posts and their authors, the signed-in user, unsent messages, recent searches. A synchronous "cleared" signal reaches the screens still open before drift re-reads the emptied tables, and they load again with a spinner instead of showing "nothing here".

## Chat

**Q: Dart is single-threaded. Why does sending need a `Lock`?**
A: No data races, but every `await` lets other code run. Two sends started together both reach their network call, and a slower first request would land second. The `Lock` sends one message at a time, in order, like an actor's mailbox. A test holds the first send back: without the lock, the server receives `Three, One, Two`.

**Q: How do you make a retry safe?**
A: The client makes the message id, and the server keeps it. If the server stored a message but the answer was lost, the client shows "Not sent · Tap to retry"; the retry sends the same id, and the server answers with the message it already has instead of storing a copy.

**Q: How does the typing indicator stay right across quick messages?**
A: The server counts pending replies per conversation. Typing starts with the first and stops after the last, so two quick messages give one continuous indicator. The iOS edition switched it off after each reply.

**Q: How does a reply stay read while you're looking at the chat?**
A: The repository counts who watches each conversation's messages. While the chat screen watches, a reply is stored as read and the server is told; otherwise the next refresh would bring the unread count back.

**Q: Why does the realtime channel belong to a session?**
A: Its events are one user's. It closes at logout, and an event for an ended session is dropped, so the previous user's reply can't land in the next user's cache.

## Settings and accessibility

**Q: How do you avoid a light flash when the saved theme is dark?**
A: `SharedPreferencesWithCache` is created before `runApp` (`@preResolve`), so every read afterwards is synchronous, and the app-scoped `SettingsCubit` starts with the saved theme on the first frame. The Android edition read its setting asynchronously and flashed light.

**Q: What did the large-text pass change?**
A: An app-level test tours every screen at 200 % text in both themes. It found four real defects and a paging bug:
- an overflowing chat tile;
- a "Not sent" label that didn't wrap;
- an unlabelled search control;
- 36 px tap targets on the comment avatars;
- a Feed that never asked for the next page when its window grew without a scroll.

An on-device check at about 235 % found words breaking mid-word, which no test reports. The fixes:
- side-by-side controls stack above 130 %;
- the counts wrap onto rows;
- the tab bar keeps its label size, like iOS's own tab bar, with the label on a long press;
- badges stop growing at 130 %.

**Q: How do you test accessibility?**
A: With Flutter's guidelines in the tour: `androidTapTargetGuideline` (48 × 48), `labeledTapTargetGuideline` and `textContrastGuideline`, on a tall surface so every list item is checked. Unit tests also check WCAG contrast for every custom colour pairing.

## Testing

**Q: What does the test suite look like?**
A: 737 tests:
- unit tests for validators, the fake server, DAOs and migrations;
- repositories on the real fake server with an in-memory database;
- `bloc_test` for every Cubit and Bloc, and widget tests with mocked Cubits;
- app-level flows on the real DI graph;
- an accessibility tour.

Fakes are preferred over mocks, and every async wait is bounded.

**Q: Tell me about a hard test bug.**
A: Reply tests in `fake_async` never saw a reply. The fake server is seeded from assets in `setUp`, outside the fake zone, and a future created there resumes its awaiters on the real event loop, which a synchronous fake-time body never runs: the reply was never scheduled. The scheduler's timing is tested in fake time on its own; the server and repository tests run in real time with a 1 ms scheduler.

**Q: How do you know a test can fail?**
A: Mutation checks: remove the `Lock`, move the outcome above the cache read, delete a migration step, swap `restartable()` for `concurrent()`. Each time, the targeted test fails.

## Trade-offs and next steps

**Q: What would change with a real backend?**
A: The fake services become `dio` services against the same interfaces, and the realtime channel becomes a WebSocket with reconnect and backoff. The token would need refresh on 401 instead of a sign-out, and unsent messages could retry when connectivity returns. Repositories, drift, Cubits and screens stay.

**Q: What would you improve first?**
A:
- Real translations behind the language setting (`gen-l10n`).
- Automatic retry of unsent messages.
- Paging chat history.
- An integration-test suite on devices, and golden tests for the design system.
