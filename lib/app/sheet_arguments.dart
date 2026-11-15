import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';

/// What a native sheet is opened with. On iOS a sheet runs in an engine of
/// its own, which cannot read the app's blocs, so the words of the language
/// the app speaks travel with the sheet's own value: the sheet starts at
/// once, without reading or unpacking the archive.
abstract final class SheetArguments {
  /// [value] with the app's words in the language it speaks under
  /// [context].
  static Map<String, Object?> wrap(BuildContext context, Object? value) {
    final localisation = context.read<LocalisationBloc>();
    return {
      'words': localisation.library.export(localisation.state.language),
      'value': value,
    };
  }

  /// The words [wrap] sent, ready for the sheet's own `LocalisationBloc`.
  static LocalisationBloc localisation(Object? arguments) {
    final library = LocaleLibrary.words(
      localeRegistry,
      (arguments as Map)['words'] as Object,
    );
    return LocalisationBloc.fixed(library: library, language: library.fallback);
  }

  static Object? value(Object? arguments) => (arguments as Map?)?['value'];
}
