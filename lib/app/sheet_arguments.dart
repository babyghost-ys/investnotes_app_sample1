import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

/// What a native sheet is opened with. On iOS a sheet runs in an engine of
/// its own, which cannot read the app's blocs, so the language the app
/// speaks travels with the sheet's own value.
abstract final class SheetArguments {
  /// [value] with the language the app speaks under [context].
  static Map<String, Object?> wrap(BuildContext context, Object? value) => {
    'language': context.read<LocalisationBloc>().state.language,
    'value': value,
  };

  static String language(Object? arguments) =>
      (arguments as Map?)?['language'] as String? ?? 'en';

  static Object? value(Object? arguments) => (arguments as Map?)?['value'];
}
