import 'dart:ui' show Locale;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:keel_localisation/src/language_store.dart';
import 'package:keel_localisation/src/locale_catalogue.dart';
import 'package:keel_localisation/src/locale_library.dart';

part 'localisation_event.dart';
part 'localisation_state.dart';

/// The language the app speaks, and every namespace's words in it.
///
/// [LocalisationState.choice] is what the person picked; null follows the
/// device. With a [store] the choice is kept across launches.
class LocalisationBloc extends Bloc<LocalisationEvent, LocalisationState> {
  LocalisationBloc({
    required this.library,
    this.store,
    String? choice,
    Iterable<Locale> system = const [],
  }) : _system = List.of(system),
       super(
         LocalisationState(
           choice: choice,
           catalogue: library.catalogue(_resolve(library, choice, system)),
         ),
       ) {
    on<LocalisationChoiceChanged>((event, emit) async {
      emit(_state(event.choice));
      await store?.write(event.choice);
    });
    on<LocalisationSystemLocalesChanged>((event, emit) {
      _system = List.of(event.locales);
      emit(_state(state.choice));
    });
  }

  /// Fixed to [language], for a native sheet's or overlay's own engine:
  /// it speaks whatever the app spoke when it opened.
  LocalisationBloc.fixed({
    required LocaleLibrary library,
    required String language,
  }) : this(library: library, choice: language);

  final LocaleLibrary library;
  final LanguageStore? store;
  List<Locale> _system;

  LocalisationState _state(String? choice) => LocalisationState(
    choice: choice,
    catalogue: library.catalogue(_resolve(library, choice, _system)),
  );

  static String _resolve(
    LocaleLibrary library,
    String? choice,
    Iterable<Locale> system,
  ) => choice != null && library.files.containsKey(choice)
      ? choice
      : library.resolve(system);
}
