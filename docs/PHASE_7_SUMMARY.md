# Phase 7 — Open-Source Polish

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 7, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions handled the same phase.

---

## 🎯 Phase Goal

Every feature works after Phase 6. Phase 7 makes ConnectHub a finished portfolio project that someone else can read, run, check and contribute to:
- **Docs** that explain the whole app: its architecture, the tests, the fake backend, and the concepts in it.
- **Screenshots** taken from the simulator, in light, dark and large text.
- **The open-source files:** how to contribute, report a vulnerability, or file an issue.
- **An accessibility pass on every screen,** in dark mode and at large text sizes, with the semantics checked.

The accessibility pass wasn't only a review. It is now a test that visits every screen and key state, and it found real defects, fixed in this phase.

---

## 🧱 What Was Implemented

- **Docs** (`docs/`):
  - `ARCHITECTURE.md`: the layers, who owns what, every screen's state holder, error handling, writes, the realtime channel, the session lifecycle, navigation, DI, persistence, accessibility and the key decisions;
  - `TESTING.md`: the commands, the tests per area, how they are built, the mutation checks and the gotchas;
  - `API_SIMULATION.md`: the services and their latencies, the seed data and what was added to it, accounts and tokens, the server's rules, the reply algorithm, the developer switches, the errors, and what a restart resets;
  - `LEARNING_NOTES.md` (every Flutter / Dart concept in the app) and `INTERVIEW_NOTES.md` (Q&A based on this codebase);
  - `ROADMAP.md` and `SCREENSHOTS.md`, with 12 screenshots: 5 light, 5 dark and 2 at accessibility size AX3, each with alt text.
