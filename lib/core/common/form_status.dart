/// Where a form's submission stands. Shared by every form (sign in, sign up,
/// and later create post and edit profile).
enum FormStatus {
  /// Editing; nothing has been sent yet (or the last attempt was invalid).
  idle,

  /// The request is in flight: the submit button shows a spinner.
  submitting,

  /// The server rejected it; the form shows the error message.
  failure,

  /// Done. The screen is about to go away, so the button stays disabled.
  success,
}
