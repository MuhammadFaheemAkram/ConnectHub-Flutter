# Testing

```bash
fvm flutter analyze                                   # no issues allowed
fvm dart format --output=none --set-exit-if-changed .
fvm flutter test                                      # 737 tests, about 35 s
```

CI (`.github/workflows/flutter-ci.yml`) runs the same commands on every push to `main` and every pull request. It also regenerates the code and fails if the committed files are stale.

## What is covered

| Area | Tests | Highlights |
|---|---:|---|
| Cubits and Blocs | 160 | every screen's states (loading / empty / error / loaded with no false-empty flash), failures as SnackBars, debounce and restartable search, `droppable()` submits, Undo, reloading after "Clear cache" |
| Views | 117 | each screen's states and its main interaction, with mocked Cubits; the auto-scroll effect; large-text layouts |
| Repositories | 101 | on the **real** fake server and an in-memory database: paging without duplicates, optimistic writes and rollback, mirroring, the REPLACE-cascade regression, 20 concurrent chat sends in order, retries without duplicates, the unread rules, session expiry |
| Fake server + reply scheduler | 66 | seeding and date rebasing, login and sign-up rules, tokens, idempotent likes, derived comment counts, cursor pages 6 / 6 / 5, search, chat (client ids, replies in turn, a channel per user), notifications; reply timing in fake time |
| DAOs | 60 | JOIN reads, upserts, mirroring that keeps unsent messages, message order, unread sums, recent-search rules, `clearAll` covering every table, "Clear cache" keeping the right rows |
| Design system | 51 | theme and WCAG contrast of every custom pairing, `PostCard`, `UserAvatar`, comment and chat widgets, typing indicator (with and without animations), badges and their semantics |
| Accessibility tour | 39 | every screen and key state, light and dark, at 200 % text: no overflow, tap targets ≥ 48 × 48, every tappable labelled, text contrast; tab labels and badges at 300 % |
| Navigation | 38 | every rule of `authRedirect`, typed locations, tabs and their back stacks, screens above the shell, full-screen dialogs |
| App-level flows | 38 | the real app on the real DI graph: sign in, deep links through sign-in, session expiry, feed offline, post and comments, search, bookmarks, profiles, chat send and reply, activity, settings, Clear cache |
| Common + storage | 35 | validators (every rule and message), relative time, `firstValue`, secure session storage |
| API services + DTOs | 21 | each fake service authenticates, fails offline, and answers 401 without a session |
| drift migrations | 9 | every upgrade path from v1 to v4, plus data integrity for each step |
| DI | 2 | the real container resolves every Bloc, Cubit and repository |
| **Total** | **737** | |

## How the tests are built

- **Fakes over mocks.**
  - Repository fakes (`test/helpers/fakes/`) behave like the real ones: their `watch…` streams emit the current value, then every change, asynchronously, like drift.
  - Mocks (`mocktail`, `MockCubit` / `MockBloc` from `bloc_test`) appear only in widget tests.
- **The real data stack.** `DataStack` wires the real repositories to the real `FakeServer` (zero latency), an in-memory database (`NativeDatabase.memory()`) and the secure-storage mock. Gated API wrappers hold a request in flight, or lose its answer, to test ordering and retries.
- **The real app.** `pumpConnectHub` builds the real composition root with only these swaps: in-memory database, zero-latency network, `InMemorySharedPreferencesAsync`, `PackageInfo.setMockInitialValues`. Pair it with `tearDown(getIt.reset)`.
- **Offline images.** `test/flutter_test_config.dart` installs an image cache that can't download. The default cache asks `path_provider` for a directory the moment it is created; in tests that lookup fails, and the unhandled failure used to fail whichever test happened to be running.
- **Time.**
  - A fixed `Clock` everywhere dates matter.
  - `fake_async` for exact timings that don't switch streams (the 300 ms debounce, the reply scheduler).
  - Real time with short delays where a future is created outside the fake zone or a stream is switched (see the gotchas).
  - App tests pump past the 1.9 s chat reply timers, because a pending timer fails a widget test.
- **Bounded waits.** `nextEvent()` wraps `StreamQueue.next` in a timeout, so a broken stream fails fast instead of hanging the suite.
- **Accessibility.** The tour runs on a phone-width but very tall surface, so every list item is built and checked by `meetsGuideline(androidTapTargetGuideline / labeledTapTargetGuideline / textContrastGuideline)`; a layout overflow anywhere fails the test.

## Proving the tests can fail

Several tests were checked by breaking the code on purpose (a mutation check):
- removing the chat `Lock`: the server receives `Three, One, Two`, and the ordering test fails;
- recording a refresh's outcome before reading the cache: three `ChatDetailCubit` tests fail;
- removing the v3 → v4 migration step: four migration tests fail;
- swapping `restartable()` for `concurrent()` in Search: two tests fail;
- removing the feed's resize check: the "window grew" test fails.

## Gotchas worth knowing

- **A drift stream's first value can predate a write you just made.** Read "what is cached now" with `firstValue` after a write, not the stream's last value.
- **`Stream.first` can hang under fake async** (a drift stream's cancel never finishes there): use `firstValue`.
- **A future created outside `fakeAsync` never resumes inside it** (for example a server seeded in `setUp`). Neither does anything that awaits the root zone's `_nullFuture`, which is why `switchMap` stalls in a fake-time body.
- **A mocked Bloc's state is read once** by `BlocBuilder`: one state per widget test, or drive changes through `whenListen` and a `StreamController`.
- **`ListTile` merges its children's semantics**; **`scrollUntilVisible` needs `scrollable:`** when a screen has more than one `Scrollable`; **local times depend on the machine's time zone**.

These, and more, are recorded as verified traps in the shared Flutter conventions (`00-CONVENTIONS.md` §11).
