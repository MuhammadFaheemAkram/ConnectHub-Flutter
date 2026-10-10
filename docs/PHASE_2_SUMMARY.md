# Phase 2 — Fake Auth + Session

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 2, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions solved the same problems.

---

## 🎯 Phase Goal

Phase 2 makes the sign-in gate real:
- **Sign up / sign in** against a fake backend, with validated forms and honest error messages.
- **A session that survives restarts**, stored where credentials belong: the Keychain / Keystore.
- **An app-wide `AuthBloc`** that the router's gate follows. Signing in or out still needs no navigation code anywhere.
- **A return address:** a deep link (or the screen open when a session expires) survives the trip through Login.

It also lays the data foundations every later phase uses: `Result`, the `AppException` vocabulary, the in-memory `FakeServer`, the simulated network, and `ApiGuard`.

---

## 🧱 What Was Implemented

- **Packages:** `flutter_bloc`, `bloc_concurrency`, `freezed_annotation`, `json_annotation`, `flutter_secure_storage`; dev: `freezed`, `json_serializable`, `bloc_test`, `mocktail`, `async`.
- **Core types** (`core/common/`)
  - `Result<T>` (Dart 3.13 primary constructors, as in MovieExplorer).
  - A sealed `AppException` hierarchy:
    - `Network`, `NotFound`, `Unauthorized`, `InvalidCredentials`, `EmailTaken`, `DataFormat`, `Unknown`;
    - the user-facing messages follow the iOS edition.
  - `Validators`: email, password, confirm password and name, with the exact messages from the spec.
  - `IdGenerator`, `DemoAccount`, `FormStatus`, `AppConfig`.
- **Fake backend** (`core/network/`)
  - `FakeServer`
    - In memory, seeded on first use from `assets/json/auth_user.json` (copied from the iOS edition).
    - Accounts:
      - the demo account `demo@connecthub.app` / `connecthub`;
      - sign-up creates more; emails are unique, case-insensitive.
    - Tokens: `fake.<userId>.<random>`, validated by `authenticate()`, revocable with `revoke()`.
    - It throws the same `InvalidCredentialsException` for an unknown email and a wrong password.
  - `NetworkSimulator`: latency (×0 in tests) and a `failRequests` switch.
  - `AuthApiService` (the contract) and `FakeAuthApiService` (800 ms, then the server).
  - DTOs: `UserDto` (`@JsonKey(name: 'avatarURL')`) and `AuthResponseDto`. `AssetJsonLoader` reads with `cache: false`.
- **Session** (`core/storage/` + `data/`)
  - `SessionStorage`: `flutter_secure_storage` holds `{token, userId, email}` as JSON, behind a plain record type. A corrupt entry is dropped.
  - `SessionRepositoryImpl.watchSession()` is a behaviour-subject-style stream (`Stream.multi`):
    - the current state first (restored from storage once), then every change;
    - a sign-in that lands while storage is still being read is never overwritten by the stale stored value.
  - `SessionState`: `signedIn(session)` or `signedOut(reason)`, with `SignOutReason.none` / `loggedOut` / `expired`.
  - `AuthRepositoryImpl`: sign-in and sign-up save the session; logout clears it.
  - `ApiGuard`:
    - turns any API call into a `Result`, and logs unexpected exceptions;
    - expires the session on a 401.
  - Use cases: `LoginUseCase`, `SignUpUseCase`, `LogoutUseCase`, `WatchSessionUseCase`.
- **App-wide `AuthBloc`**
  - Events `AuthSubscriptionRequested` (`restartable`) and `AuthLogoutRequested` (`droppable`); state `unknown` / `authenticated` / `unauthenticated(reason)`.
  - It is created and owned by `ConnectHubApp`, provided above `MaterialApp.router`, and followed by the router through a `StreamListenable`.
- **The gate:** `authRedirect(AuthState, Uri)`
  - Unknown → the splash.
  - Signed out → Login.
  - Signed in → off the gate screens.
  - A **return address** (`from`) travels through the splash, Login and Sign Up. It is dropped after a deliberate logout, kept after an expiry, and validated as a safe in-app path.
- **Router fix:** `_visibleLocation`. On a refresh, go_router re-checks the *base* location. With a screen pushed on top, the gate is now given what is actually on screen (see the concepts below).
- **Screens**
  - **Splash.**
  - **Login:**
    - a `LoginBloc` with field events and a `droppable()` submit;
    - field errors stay quiet until the first submit, then update live;
    - "Use demo account" fills the form through the Bloc;
    - the server's error appears under the fields;
    - a session-expired notice.
  - **Sign Up:** a `SignUpBloc`, four fields, the same rules.
  - **Profile placeholder:** "Signed in as …", and Log out with a confirmation dialog.
  - `PlaceholderSession` is gone.
