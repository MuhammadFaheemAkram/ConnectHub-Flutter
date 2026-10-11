# Security Policy

## Supported Versions

ConnectHub is a learning/reference project. Security fixes are applied to the latest `main` only.

| Version | Supported |
|---------|:---------:|
| `main`  | ✅ |

## Reporting a Vulnerability

Please **do not** open a public issue for security problems.

Instead, email **muhammadfaheem004@gmail.com** with:

- a description of the issue and its impact;
- steps to reproduce (a proof of concept if possible);
- any suggested remediation.

You can expect an acknowledgement within a few business days.

## What the App Holds

The app has **no real backend and no API keys**. Its "server" is an in-memory fake inside the app, so nothing you type leaves the device. The only network traffic is image downloads: the seed's placeholder pictures (pravatar.cc, picsum.photos), and any image or avatar URL you enter yourself.

- **The demo account's password is public on purpose** (`demo@connecthub.app` / `connecthub`). Accounts created by sign-up live in memory, and are gone when the app restarts.
- **The session token** is a fake one, but it is handled like a real credential:
  - it is stored with `flutter_secure_storage` (Keychain / Android Keystore), never in plain preferences;
  - Android backup is disabled, so it never reaches a cloud backup;
  - logout and expiry delete it, after wiping the cache.
- **The cache** (drift / SQLite) holds the fake server's posts, profiles, chats and notifications, plus recent searches and unsent messages. It belongs to one user: logout and expiry wipe it, and an answer that arrives after its session ended is dropped instead of cached.
- **Preferences** hold only the appearance, the badges switch and the language label.

The practical attack surface is small. Reports about unsafe patterns (in how the session, the cache or the return address after sign-in are handled), dependency issues or data-handling concerns are still very welcome.