- **Open-source files:** `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1), `SECURITY.md` (what the app stores, and why the demo password is public), `CHANGELOG.md` (0.1.0 to 0.7.0, one version per phase), and the GitHub bug, feature and pull request templates.
- **The final README:** the phase table, screenshots, the data flow for every screen, "How Chat Works", "Accessibility", a shorter Testing section, the platform comparison, links to every doc, and the roadmap.
- **An accessibility tour** (`test/app/accessibility_tour_test.dart`, 39 tests):
  - The real app, at 200 % text, in light and in dark.
  - Every screen: Feed, Post, Comments, Create Post, Search, Bookmarks, Activity, my profile and someone else's, Edit Profile, Settings, Chats and a chat.
  - Key states: search results, a failed message, the typing indicator, the "Clear cache?" dialog, Login and Sign Up.
  - Each is checked against Flutter's tap-target, labelled-tap-target and text-contrast guidelines, on a tall surface so every list item is built. Any layout overflow fails the test.
  - One more test, at 300 %, checks that the tab labels keep their size and show on a long press, and that the badges stop growing.
- **What the tour found, and the fixes:**
  - **Search and Chats:** Material's `SearchBar` wraps its field in a tappable surface with no label, so a screen reader stopped on an unnamed control. **`AppSearchField`** replaces it: one labelled field with a Clear button, and autocorrect off.
  - **Chats:** `ConversationTile` overflowed at 200 %, because a `ListTile` gives its trailing column a fixed height. It is now a custom row that grows with the text, and still reads as one button ("Grace Hopper, 1 hour ago, …, 2 unread").
  - **Post:** each comment's author picture was a 36 × 36 tap target. It is now 48 × 48, the extra space taken from the padding, so the layout doesn't move.
  - **Chat:** "Not sent · Tap to retry" overflowed by 226 px at 200 %. It wraps now.
  - **Feed:** on the tour's tall surface, the footer spinner never stopped. The list was checked for "near the end" only on a scroll or a state change, so a list that came to fit on screen without scrolling never asked for the next page. A `ScrollMetricsNotification` listener now checks again whenever the viewport or the content changes size: a resized window, an unfolded foldable, the keyboard closing, a smaller text size.
- **What the simulator found at AX3 (about 235 %)**, which the tour can't see (a word broken mid-way isn't an overflow):
  - "System" broke inside its segment;
  - "Followers" and "Following" broke;
  - "Edit profile" wrapped;
  - "Bookmarks" broke in the tab bar;
  - the badges grew over their icons.
- **The large-text rules that fix them:**
  - **`context.prefersStackedLayout`** (text above 130 %) is the one rule. Side-by-side controls stack: Settings' Appearance becomes a radio list (`RadioGroup` + `RadioListTile`), and Profile's two buttons stack, full width.
  - **The profile counts sit in a `Wrap`**, so they move onto a second row instead of breaking a word.
  - **The tab labels keep their size** (`MediaQuery.withNoTextScaling`), as on iOS's own tab bar. A long press shows the label, and screen readers read it.
  - **Badges grow up to 130 %, then stop** (`MediaQuery.withClampedTextScaling`), so they never cover their icon.
- **Cleanup:**
  - No placeholders, temporary buttons, `TODO`s or `print`s are left.
  - `EditProfileState.isLoading`, which nothing used, is gone.
  - Seven app-level test files shared copies of the same finders. They now use `destination`, `appBarTitled` and `tester.selectedTab` from `app_harness.dart`.
- **Test infrastructure:** `test/flutter_test_config.dart` installs an offline image cache for every test. The default cache asks `path_provider` for a directory the moment it is created. In tests that lookup fails, and the unhandled error failed whichever test was running: a flaky failure, first seen in the tour.
- **Package:** `flutter_cache_manager` as a dev dependency, for the test cache's type (it already came with `cached_network_image`).
- **Tests:** 737 in total (43 new): the tour, the large-text layouts of Profile and Settings, and the Feed's "window grew" regression.

### Differences from the plan

- **CI was already done.** It has run since Phase 1. This phase only confirmed that both actions it uses are on their current major versions.
- **The accessibility pass is a test, not a checklist.** A review would have missed most of these defects, and a test keeps them fixed.
- **Screenshots include large text**, not only light and dark: the large-text layouts are part of what this phase shipped.
- **Two deliberate limits on large text** (the tab labels and the badges), each documented with its reason.
- **A test-infrastructure fix** (the offline image cache), and the dev dependency it needs.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **Accessibility guidelines as widget-test matchers.**
  - `meetsGuideline(androidTapTargetGuideline)` checks 48 × 48 targets.
  - `labeledTapTargetGuideline` checks that every tappable has a label.
  - `textContrastGuideline` checks text contrast against what is actually painted behind it.
  - They run on the semantics tree, so the test needs `tester.ensureSemantics()`.
- **Simulating the user's settings in a test.** `tester.platformDispatcher.textScaleFactorTestValue` and `platformBrightnessTestValue` stand in for the system's text size and dark mode, for the real app, theme and `MediaQuery` included. `clearAllTestValues`, registered with `addTearDown`, resets them after the test.
- **A tall test surface.** `tester.view.physicalSize = Size(390 * 3, 6000 * 3)` is a phone's width, but tall enough for lazy lists to build every item, so the guidelines check them all.
- **`TextScaler`, not a factor.** `MediaQuery.textScalerOf(context)` can scale nonlinearly (Android 14 scales large text less than small), so the rule scales a reference size and compares: `scale(14) / 14 > 1.3`.
- **Local text-scaling overrides.** `MediaQuery.withNoTextScaling` and `withClampedTextScaling` change the scaling for one subtree. A tooltip from inside that subtree is shown in an `OverlayPortal`, which inherits the subtree's `MediaQuery`, so the tab bar's long-press label is unscaled too.
- **`Wrap` instead of `Row` + `Expanded`** when content must not break: `Expanded` squeezes each child to a third of the width; a `Wrap` moves it to the next row.
- **`RadioGroup`**, Flutter 3.47's API for radio buttons: the group holds the value and `onChanged`, and each `RadioListTile` has only its `value` (the tiles' own `groupValue` is deprecated).
- **Custom semantics for a custom row.** `MergeSemantics` + `Semantics(button: true)` makes a hand-built row read and act like one `ListTile` button. `ExcludeSemantics` hides the decorative avatar, and the badge's `Semantics(label: '2 unread')` replaces a bare "2".
- **`ScrollMetricsNotification`.** A scroll listener hears only scrolling. When the viewport or the content changes size, Flutter dispatches a `ScrollMetricsNotification` instead, once at the first layout too. That is why the old first-frame check had to go: it would have asked for the second page twice.
- **`testExecutable` in `flutter_test_config.dart`** runs before every test file in its directory tree: here, it replaces a static default (`CachedNetworkImageProvider.defaultCacheManager`).
- **A word broken mid-way isn't an overflow.** Flutter breaks a word that doesn't fit its line, and nothing reports it, so the tour can't see it. Checking on a device at the largest sizes still matters.

---

## 🔁 Data Flow (this phase)

The app's data flow is unchanged. What's new is how the screens adapt, and how the tour checks them.

```
Accessibility tour (once per theme)
textScaleFactorTestValue = 2.0 · platformBrightnessTestValue = light | dark
  ─▶ pumpConnectHub (the real DI graph, an in-memory database, a zero-latency fake server)
  ─▶ a phone-wide, very tall surface (every list item is built)
  ─▶ open a screen or a state (sign in, tap, type, switch on "Simulate network failure")
  ─▶ androidTapTargetGuideline · labeledTapTargetGuideline · textContrastGuideline   (+ any overflow fails)