- **Root-level screens:** a `BackToFeedButton` replaces Back/Close when the screen was opened directly and has nothing underneath.
- **Design system:** `NoticeBanner`, `ButtonProgress`, `showConfirmationDialog`.
- **Android:** `android:allowBackup="false"`, so the Keystore-backed session isn't restored onto another device, where it couldn't be decrypted.
- **Tests:** 98 new, **138 in total**.
- **Docs:** the README (fake backend, session storage, the sign-in flow) and this summary. Two new verified traps in `00-CONVENTIONS.md` §11.19–11.20.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **An event-driven Bloc for app-wide state**
  - `emit.forEach` turns a stream into states for as long as the Bloc lives, then cancels it. There is no manual `StreamSubscription`.
  - Each event type gets its own concurrency rule: `restartable()` for the subscription, `droppable()` for logout.
  - The Bloc never navigates; the router follows it.
- **Bloc vs Cubit, concretely**
  - `droppable()` on a form submit is the whole double-tap guard; a Cubit would need a hand-written `if (submitting) return;`.
  - A closed Bloc's emitter ignores late emits, while a Cubit's `emit` throws after close. So Blocs need no `isClosed` checks after an `await`.
- **Bridging a Bloc into go_router:** `refreshListenable` takes a `Listenable`; a Bloc offers a `Stream`. `StreamListenable` (a `ChangeNotifier` that notifies per event) is the whole adapter.
- **Owning app-scoped objects in `State`:** the root widget creates the Bloc itself (the router needs the instance before the first build), provides it with `BlocProvider.value`, and closes it in `dispose`.
- **Derived state with freezed:** `const LoginState._()` enables getters such as `emailError`, computed from the values, so errors can never disagree with the fields.
- **A behaviour subject without RxDart:** `Stream.multi` plus a `sync: true` broadcast controller.
  - The watcher subscribes *before* the restore starts, so no change can be missed.
  - The restore doesn't overwrite a newer sign-in.
- **Records as a boundary type:** `typedef StoredSession = ({String token, String userId, String email})` keeps `core/storage` independent of `domain/`.
- **Secure storage vs preferences**
  - The token goes to the Keychain / Keystore (`flutter_secure_storage`).
  - Preferences go to `shared_preferences` (Phase 6).
  - On iOS the Keychain outlives an uninstall. A reinstalled app can therefore find an old token, which this fake server still accepts for the demo user.
- **An interceptor-like guard:** `ApiGuard.run` is the single place where a 401 becomes "session expired". It is the role a `dio` interceptor plays with a real backend.
- **Typed query parameters:** non-path fields of a typed route (`from`) become encoded query parameters: `/login?from=%2Fposts%2Fp3`.
- **Open-redirect safety:** only relative, in-app paths are followed. `https://…`, `//host` and the gate screens themselves are ignored.
- **Two go_router / flutter_test traps** (now §11.19–11.20)
  - `rootBundle` caches `loadString` *futures*. In the next `testWidgets`, that cached future belongs to a dead fake-async zone and never completes. Each test passed alone; the full run timed out on a spinner. Fixed with `cache: false`.
  - After a `push`, a refresh redirect sees the base location (`/feed`), not the pushed `/posts/p1`. The return address would forget the post. Fixed by reading `router.state.uri` when the redirect re-checks the current location.
- **Testing**
  - `MockBloc` + `whenListen` for views, and events matched by type and field (they have no `==`).
  - A `Completer` gate holds a request open, to prove `droppable()`.
  - `FlutterSecureStorage.setMockInitialValues`.
  - App-level tests on the *real* DI graph, with just two swaps (mock storage, zero latency).

---

## 🔁 Data Flow (this phase)

