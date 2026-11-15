import 'package:keel_localisation/src/locale_bundle.dart';

/// Builds one namespace's bundle from its decoded JSON.
typedef LocaleFactory =
    LocaleBundle Function(String language, Map<String, Object?> json);

/// Every namespace the app has and how to build each. The generator writes
/// the app's registry next to `Locales`.
class LocaleRegistry {
  const LocaleRegistry(this.factories);

  final Map<String, LocaleFactory> factories;

  Iterable<String> get namespaces => factories.keys;

  LocaleBundle create(
    String namespace,
    String language,
    Map<String, Object?> json,
  ) {
    final factory = factories[namespace];
    if (factory == null) {
      throw ArgumentError.value(namespace, 'namespace', 'Not registered');
    }
    return factory(language, json);
  }
}
