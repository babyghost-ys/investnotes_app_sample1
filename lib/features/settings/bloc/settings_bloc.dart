import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/app_language.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// The settings page's choices: the language and haptic feedback. Held on
/// the page only; nothing acts on them yet.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsLanguageChanged>(
      (event, emit) => emit(state.copyWith(language: event.language)),
    );
    on<SettingsHapticsToggled>(
      (event, emit) => emit(state.copyWith(haptics: event.on)),
    );
  }
}
