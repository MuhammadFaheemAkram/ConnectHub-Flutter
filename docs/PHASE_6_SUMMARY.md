# Phase 6 — Chat + Notifications + Settings

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 6, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions solved the same problems.

---

## 🎯 Phase Goal

Phase 6 finishes every feature of the app:
- **Chat:** the Chats list (filtered locally as you type) and a chat screen. A message shows at once ("Sending…"), messages go out in the order they were written, and a failed one says "Not sent · Tap to retry". A retry can never post a message twice. The other person "types", then replies, over a realtime channel; a chat on screen stays read.
- **Activity:** notifications with filter chips, a read state the server owns, rows that open their post or profile, "Mark all read", and a live unread badge on the tab.
- **Settings:** System / Light / Dark from the very first frame, the unread badges switch, a language label, "Clear cache", developer switches (simulate network failure, expire session), log out and About.

It also ships the third schema change: drift v4 adds `conversations`, `messages` and `notifications`, with a generated and tested migration.

---

## 🧱 What Was Implemented

- **Packages:** `shared_preferences` (`SharedPreferencesWithCache`), `package_info_plus`; dev: `shared_preferences_platform_interface` (an in-memory store for tests).
- **Fake backend** (`core/network/`)
  - Seeds: the iOS edition's `conversations.json` and `messages.json` (its `"me"` sender is the demo user), and `notifications.json` with a link added to each notification that is about a post or a person.
  - `FakeServer`:
    - `getConversations` (the most recent activity first; a conversation's last message and time are derived from its messages), `getMessages` (oldest first; someone else's conversation answers 404);
    - `sendMessage`: keeps the **client's id**; sending a known id again returns the stored message and schedules no second reply. A blank message, or one over 1000 characters, is refused;
    - `markConversationRead`, and a reply raising the unread count;
    - `chatEvents(viewerId)`: the realtime channel (typing started, a reply with the conversation as it now stands, typing stopped), per user;
    - `getNotifications` (newest first), `markNotificationRead` (404 for someone else's), `markAllNotificationsRead`.
  - `ReplyScheduler`: typing starts 400 ms after a message (unless a reply is already pending), the reply comes 1.5 s later, and typing stops when the *last* pending reply has arrived. A question gets "Good question — let me think about that. 🤔"; anything else gets the iOS edition's eight replies in turn.
  - Services: `ChatApiService` / `FakeChatApiService` (400 ms reads, 350 ms writes; `events()` authenticates like any request, then streams), `NotificationApiService` / `FakeNotificationApiService` (500 ms / 350 ms), and `DeveloperToolsService` / `FakeDeveloperToolsService` for Settings → Developer.
- **drift v4** (`core/database/`)
  - `conversations` (→ `users`), `messages` (→ `conversations` with `ON DELETE CASCADE`; a `status`: sending, sent or failed), `notifications` (with optional links).
  - `ChatDao`: conversations with the other person (JOINed), the unread total (`SUM`), mirroring that keeps unsent messages, pending / confirmed / failed / retried messages, and incoming replies in one transaction. Delivered messages come in time order and unsent ones after them, in the order they were written (a `CASE WHEN` in `ORDER BY`).
  - `NotificationsDao`: mirroring, the unread count, optimistic read writes that return the state from before.
  - `CacheDao.clearAll` covers the new tables; `clearServerData` is "Clear cache".
  - `schemaVersion` 4; `make-migrations` exported `drift_schema_v4.json` and regenerated the steps. `from3To4` creates the tables, and a hand-written v3 → v4 data-integrity test checks that nothing older is lost.
- **Domain:** `Conversation`, `Message` (`MessageStatus`), `AppNotification` (`NotificationKind`), `AppSettings`, `AppThemeMode`, `AppLanguage`; `ChatRepository`, `NotificationRepository`, `SettingsRepository`, `CacheRepository`, `DemoToolsRepository`; 25 use cases.
- **Data**
  - `ChatRepositoryImpl`: sends ordered by a `Lock`, client ids and retry, the realtime channel (opened on first use, bound to the session), the typing map, and the unread rules.
  - `NotificationRepositoryImpl`: mirrors the server's read state; mark read and mark all read are optimistic and rolled back on failure.
  - `SettingsRepositoryImpl` over `SettingsLocalDataSource` (`SharedPreferencesWithCache`, created before `runApp` with `@preResolve`); `CacheRepositoryImpl` (the wipe, then a "cleared" signal); `DemoToolsRepositoryImpl`.
- **App root:** an app-scoped `SettingsCubit` above `MaterialApp.router`, next to the `AuthBloc`; only a theme change rebuilds the app (`BlocSelector`).
- **Design system:** `MessageBubble`, `TypingIndicator`, `ConversationTile`, `NotificationTile`, `UnreadBadge`. `CommentComposer` became `ComposerBar`, with a hint and a limit per use (280 for a comment, 1000 for a message).
- **Screens**
  - Activity: `ActivityCubit` (filters, mark read, mark all, links, pull to refresh).
  - Chats: `ChatsCubit` (the local filter, pull to refresh).
  - Chat Detail: `ChatDetailCubit` (`@factoryParam conversationId`): bubbles, the typing indicator, retry, "Say hello 👋", and the auto-scroll effect.
  - Settings: the app-scoped `SettingsCubit` for the preferences, and the screen's own `SettingsToolsCubit` for "Clear cache" and the developer switches.
  - The shell: a `BadgesCubit` drives the Activity tab's badge and the Feed's Chats badge.
- **"Clear cache" reaches the screens still open:** Feed, Profile, Search, Activity and the badges load again instead of showing their emptied lists as "nothing here".
- **Also fixed**
  - Every list Cubit (Feed, Bookmarks, Comments, Post Detail, Profile and the new ones) now records a refresh's outcome only *after* reading the cache. A stale value delivered meanwhile could otherwise flash "No posts yet" or an error for a frame (§11.33).
  - Unsent messages are ordered by when they were written, whatever the device's clock says (found by a DAO test).
- **Tests:** 694 in total (189 new).

### Differences from the plan

- **`synchronized` was already there.** It arrived in Phase 3, so that refresh and load-more take turns.
- **"Clear cache" also keeps unsent messages**, with their conversations and the other person: they are the user's words, and the server doesn't have them yet (Correctness Rule 7).
- **The screens still open reload after "Clear cache".** The spec says the screens re-fetch on demand, but the shell keeps the tabs alive, so a signal (`CacheRepository.watchCleared`) tells them to.
- **Chat Detail has a "not found" state**, like Post Detail and Profile, and **Chats has pull to refresh**.
- **"Not sent · Tap to retry" sits under the bubble**, on the page's surface. In the error color on my teal bubble it measured 1.18:1 in light mode. My bubble's time is full strength for the same reason (75% opacity measured 3.31:1). Contrast tests guard both.
- **"Expire session" shows a SnackBar** saying what happens next: "Session expired. Your next request will sign you out."
- **A failed mark-read when a chat opens rolls back quietly.** The refresh fails the same way, and its message already says so.
- **Timing tests:** the `ReplyScheduler` is tested in fake time. The fake server's and the repository's reply tests run in real time with a 1 ms scheduler, because the server is seeded outside the fake zone (§11.34).

---

## 💙 Flutter / Dart Concepts Demonstrated

- **A `Lock` in a single-threaded language.** Dart has no data races, but every `await` lets other code run, so two sends could reach the server out of order. `sendMessage` writes the row at once, then delivers under `Lock.synchronized`, like messages through a Swift actor's mailbox. With the first send held back, the server received `['Three', 'One', 'Two']` without the lock; the test fails that way.
- **Client-generated ids make retries safe.** The id is made on the device and the server keeps it. If an answer is lost after the server stored the message, the retry sends the same id, and the server answers with the message it already has.
- **A status per message.** `sending`, `sent` and `failed` live in the `messages` table. A refresh mirrors only `sent` rows, so a refresh can never delete words that haven't reached the server, and an unsent message survives a restart.
- **A realtime channel is just a `Stream`.**
  - The fake service is an `async*` function: it authenticates, then `yield*`s the server's events for that user.
  - The repository holds one subscription per session and handles events with `asyncMap`, one at a time, so "typing stopped" waits until the reply before it is in the cache.
  - The channel closes on logout, and an event that arrives for a session that has ended is dropped.
- **"Open" conversations, counted.** `watchMessages` is a `Stream.multi` that counts its watchers. While a chat's screen watches it, a reply is stored as read and the server is told, or the next refresh would bring the count back.
- **The typing indicator follows pending replies.** The server's scheduler emits "started" for the first pending reply and "stopped" after the last; the repository keeps a set of typing conversations and exposes `Stream<bool>` with `distinct()`.
- **Settings without a flash.** `SharedPreferencesWithCache` is created before `runApp` (`@preResolve`), so reads are synchronous, and the `SettingsCubit`'s first state is the saved theme. `package_info_plus` is resolved the same way.
- **State scoped to where it belongs.** App-wide: the `AuthBloc` and the `SettingsCubit`, above `MaterialApp`. Session-wide: the `BadgesCubit`, in the tab shell, which exists only while signed in. Screen-wide: everything else.
- **Animation with accessibility.** `TypingIndicator` drives three phase-shifted dots from one `AnimationController`, stays still when `MediaQuery.disableAnimationsOf` asks, and reads as "Typing".
- **A reversed list for a chat.** It starts at the newest message with no initial scroll. A new message (mine or theirs) brings the list back to it once: a `BlocListener` keyed on the newest message's id.
- **A signal that beats the database.** The "cache cleared" `StreamController` is synchronous, so the screens hear it the moment the wipe commits, before drift has re-read the emptied tables.
- **drift**
  - `CaseWhenExpression` in `ORDER BY`: sent messages by time, unsent ones by row id.
  - `isNotInQuery` subqueries keep exactly the right rows in "Clear cache".
  - `SUM` for the unread total.
- **Testing**
  - The real `FakeServer` with a quick `ReplyScheduler`; `fake_async` for the scheduler's own timing.
  - `GatedChatApi` holds a send in flight or loses its answer.
  - Mutation checks: removing the `Lock`, recording the outcome before the read, removing `from3To4`.
  - `InMemorySharedPreferencesAsync`, `PackageInfo.setMockInitialValues`, and app tests that pump past the 1.9 s reply timers.

---

## 🔁 Data Flow (this phase)

```
Chat
Send ─▶ SendMessageUseCase (trims) ─▶ ChatRepository.sendMessage
          ├▶ ChatDao.insertPending (status sending, client id) ─▶ the bubble shows "Sending…"
          └▶ Lock ─▶ ChatApiService.sendMessage(clientId) ─▶ confirmSent (server time)  │  markFailed
Retry ─▶ markSending ─▶ Lock ─▶ the same id again ─▶ the server returns what it already has

FakeServer ─ ReplyScheduler ─▶ TypingStarted ─▶ MessageReceived(message, conversation) ─▶ TypingStopped
   └ chatEvents(user) ─▶ ChatApiService.events() ─▶ ChatRepository (one subscription per session, asyncMap)
        typing set ─▶ watchTyping ─▶ ChatDetailCubit.isTyping
        ChatDao.addIncoming (unread 0 if the chat is open; markRead to the server) ─▶ watchMessages / watchConversations

Activity
open / pull ─▶ refresh ─▶ getNotifications ─▶ NotificationsDao.replaceNotifications (read states mirrored)
tap ─▶ markRead (drift at once ─▶ server │ rollback) + open the post or the profile
badges: BadgesCubit ◀─ unread notifications ⊕ unread messages ⊕ "Show unread badges"

Settings
launch ─▶ SharedPreferencesWithCache (preResolve) ─▶ SettingsRepository (sync) ─▶ SettingsCubit ─▶ MaterialApp.themeMode
Clear cache ─▶ CacheDao.clearServerData ─▶ "cleared" (sync) ─▶ Feed, Profile, Search, Activity, Badges load again
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `assets/json/{conversations,messages,notifications}.json` | The chat and activity seeds. |
| `lib/core/network/fake_server/reply_scheduler.dart` | Typing, then the reply, per conversation. |
| `lib/core/network/api/{chat,notification,developer_tools}_service.dart` + fakes | The endpoints and the developer switches. |
| `lib/core/network/dto/{conversation,message,notification,chat_event}_dto.dart` | Wire shapes, and the realtime events. |
| `lib/core/database/tables/{conversations,messages,notifications}_table.dart` | The v4 tables. |
| `lib/core/database/daos/{chat,notifications}_dao.dart` | Chat and notifications in drift. |
| `drift_schemas/app_database/drift_schema_v4.json`, `test/drift/app_database/generated/schema_v4.dart` | The exported v4 schema and its test snapshot. |
| `lib/core/storage/settings_local_data_source.dart` | The preference keys, over `SharedPreferencesWithCache`. |
| `lib/domain/model/{conversation,message,app_notification,app_settings,app_theme_mode,app_language}.dart` | Domain models. |
| `lib/domain/repository/{chat,notification,settings,cache,demo_tools}_repository.dart` | Contracts. |
| `lib/domain/usecase/*` (25 files) | Chat, notifications, settings, cache and developer use cases. |
| `lib/data/repository/{chat,notification,settings,cache,demo_tools}_repository_impl.dart` | The repositories. |
| `lib/core/design_system/widgets/{message_bubble,typing_indicator,conversation_tile,notification_tile,unread_badge}.dart` | The new widgets. |
| `lib/app/theme_mode_mapper.dart` | `AppThemeMode` → Flutter's `ThemeMode`. |
| `lib/features/{activity,chats,chat_detail,settings}/**`, `lib/features/shell/cubit/` | The screens and the badges. |
| `test/helpers/fakes/{fake_chat,fake_notification,fake_settings,fake_cache,fake_demo_tools}_repository.dart`, `gated_chat_api.dart` | Fakes for the Cubit and repository tests. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `ReplyScheduler` | class | The other person's typing and replies | `core/network/fake_server` (part of the fake backend) |
| `ChatEventDto` (+ 3 subclasses) | sealed class | What the realtime channel pushes | `core/network/dto` |
| `Conversations`, `Messages`, `Notifications` | drift tables | The v4 cache | `core/database/tables` |
| `MessageRowStatus` | enum | sending / sent / failed in the database | `core/database/tables` |
| `ChatDao`, `NotificationsDao` | drift accessors | Chat and notifications | `core/database/daos` |
| `Schema4`, `from3To4` | generated / step | The v4 schema and its migration | `app_database.steps.dart` / `app_database.dart` |
| `Conversation`, `Message`, `AppNotification`, `AppSettings` | freezed | Domain models | `domain/model` |
| `ChatRepository` … `DemoToolsRepository` (+ `Impl`) | contracts / implementations | Chat, notifications, settings, cache, developer switches | `domain/repository` / `data/repository` |
| `SettingsLocalDataSource` | class | Preference keys and values | `core/storage` |
| `SettingsCubit` | Cubit (`AppSettings`) | App-wide preferences, the theme | `features/settings/cubit`, provided above `MaterialApp` |
| `SettingsToolsCubit` / `SettingsToolsState` | Cubit / freezed | Clear cache, developer switches | `features/settings/cubit` |
| `BadgesCubit` / `BadgesState` | Cubit / freezed with getters | The unread badges | `features/shell/cubit`, provided by the shell |
| `ActivityCubit` / `ActivityState`, `ActivityFilter` | Cubit / freezed / enum | Activity | `features/activity/cubit` |
| `ChatsCubit` / `ChatsState` | Cubit / freezed with a filter getter | The Chats list | `features/chats/cubit` |
| `ChatDetailCubit` / `ChatDetailState`, `ChatStatus` | Cubit / freezed / enum | One chat | `features/chat_detail/cubit` |
| `MessageBubble`, `TypingIndicator`, `ConversationTile`, `NotificationTile`, `UnreadBadge`, `ComposerBar` | widgets | Chat and activity UI | `core/design_system/widgets` |

---

## 🌱 Folder Structure Changes

- **New:** `lib/features/{activity,chats,chat_detail,settings}/cubit/`, `lib/features/shell/cubit/`, and their `test/features/…` counterparts.
- **Replaced:** the Activity, Chats, Chat Detail and Settings placeholders are real screens now; no placeholder is left.
- **Renamed:** `comment_composer.dart` → `composer_bar.dart` (it serves chat too).

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Chat storage | Room (conversations, messages) | in memory (`actor MessageStore`), not SwiftData | drift, with a status per message |
| Sending | waits for the API (350 ms), then Room | appended locally with a client id; never sent to the (fake) service | shows at once, then goes out in order under a `Lock` |
| A failed send | – | – | "Not sent · Tap to retry", with the same client id |
| Replies | one fixed text after 900 ms, built in the repository | after 1.5 s: a question gets "Good question…", otherwise a random canned reply | the server's `ReplyScheduler` (400 ms typing, 1.5 s reply, canned replies in turn), over a realtime channel |
| Typing indicator | on when you tap Send, before your message appears | turned off after each reply (`defer`): off too early when replies overlap | on with the first pending reply, off after the last |
| Message history | `REPLACE` + `CASCADE`: refreshing the conversations deleted every message | reopening a chat reset it to the seed | mirrors the server, and keeps unsent messages |
| Unread | not cleared when a chat opens | cleared, but every visit to Chats reloads the JSON and brings it back | cleared (here and on the server); replies to an open chat stay read |
| Auto-scroll | – | to the bottom on new messages and typing | to the newest message when one arrives |
| Chats search | name or last message | `.searchable` | name or last message, local |
| Notifications | "Notifications" tab, Room, 6 filter chips | "Activity" tab, in memory, no filters | "Activity" tab, drift, 6 filter chips |
| Read state | local only, kept across refreshes | local only; a refresh resets it | the server's: optimistic, rolled back on failure, mirrored |
| Tapping a notification | opens its post (follows do nothing) | nothing (no links) | opens the post or the profile |
| Tab badge | hard-coded 3 | none | the unread count, live; Settings can hide it |
| Appearance | a dark-mode switch (+ dynamic color); DataStore, read asynchronously | System / Light / Dark; UserDefaults | System / Light / Dark; `SharedPreferencesWithCache`, read before the first frame |
| Notifications switch | saved, no effect | saved, no effect | hides the Activity and Chats badges |
| Languages | English, Spanish, French (labels) | English, Español, Français, Deutsch (labels) | English, Español, Français, Deutsch (labels) |
| Clear cache | deletes nothing (records a time) | deletes every cached post and comment, bookmarks and likes included | deletes the server's data, keeps bookmarks, me, unsent messages and recent searches; open screens reload |
| Developer tools | – | – | simulate network failure, expire session |
| Log out | no confirmation | no confirmation | "Log out?" |
| About | no version | the version | version and build, licenses |

The closest match is iOS's appearance setting, which already read UserDefaults synchronously. The Flutter edition adds what both editions skipped: messages that reach the (fake) server in order and can be retried safely, a typing indicator that survives overlapping replies, a read state the server owns, and a "Clear cache" that keeps what can't be fetched again.

---

## 🎤 Interview Notes

**Q: Dart is single-threaded. Why does chat need a `Lock`?**
A: There are no data races, but every `await` is a point where other code runs. Two sends started together both reach their network call; the first one's latency can be longer, so the server would store them out of order. The `Lock` makes each send wait for the previous one, like an actor's mailbox. A test holds the first send back: without the lock the server receives `Three, One, Two`.

**Q: Why does the client generate message ids?**
A: To make retries safe. If the server stored a message but the answer was lost, the client marks it "Not sent". The retry sends the same id, and the server answers with the message it already has instead of storing a copy.

**Q: How does the typing indicator stay on across overlapping replies?**
A: The server counts pending replies per conversation. Typing starts with the first and stops after the last, so two quick messages give one continuous indicator. The iOS edition turned it off after each reply (`defer`), so it vanished while the second reply was still coming.

**Q: How do replies to an open chat stay read?**
A: The repository counts who watches each conversation's messages. While a chat screen watches, an incoming reply is stored with unread 0, and the server is told; otherwise the next refresh would bring the count back. Opening a chat also marks it read, optimistically, with rollback.

**Q: Why does the realtime channel belong to a session?**
A: Its events are one user's. It closes at logout, and an event that arrives for a session that has ended is dropped, so a reply for the previous user can't land in the next user's cache.

**Q: Why are the settings in `shared_preferences`, and why read them before `runApp`?**
A: They are small, non-secret values the device owns: secure storage is for the token, drift for the server's data. `SharedPreferencesWithCache` loads them once, before the first frame; after that every read is synchronous, so the app starts in the saved theme instead of flashing light first (Correctness Rule 13).

**Q: What does "Clear cache" keep, and how do the screens avoid showing "nothing here"?**
A: It deletes the cached copy of the server's data and keeps what can't be fetched again: bookmarks (with their authors), the signed-in user, unsent messages and recent searches. A synchronous "cleared" signal reaches the screens before drift re-reads the emptied tables, and they load again with their spinner.

**Q: Why aren't the reply tests in fake time?**
A: The fake server is seeded from the asset bundle before the test, outside the fake zone. A future created there resumes its awaiters on the real event loop, which a synchronous `fakeAsync` body never runs, so the reply was never even scheduled. The scheduler's timing is tested in fake time on its own; the rest runs in real time with a 1 ms scheduler.

**Q: How did a refresh flash "No messages" for a frame?**
A: The Cubit set "refresh succeeded" before awaiting the cache read. A stale empty list delivered in between met the new outcome, which means "loaded, and empty". Recording the outcome after the read fixes it; three Chat Detail tests fail with the old order.

---

## 📝 Learning Checklist

- ✅ Order async work with a `Lock`, and prove it with a test that fails without it
- ✅ Make retries idempotent with client-generated ids
- ✅ Model a realtime channel as a `Stream` (`async*` / `yield*`), bound to the session
- ✅ Keep unsent data safe through refreshes, restarts and "Clear cache"
- ✅ Drive a typing indicator from pending work, not from a timer per message
- ✅ Load preferences before the first frame (`@preResolve`), and scope state app-wide, per session or per screen
- ✅ Animate with respect for "reduce motion", and check text contrast on every new fill
- ✅ Order rows with `CASE WHEN`, and keep exactly the right rows with subqueries
- ✅ Know when `fake_async` can't see a future, and test in real time instead
- ⬜ Open-source polish and final docs (Phase 7)

---

## 🚀 Future Improvements

- **Phase 7:** the remaining docs, screenshots in light and dark, the community files, and a large-text pass on every screen.
- **A real socket** behind `ChatApiService.events()`, with reconnect and backoff.
- **Retry unsent messages automatically** when the network comes back.
- **Paging chat history** for long conversations.
- **Delivery and read receipts**, and push notifications.
- **Real translations** behind the language setting (`intl` / ARB files).