```
Launch ── AuthBloc(unknown) ── router: /splash?from=…
            │ AuthSubscriptionRequested → emit.forEach(watchSession())
            ▼
   SessionRepository ── restore once ── SessionStorage.read() (Keychain / Keystore)
            │ SignedIn(session) / SignedOut(reason)
            ▼
   AuthBloc ─▶ authenticated / unauthenticated ─▶ StreamListenable ─▶ router re-runs authRedirect

Sign in ── LoginSubmitted (droppable) ─▶ LoginBloc ─▶ LoginUseCase ─▶ AuthRepository
            ─▶ ApiGuard.run(FakeAuthApiService.login) ─▶ NetworkSimulator (800 ms) ─▶ FakeServer
            ◀─ AuthResponseDto(token, user) ─ SessionRepository.save ─▶ SignedIn ─▶ … ─▶ the Feed / `from`

Any API call returning 401 ─▶ ApiGuard ─▶ SessionRepository.expire() ─▶ SignedOut(expired)
            ─▶ Login with "Your session has expired…" and `from` = the screen the user was on
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `assets/json/auth_user.json` | The demo user (iOS seed). |
| `lib/core/common/{result,app_exception,validators,id_generator,demo_account,form_status,app_config}.dart` | Core types. |
| `lib/core/network/fake_server/fake_server.dart` | The in-memory backend: accounts, tokens. |
| `lib/core/network/fake_server/{network_simulator,seed_loader}.dart` | Latency and failures; seed reading. |
| `lib/core/network/api/{auth_api_service,fake_auth_api_service}.dart` | The auth endpoints and their fake. |
| `lib/core/network/dto/{user_dto,auth_response_dto}.dart` (+ `.g.dart`) | Wire models. |
| `lib/core/storage/session_storage.dart` | The session in secure storage. |
| `lib/data/repository/{session,auth}_repository_impl.dart` | Session and auth implementations. |
| `lib/data/repository/api_guard.dart` | API call → `Result`; 401 → expiry. |
| `lib/domain/model/{session,session_state}.dart` (+ `.freezed.dart`) | Session models. |
| `lib/domain/usecase/{login,sign_up,logout,watch_session}_use_case.dart` | Use cases. |
| `lib/features/auth/bloc/auth_*.dart` | The app-wide `AuthBloc`. |
| `lib/features/auth/login/**`, `lib/features/auth/sign_up/**` | Forms: Bloc, events, state, Page, View. |
| `lib/core/navigation/{stream_listenable,back_to_feed_button}.dart` | Bloc → router bridge; deep-link-safe Back. |
| `lib/core/design_system/widgets/{notice_banner,button_progress,confirmation_dialog}.dart` | Shared UI. |
| `lib/di/app_module.dart` | `AssetBundle` and `FlutterSecureStorage` registrations. |
| `test/helpers/{test_dependencies,fixtures,stream_helpers}.dart`, `test/helpers/fakes/*` | Test infrastructure. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `Result`, `AppException` | sealed classes | Typed success/failure, user-facing messages | `core/common`: shared vocabulary |
| `FakeServer` | `@lazySingleton` | The backend's data and rules | `core/network/fake_server`, reached only through services |
| `NetworkSimulator` | `@lazySingleton` | Latency and simulated failures | transport, separate from server logic |
| `AuthApiService` / `FakeAuthApiService` | interface / implementation | The auth endpoints | `core/network/api`: replaceable by `dio` |
| `SessionStorage` | class (+ `StoredSession` record) | Secure persistence | `core/storage`: infrastructure, no domain types |
| `Session`, `SessionState`, `SignOutReason` | freezed / enum | The session and why it ended | `domain/model`: pure Dart |
| `SessionRepository` / `Impl` | contract / implementation | Restore, save, clear, expire; the state stream | `domain/repository` / `data/repository` |
| `AuthRepository` / `Impl` | contract / implementation | Sign in, sign up, log out | same |
| `ApiGuard` | `@lazySingleton` | Result mapping; 401 → expiry | `data/repository`, used by every repository |
| `AuthBloc` | Bloc | The app-wide session state | `features/auth`, provided above the router |
| `LoginBloc`, `SignUpBloc` | Blocs | Form state and submission | `features/auth/<form>/bloc` |
| `StreamListenable` | `ChangeNotifier` | Stream → `Listenable` | `core/navigation`: the router's need |
| `BackToFeedButton` | widget | Back/Close, or "go to the feed" when nothing is underneath | `core/navigation`: knows the Feed route |

---

## 🌱 Folder Structure Changes

- **New:** `assets/json/`, `lib/core/{common,network/{api,dto,fake_server},storage}/`, `lib/data/{mapper,repository}/`, `lib/domain/{model,repository,usecase}/`, and `lib/features/auth/{bloc,login/bloc,sign_up/bloc}/`.
- **Tests:** `test/core/{common,network,storage}/`, `test/data/repository/`, `test/features/auth/`, and `test/helpers/fakes/`.
- **Removed:** `lib/core/navigation/placeholder_session.dart`, and the `.gitkeep` files of the folders that now have code.

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Fake auth | anything valid works; the name comes from the email | anything valid → the same demo user; `blocked@…` errors | real accounts in an in-memory server; a wrong password errors |
| Session storage | DataStore (plain preferences) | UserDefaults (plain) | `flutter_secure_storage` (Keychain / Keystore) |
| Session restore | splash ViewModel reads DataStore once | `RootViewModel` + `SessionStore.restore()` (600 ms sleep) | `AuthBloc` + `watchSession()`, no artificial delay |
| Who navigates after sign-in | the screen, via a `NavigateToHome` effect | the root swaps flows when the session stream changes | nobody: the router's gate re-runs on the `AuthBloc` stream |
| Form state | `MutableStateFlow` + validators | `@Observable` properties | freezed state with derived errors, plus field events |
| Double-submit guard | `isLoading` flag | `isLoading` flag | `droppable()` transformer |
| Expired session | – | `.unauthorized` exists, but no global handling | `ApiGuard` → `expire()` → Login with a reason and a return address |
| Logout | clears the session; keeps the caches | clears the session; keeps the caches | clears the session (Phase 3+ wipes the caches too) |

The closest match is iOS's root-switching. The Flutter difference is that the switch is *declarative*, a pure function of (session, location), so deep links and return addresses fall out of the same rule.

---

## 🎤 Interview Notes

**Q: Where should an auth token live on a phone?**
A: In the platform's secure store: the Keychain on iOS, the Keystore-backed encrypted storage on Android, via `flutter_secure_storage`. Never in `shared_preferences`: those are plain files that backups and rooted devices can read. Also consider backups. Here `android:allowBackup="false"` keeps the token from being restored onto a device where its key doesn't exist.

**Q: Why is auth state a Bloc and not a Cubit?**
A: It is driven by two inputs of different kinds: a long-lived session subscription and a user intent (log out). As events, each is explicit and observable, and each gets its own concurrency rule (`restartable` for the subscription, `droppable` for logout). `emit.forEach` also manages the subscription for us.

**Q: Why doesn't Login navigate after a successful sign-in?**
A: Navigation is a function of state. Sign-in only saves the session. The `AuthBloc` emits `authenticated`, the router's `refreshListenable` fires, and `authRedirect` moves the user. There is one code path for sign-in, sign-up, session restore and expiry, instead of four.

**Q: How do you keep a deep link working when the user must sign in first?**
A: The gate records the intended location as a `from` query parameter and carries it through the splash, Login and Sign Up. Once authenticated, it sends the user there. It is validated as a relative in-app path (no open redirects) and dropped after a deliberate logout.

**Q: How do you handle an expired token globally?**
A: One wrapper, `ApiGuard.run`, runs every API call. A 401 calls `SessionRepository.expire()`, and the router does the rest: Login, with an explanation and a return address. Repositories and screens never special-case it. With `dio`, this would be an interceptor.

**Q: What's a race you guarded against in the session repository?**
A: Restoring is async (a Keychain read). If a sign-in completes while the read is still pending, the stale "signed out" from storage must not overwrite it. Watchers subscribe to changes before the restore starts, and the restore only applies if nothing newer happened. A test holds the read open with a gated fake to prove it.

**Q: Why are form errors hidden until the first submit?**
A: Showing "Email is required." before the user has typed anything is hostile. After the first submit the user wants feedback, so the errors are derived live from the values: freezed getters on the state, not stored fields that could go stale.

**Q: Your widget tests passed one by one but hung together. Why?**
A: `rootBundle.loadString` caches the *future*. The first test created it in its fake-async zone. The next test received the same future, whose continuation was scheduled in a zone nobody pumps any more. Reading with `cache: false` fixed it, since the fake server keeps the parsed data anyway.

---

## 📝 Learning Checklist

- ✅ Model app-wide session state with an event-driven Bloc and `emit.forEach`
- ✅ Choose event transformers deliberately (`restartable`, `droppable`)
- ✅ Bridge a Bloc into `GoRouter.refreshListenable`
- ✅ Carry a safe return address through an auth gate
- ✅ Store credentials in the Keychain / Keystore with `flutter_secure_storage`
- ✅ Build a "current value, then changes" stream with `Stream.multi`, race-free
- ✅ Centralize 401 handling (`ApiGuard`)
- ✅ Validate forms with derived freezed getters, quiet until the first submit
- ✅ Test Blocs with `bloc_test`, views with `MockBloc`, and the app on the real DI graph
- ⬜ Cache the feed in drift and read it offline (Phase 3)
- ⬜ Optimistic like/bookmark with rollback, and cursor pagination (Phase 3)
- ⬜ Migrations as the schema grows (Phases 4–6)

---

## 🚀 Future Improvements

- **Phase 3:** the first authenticated endpoints.
  - The fake API reads the token and `ApiGuard` expires on 401; this phase built that path and tested it directly.
  - Plus drift, the offline feed, and `UiMessage` for one-time SnackBars. It was planned for this phase, but nothing here needs it yet.
- **Phase 6:** Settings → Developer gains "Simulate network failure" and "Expire session", to try these paths by hand.
- **Refresh tokens:** a real backend would issue short-lived access tokens plus a refresh token. `ApiGuard` would refresh once on a 401 before expiring the session.
- **Biometric unlock** (Face ID / fingerprint) before using a stored session would be a natural extension of secure storage.
