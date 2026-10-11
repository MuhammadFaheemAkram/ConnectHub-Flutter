# Screenshots

Captured on an **iPhone 17 Pro simulator** (iOS, debug build) on 2026-10-11, with the status bar fixed at 9:41, then downscaled to 1000 px tall. Everything on screen comes from the fake server's seed. The avatars are placeholder portraits from pravatar.cc, and the post images are placeholder photos from picsum.photos.

## Light

| Login | Feed | Post |
|:---:|:---:|:---:|
| <img src="screenshots/login-light.png" width="250" alt="Login: the ConnectHub logo, 'Welcome to ConnectHub', email and password fields, a Sign in button, then 'Use demo account' and 'Create an account'"> | <img src="screenshots/feed-light.png" width="250" alt="Feed: Ada Lovelace's post with a mountain photo, 142 likes and 3 comments, then Grace Hopper's post; the Chats icon in the app bar has a badge of 3, the Activity tab has a badge of 3, and a pencil button starts a new post"> | <img src="screenshots/post-detail-light.png" width="250" alt="Post: Ada Lovelace's post above comments from Grace Hopper, Alan Turing and Katherine Johnson, with an 'Add a comment…' field at the bottom"> |

| Search | Someone else's profile |
|:---:|:---:|
| <img src="screenshots/search-light.png" width="250" alt="Search: the query 'ada' with All, People and Posts chips; Ada Lovelace under People and her post under Posts"> | <img src="screenshots/profile-other-light.png" width="250" alt="Ada Lovelace's profile: her photo, the bio 'Enchantress of numbers.', 4.8K followers, 312 following and 3 posts, with her posts below"> |

## Dark

| Chats | Chat | Activity |
|:---:|:---:|:---:|
| <img src="screenshots/chats-dark.png" width="250" alt="Chats in dark mode: a search field, then Grace Hopper with 2 unread, Alan Turing, and Katherine Johnson with 1 unread; the unread conversations are bold"> | <img src="screenshots/chat-typing-dark.png" width="250" alt="A chat with Alan Turing in dark mode: the demo user's new message 'Only if they can also debug.' and Alan's typing indicator below it"> | <img src="screenshots/activity-dark.png" width="250" alt="Activity in dark mode: filter chips (All, Unread, Likes, Comments), 'Mark all read', three unread notifications highlighted with a dot, then the read ones"> |

| My profile | Settings |
|:---:|:---:|
| <img src="screenshots/profile-dark.png" width="250" alt="My profile in dark mode: the demo user's photo and bio, 128 followers, 87 following and 2 posts, Edit profile and Log out buttons, then a post about offline-first apps"> | <img src="screenshots/settings-dark.png" width="250" alt="Settings in dark mode: Appearance (System, Light, Dark), Show unread badges switched on, Language English, Clear cache, and the Developer switches"> |

## Large text

Accessibility text size **AX3** (about 235 %), dark mode.

| My profile | Settings |
|:---:|:---:|
| <img src="screenshots/large-text-profile.png" width="250" alt="My profile at accessibility text size AX3: the name and bio are large, the counts wrap onto two rows, and the tab labels keep their usual size"> | <img src="screenshots/large-text-settings.png" width="250" alt="Settings at accessibility text size AX3: Appearance becomes a list of System, Light and Dark radio buttons, and the badges switch's text wraps beside it"> |

## What to look for

- **Dark mode** comes from the `SettingsCubit` above `MaterialApp.router`. In the dark screenshots, Settings is on "System" and the simulator is dark; choosing Light or Dark overrides it. The choice is read before the first frame, so a saved Dark never flashes light.
- **One source of truth:** Ada's post shows the same 142 likes and 3 comments on the Feed, the Post, Search and her profile, because every screen reads the same drift rows.
- **Live badges:** the Chats icon adds up the unread messages (Grace 2 + Katherine 1). The Activity tab counts the unread notifications. Both follow the cache, so they change as replies arrive and things are read.
- **The typing indicator** is pushed by the fake server's realtime channel 400 ms after a message; the reply follows 1.5 s later.
- **Unread rows** are bold in Chats, and highlighted with a dot in Activity.
- **Large text:**
  - the profile counts wrap onto rows instead of breaking words;
  - side-by-side controls (the Appearance buttons, Edit profile and Log out) stack vertically;
  - the tab labels keep their size, as on iOS's own tab bar (a long press shows the label).

## Retaking them

```bash
fvm flutter build ios --simulator --debug
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted co.bitfuse.flutter.connectHub

xcrun simctl status_bar booted override --time 9:41 --dataNetwork wifi --wifiBars 3 --cellularBars 4 --batteryState charged --batteryLevel 100
xcrun simctl ui booted appearance dark                              # or light
xcrun simctl ui booted content_size accessibility-extra-large       # AX3; "large" is the default

xcrun simctl io booted screenshot docs/screenshots/<name>.png
sips -Z 1000 docs/screenshots/<name>.png                            # downscale (macOS)

xcrun simctl status_bar booted clear                                # afterwards
```
