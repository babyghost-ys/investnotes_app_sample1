/// Keel's localisation.
///
/// Each feature keeps its words in JSON, one file per language:
/// `l10n/offerings/offerings-en.json`, `l10n/offerings/offerings-fr.json`.
/// A file holds a `labels` section and, only where a key needs one, a
/// `semantics` section for what assistive technologies say instead:
///
/// ```json
/// {
///   "labels": { "title": "Offerings" },
///   "semantics": { "filter": "Filters" }
/// }
/// ```
///
/// `dart run keel_localisation:generate` turns every namespace into a typed
/// class (`OfferingsLocale`), writes `Locales` with one constant per
/// namespace, and packs every file into one `tar.bz2` archive the app ships.
///
/// A page names what it needs and reads it by position:
///
/// ```dart
/// class OfferingsPage extends StatelessWidget implements LocalisationConsumer {
///   @override
///   List<String> get namespaces => const [Locales.offerings, Locales.general];
///
///   @override
///   Widget build(BuildContext context) => LocalisedBuilder(
///     consumer: this,
///     builder: (context, locale) {
///       final offerings = locale[0] as OfferingsLocale;
///       return Text(offerings.labels.title);
///     },
///   );
/// }
/// ```
library;

export 'src/language_store.dart';
export 'src/locale_bundle.dart';
export 'src/locale_catalogue.dart';
export 'src/locale_library.dart';
export 'src/locale_registry.dart';
export 'src/locale_text.dart';
export 'src/localisation_bloc.dart';
export 'src/localisation_consumer.dart';
export 'src/localised_builder.dart';
export 'src/system_locale_listener.dart';
