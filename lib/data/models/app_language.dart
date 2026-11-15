/// A language choice on the settings page: the system's, or a set one.
enum AppLanguage {
  system('SYS', 'System'),
  english('EN', 'English'),
  french('FR', 'French');

  const AppLanguage(this.code, this.spoken);

  /// The short label on the language control.
  final String code;

  /// What VoiceOver and TalkBack say for it; never shown.
  final String spoken;
}
