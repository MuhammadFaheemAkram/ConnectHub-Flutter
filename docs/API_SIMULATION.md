# API Simulation

ConnectHub runs with **no server**. A `FakeServer` lives in memory and owns the data and its rules, and the app reaches it only through API service interfaces, exactly as it would reach a real backend. Swapping in a real one means writing `dio` implementations of those interfaces; repositories, Cubits and screens stay as they are.

```
Repository ─▶ ApiGuard.run ─▶ FeedApiService (interface)
                                  │ FakeFeedApiService
                                  ▼
                          FakeApiClient.authenticate(latency)
                             ├─ reads the token (secure storage), like an auth interceptor
                             ├─ NetworkSimulator: waits the latency, fails if "offline"
                             └─ FakeServer.authenticate(token) ─▶ user id, or 401
                                  ▼
                          FakeServer.getFeed(userId, cursor) ─▶ PostPageDto
```

---

## Services

| Service | Calls | Latency |
|---|---|---|
| `AuthApiService` | `login`, `signUp` | 800 ms |
| `FeedApiService` | `getFeed(cursor, limit)`, `getPost`, `getBookmarks` · `createPost` · `setLiked`, `setBookmarked` | 700 ms reads (500 ms bookmarks) · 600 ms create · 350 ms writes |
| `CommentApiService` | `getComments` · `addComment`, `deleteComment` | 500 ms · 350 ms |
| `SearchApiService` | `search(query)` | 400 ms |
| `UserApiService` | `getUser`, `getUserPosts` · `updateMe` | 500 ms · 350 ms |
| `ChatApiService` | `getConversations`, `getMessages` · `sendMessage(clientId, text)`, `markRead` · `events()` (the realtime channel) | 400 ms · 350 ms · connects at once |
| `NotificationApiService` | `getNotifications` · `markRead`, `markAllRead` | 500 ms · 350 ms |
| `DeveloperToolsService` | `failsRequests`, `expireSession()` | (Settings → Developer) |

Every call except sign-in and sign-up is authenticated: `FakeApiClient` attaches the saved token, crosses the simulated network, and lets the server resolve the token to a user.

---

## Seed data

The server seeds itself on first use from [`assets/json/`](../assets/json/), then keeps everything in memory.

| File | Contents | Additions over the iOS edition's JSON |
|---|---|---|
| `auth_user.json` | the demo user (`u_demo`, `demo@connecthub.app`) | a distinct avatar (`img=68`; the iOS seed reused Alan's) |
| `feed_posts.json` | 17 posts by six people, with likes and images | `p16` and `p17` by the demo user, so My Profile isn't empty |
| `comments.json` | 13 comments | `c12` and `c13`, on the demo user's posts |
| `conversations.json` | 3 conversations (Grace 2 unread, Alan 0, Katherine 1) | none |
| `messages.json` | 10 messages; `"senderId": "me"` is the demo user | `isMine` removed: the client works it out from the session |
| `notifications.json` | 8 notifications (3 unread): likes, comments, follows, mentions | a `postId` or `userId` link on each one about a post or a person |

- **Fresh dates.** Every seed date is shifted by the same amount at launch, so the newest record is five minutes old and the app always looks recent. The gaps between records are kept.
- **Counts come from the server.** `likeCount` starts from the seed and moves with likes. `commentCount` is always counted from the comments themselves (the iOS seed claimed 18 comments on `p1` and shipped 3).

---

## Accounts and tokens

- **Demo account:** `demo@connecthub.app` / `connecthub`. The Login screen's "Use demo account" fills it in.
- **Emails** are compared ignoring case; **passwords** are never trimmed.
- **A wrong password and an unknown email** get the same answer: "Incorrect email or password." The response doesn't reveal which emails have accounts.
- **Sign-up:** the name is trimmed; an email that already has an account gets "An account with this email already exists."
- **Tokens** look like `fake.<userId>.<random>`. Any well-formed token for an existing user is valid, unless it was revoked. The demo user is seeded at every launch, so the demo session survives restarts; an account created by sign-up doesn't, and its token then answers 401.

---

## Server rules

- **Feed pages:** newest first, 6 per page, each ending with an opaque cursor (`<createdAt>|<id>`); the 17 posts arrive as 6 / 6 / 5, and a post created meanwhile can't shift a page.
- **Likes and bookmarks** are per user and idempotent: liking twice counts once. Bookmarks come back the most recently bookmarked first.
- **Posts and comments** are written by whoever the token belongs to. Only a comment's author may delete it; anyone else gets a 404, so a stranger can't confirm the comment exists. Breaking a rule (a blank post, more than 280 characters, a bad image URL) is refused like a 400.
- **Search** is case-insensitive "contains": people by name or bio (never yourself), the most followed first; posts by content or author name, newest first.
- **Profile edits** are validated like the client and stored trimmed. Posts and comments store their author's id, so a new name shows on everything that person wrote.
- **Notifications** come newest first; the read state is the server's, so a client refresh never resets it.

---

## Chat and the reply algorithm

- **Messages keep the client's id.** Sending a known id again returns the stored message and schedules no second reply, so a retry after a lost answer can't duplicate anything. A blank message, or one over 1000 characters, is refused.
- **The other person answers every message** (`ReplyScheduler`):
  1. 400 ms after the message is stored, they start typing, unless a reply in that conversation is already pending (they are still typing);
  2. 1.5 s after that, the reply arrives and raises the conversation's unread count;
  3. typing stops when the **last** pending reply has arrived, so quick messages keep one indicator on.
- **What they say:** a message with a question mark gets "Good question — let me think about that. 🤔"; anything else gets the iOS edition's eight replies in turn ("Sounds good! 👍", "Ha, totally agree.", …).
- **The realtime channel** (`chatEvents(user)`) pushes typing started, a reply (with the conversation as it now stands) and typing stopped, only to the conversation's owner. The client marks a reply read at once when its chat is on screen.

---

## Developer switches (Settings → Developer)

| Switch | Effect | Lifetime |
|---|---|---|
| **Simulate network failure** | every request fails with "Something went wrong with your connection." after its latency, as if offline; cached data stays on screen, and new chat messages end "Not sent" | in memory: resets when the app restarts (it starts from `AppConfig.simulateNetworkErrors`) |
| **Expire session** | revokes the current token on the server; the next request answers 401, `ApiGuard` ends the session, and Login says "Your session has expired. Please sign in again." | until you sign in again |

---

## Errors

| Exception | Message | When |
|---|---|---|
| `NetworkException` | Something went wrong with your connection. Please try again. | the network is "offline" |
| `NotFoundException` | We couldn't find what you were looking for. | an unknown post, user or conversation, or someone else's |
| `UnauthorizedException` | Your session has expired. Please sign in again. | a missing, unknown or revoked token |
| `InvalidCredentialsException` | Incorrect email or password. | login |
| `EmailTakenException` | An account with this email already exists. | sign-up |
| `DataFormatException` | We received an unexpected response. Please try again. | a malformed response |
| `UnknownException` | Something went wrong. Please try again. | anything else (logged) |

---

## What a restart resets

The server lives in memory, so every launch starts from the seed: accounts created by sign-up, posts, comments, likes, bookmarks, messages and read states are gone. The client's cache keeps what it had until the next refresh mirrors the fresh server, and it never drops the messages it hasn't managed to send.
