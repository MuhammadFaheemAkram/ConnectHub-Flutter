/// What a search shows: everything, or only people or only posts.
///
/// The scope only filters what is on screen. The server always answers with
/// both people and posts, so switching scope needs no new request.
enum SearchScope { all, people, posts }
