/// A language choice on the settings page: the device's, or a set one.
enum AppLanguage {
  system(null),
  english('en'),
  french('fr');

  const AppLanguage(this.language);

  /// The language code the app speaks; null follows the device.
  final String? language;

  /// The choice that sets [language], or [system] for none.
  static AppLanguage of(String? language) => values.firstWhere(
    (choice) => choice.language == language,
    orElse: () => system,
  );
}
