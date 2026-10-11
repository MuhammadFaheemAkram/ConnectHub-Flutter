# Roadmap

All seven build phases are complete. These are natural next steps, roughly in order of learning value.

## Done

- ✅ **Phase 1 — Foundation:** FVM toolchain, `material_ui`, design system, typed routes with a sign-in gate, the 5-tab shell, DI root, CI.
- ✅ **Phase 2 — Fake auth + session:** an in-memory fake server with accounts and tokens, secure storage, an `AuthBloc` that drives the router, Login / Sign Up.
- ✅ **Phase 3 — Feed + offline cache:** drift v1, cursor paging with infinite scroll, optimistic likes and bookmarks with rollback.
- ✅ **Phase 4 — Post detail, comments, create post:** drift v2, with a generated and tested migration.
- ✅ **Phase 5 — Search, bookmarks, profiles:**
  - a debounced, restartable `SearchBloc` with live results;
  - offline bookmarks with Undo;
  - profile edits that rename you everywhere;
  - drift v3.
- ✅ **Phase 6 — Chat, notifications, settings:**
  - ordered sends with retry;
  - a realtime channel for typing and replies;
  - Activity with live badges;
  - Settings applied from the first frame;
  - drift v4.
- ✅ **Phase 7 — Open-source polish:** the docs, screenshots and community files, plus a dark-mode and large-text pass with a test tour of every screen.

## Next ideas

- **Real backend:**
  - `dio` implementations of the API service interfaces (repositories, Cubits and screens stay as they are);
  - a token refresh on a 401 (an interceptor that retries once) instead of ending the session;
  - the realtime channel over a WebSocket, with reconnect and backoff.
- **Retry unsent messages automatically** when the connection returns (`connectivity_plus`), with an offline banner.
- **Localization:** `flutter_localizations` + `gen-l10n` (ARB files), so the language setting actually translates the UI. Today it is a saved label: English, Español, Français or Deutsch.
- **Following people:** follow and unfollow on profiles (the counts exist, the action doesn't), and a feed of the people you follow.
- **Photos:** pick a picture (`image_picker`) and upload it, instead of pasting an image URL.
- **Longer histories:** page older messages and notifications, as the feed already does.
- **Push notifications** (FCM / APNs) once there is a real server, each opening the post or chat it is about.
- **Integration tests** on devices (`integration_test`), plus golden tests for the design-system widgets.
- **Adaptive layout:** a `NavigationRail` on tablets and in landscape, with Chats as a list–detail pair.
- **CI:** an iOS simulator build on a macOS runner, plus coverage reporting.
- **Screen-reader pass on devices:** TalkBack and VoiceOver reading order. The automated tour checks labels, tap targets and contrast, but not the order.
- **A large long-press label for the tabs**, like iOS's Large Content Viewer. Today's tooltip stays at the normal size.
- **Dynamic color** on Android 12+ (the Android edition has it), with the contrast tests run on the colors it produces.
