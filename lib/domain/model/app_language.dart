/// The language the user picked. Persisted and shown, but a label only: the
/// app has no translations yet.
enum AppLanguage {
  en('English'),
  es('Español'),
  fr('Français'),
  de('Deutsch');

  const AppLanguage(this.displayName);

  /// The language's name in that language.
  final String displayName;
}
