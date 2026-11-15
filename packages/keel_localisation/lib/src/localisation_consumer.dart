/// A widget that shows words. It names the namespaces it reads, and a
/// `LocalisedBuilder` hands it their bundles in the same order.
abstract interface class LocalisationConsumer {
  /// Constants from the generated `Locales`, such as
  /// `[Locales.offerings, Locales.general]`.
  List<String> get namespaces;
}
