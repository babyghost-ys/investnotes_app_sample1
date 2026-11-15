import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the language the person chose across launches. Null means the
/// device's language.
class LanguageStore {
  const LanguageStore({this.key = 'keel_localisation.language'});

  final String key;

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(key);

  Future<void> write(String? language) async {
    final preferences = await SharedPreferences.getInstance();
    if (language == null) {
      await preferences.remove(key);
    } else {
      await preferences.setString(key, language);
    }
  }
}
