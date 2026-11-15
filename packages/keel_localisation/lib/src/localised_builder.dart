import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keel_localisation/src/locale_bundle.dart';
import 'package:keel_localisation/src/locale_catalogue.dart';
import 'package:keel_localisation/src/localisation_bloc.dart';
import 'package:keel_localisation/src/localisation_consumer.dart';

/// Builds with the bundles a [LocalisationConsumer] names, in its order,
/// and builds again in the new language when the language changes.
class LocalisedBuilder extends StatelessWidget {
  const LocalisedBuilder({
    super.key,
    required LocalisationConsumer consumer,
    required this.builder,
  }) : _consumer = consumer,
       _namespaces = null;

  /// For code that is not a widget of its own, such as a route's title.
  const LocalisedBuilder.namespaces({
    super.key,
    required List<String> namespaces,
    required this.builder,
  }) : _namespaces = namespaces,
       _consumer = null;

  final LocalisationConsumer? _consumer;
  final List<String>? _namespaces;
  final Widget Function(BuildContext context, List<LocaleBundle> locale)
  builder;

  @override
  Widget build(BuildContext context) {
    final catalogue = context.select<LocalisationBloc, LocaleCatalogue>(
      (bloc) => bloc.state.catalogue,
    );
    return builder(
      context,
      catalogue.all(_namespaces ?? _consumer!.namespaces),
    );
  }
}
