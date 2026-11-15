import 'package:keel_localisation/src/locale_bundle.dart';

/// Every namespace's bundle in one language.
class LocaleCatalogue {
  const LocaleCatalogue(this.language, this._bundles);

  final String language;
  final Map<String, LocaleBundle> _bundles;

  LocaleBundle operator [](String namespace) {
    final bundle = _bundles[namespace];
    if (bundle == null) {
      throw ArgumentError.value(namespace, 'namespace', 'Not in the archive');
    }
    return bundle;
  }

  /// The bundles for [namespaces], in the same order.
  List<LocaleBundle> all(List<String> namespaces) => [
    for (final namespace in namespaces) this[namespace],
  ];
}