Large text at runtime
MediaQuery.textScalerOf(context) ─▶ prefersStackedLayout (> 130 %) ─▶ a Column instead of a Row,
                                                                      a RadioGroup instead of a SegmentedButton
NavigationBar ◀─ MediaQuery.withNoTextScaling          UnreadBadge ◀─ MediaQuery.withClampedTextScaling(1.3)

Feed: when to ask for the next page
a scroll ─────────────────────────────▶ ScrollController listener ───┐
a layout (first frame, resize, text) ─▶ ScrollMetricsNotification ───┼─▶ extentAfter < 600 px ─▶ loadMore()
a new page, or a load-more state ─────▶ a check after that frame ────┘   (only if idle and there's more)
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `docs/ARCHITECTURE.md`, `TESTING.md`, `API_SIMULATION.md` | How the app is built, tested, and served. |
| `docs/LEARNING_NOTES.md`, `INTERVIEW_NOTES.md` | Every concept in the app; questions and answers. |
| `docs/ROADMAP.md`, `SCREENSHOTS.md`, `docs/screenshots/*.png` | What's next; 12 screenshots with alt text. |
| `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md` | The open-source files. |
| `.github/ISSUE_TEMPLATE/{bug_report,feature_request}.md`, `.github/PULL_REQUEST_TEMPLATE.md` | Issue and PR templates. |
| `lib/core/design_system/large_text.dart` | `prefersStackedLayout`: the large-text rule. |
| `lib/core/design_system/widgets/app_search_field.dart` | The labelled search field for Search and Chats. |
| `test/app/accessibility_tour_test.dart` | Every screen and state, light and dark, at 200 % text. |
| `test/flutter_test_config.dart` | An offline image cache for every test. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `LargeTextContext` | extension on `BuildContext` | `prefersStackedLayout`: stack side-by-side controls above 130 % text | `core/design_system`, beside the theme: every screen uses the same rule |
| `AppSearchField` | widget | A search field with a Clear button, one labelled control | `core/design_system/widgets` (Search and Chats) |
| `_OfflineCacheManager` | `BaseCacheManager` (test only) | Answers every image request with an error, as offline | `test/flutter_test_config.dart` |
| `destination`, `appBarTitled`, `AppHarness.selectedTab` | test helpers | Find a tab, the top screen, the selected tab | `test/helpers/app_harness.dart`, shared by the app-level tests |

---

## 🌱 Folder Structure Changes

- **New:** `test/app/` (the accessibility tour), `docs/screenshots/`, `.github/ISSUE_TEMPLATE/`.
- **New at the root:** `CHANGELOG.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`.
- **New in `docs/`:** `ARCHITECTURE.md`, `TESTING.md`, `API_SIMULATION.md`, `LEARNING_NOTES.md`, `INTERVIEW_NOTES.md`, `ROADMAP.md`, `SCREENSHOTS.md`, and this summary.

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| The phase itself | squashed: one initial commit holds the whole app and its open-source files, and a docs commit adds all seven phase summaries at once | one commit: docs, the community files, SwiftLint and CI; no Phase 7 summary | one commit, with this summary; every earlier summary was written with its phase |
| CI | added in this phase; it watches `main`, but the repo's branch is `master`, so a push never runs it | added in this phase; it failed until a later commit moved it to a macOS 26 runner and an iPhone 17 simulator | since Phase 1, on every push: the codegen check, format, analyze, test |
| Static checks | Android lint, in CI | SwiftLint, added in this phase | `flutter analyze` with the strict modes, since Phase 1 |
| API simulation doc | yes | – | yes: services, latencies, seed, rules, the reply algorithm, switches, errors |
| Screenshots | a to-do list, no images | 6, light mode only | 12: light, dark and large text, each with alt text |
| Accessibility labels | 12 icons with no description, 9 with hard-coded strings | 5 `accessibilityLabel`s | every tappable labelled, enforced by a test guideline |
| Large text | text grows; no layout adapts | Dynamic Type grows text; no layout adapts | stacking above 130 %, wrapping counts, fixed tab labels, clamped badges |
| Accessibility tests | – | – | a tour of every screen and key state, light and dark, at 200 % text |
| Code changes in the phase | backup and data-extraction rules | – | the defects the tour found, a Feed paging fix, cleanup |

Both native editions treated Phase 7 as paperwork, and both ended it with CI that didn't work: Android's never runs on a push, and iOS's failed until a later fix. Here the workflow has existed since Phase 1, and its exact commands passed at the end of every phase, so this phase could test the app instead: the tour turned "check dark mode and large text" into 39 tests. It found four defects and a paging bug. The simulator found five large-text problems the tour can't see, and a flaky test turned up along the way. All were fixed before the docs described them.

---

## 🎤 Interview Notes

**Q: How do you test accessibility in Flutter?**
A: With the guideline matchers in widget tests: `androidTapTargetGuideline` (48 × 48), `labeledTapTargetGuideline` and `textContrastGuideline`. The tour pumps the real app with the text scale and brightness set through `tester.platformDispatcher`, opens every screen and key state, and checks all three. Any layout overflow fails it too. It runs on a tall surface, so lazy lists build every item.

**Q: What can't an automated tour catch?**
A: Words broken mid-way: Flutter breaks a word that doesn't fit its line, and nothing reports it. Also the reading order, and how natural the labels sound. At AX3, the simulator showed what the tour had passed:
- four words broken mid-way;
- a wrapped button label;
- badges grown over their icons.

A screen-reader pass on devices is on the roadmap.

**Q: Why don't the tab labels grow with the text?**
A: Five labels share a phone's width, and at AX3 "Bookmarks" broke mid-word. iOS's own tab bar keeps its labels at a fixed size for the same reason, and offers the label another way: a long press shows a large version. Here a long press shows the label in a tooltip, and screen readers always read it. The tooltip stays at the normal size, so a large viewer like iOS's is on the roadmap. It's a deliberate, documented limit, and a test pins it.

**Q: How did you decide when to switch layouts?**
A: One rule, `prefersStackedLayout`: above 130 % text, side-by-side controls stack. Past that, a two-word label no longer fits in half a phone's width. The rule scales a reference size through the `TextScaler` rather than reading a factor, because Android 14 scales large text less than small.

**Q: Why replace Material's `SearchBar`?**
A: It wraps its text field in a tappable surface with no label of its own, so a screen reader stops on an unnamed control before reaching the field. The labelled-tap-target guideline caught it on Search and Chats. `AppSearchField` is one labelled field with a Clear button.

**Q: Tell me about the Feed bug the tour found.**
A: The Feed asked for the next page when you scrolled near the end, or when its state changed. The tour's surface grows after launch, so all the posts came to fit on screen with no scroll and no new state, and the footer spinner never stopped. A `ScrollMetricsNotification` listener now checks whenever the viewport or the content changes size. That notification also fires at the first layout, so the old first-frame check had to go, or the second page was asked for twice. The same thing could happen on a device: a window resized in split screen, a foldable unfolding, a smaller text size.

**Q: What was the flaky test, and why did only some runs fail?**
A: The image cache asks `path_provider` for a directory when it is created. In tests there's no platform plugin, so that lookup fails. If nothing awaits the failure yet, it surfaces as an unhandled error in whichever test is running at that moment. `flutter_test_config.dart` now installs an offline cache before every test file, so images show their fallback, as they would offline.

---

## 📝 Learning Checklist

- ✅ Test accessibility with Flutter's guideline matchers, on a surface that builds every item
- ✅ Simulate text size and dark mode in tests with the platform dispatcher's test values
- ✅ Adapt layouts to large text with one rule, through the `TextScaler`
- ✅ Limit text scaling locally (`withNoTextScaling`, `withClampedTextScaling`), and know what it does to tooltips
- ✅ Give a custom row the semantics of a button
- ✅ React to size changes with `ScrollMetricsNotification`, not only to scrolling
- ✅ Configure every test file at once with `flutter_test_config.dart`
- ✅ Write the docs a contributor needs: architecture, testing, the fake backend, a changelog, contribution and security policies
- ✅ Know what automated checks miss, and check on a device

---

## 🚀 Future Improvements

- **A screen-reader pass on devices** (TalkBack, VoiceOver): the reading order, and labels that sound natural.
- **Golden tests** for the design-system widgets in both themes and at large text.
- **Integration tests on devices** (`integration_test`), and an iOS build in CI on a macOS runner.
- **A real backend, localization, retrying unsent messages, following, photo uploads:** see [ROADMAP.md](ROADMAP.md).
