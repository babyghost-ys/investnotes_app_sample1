/// One namespace's words in one language. Generated classes such as
/// `OfferingsLocale` extend it.
abstract class LocaleBundle {
  const LocaleBundle({required this.language});

  /// The language these words are in, such as `en` or `fr`. Number and date
  /// formatting follow it too.
  final String language;
}
