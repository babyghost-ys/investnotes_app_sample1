import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// The settings page's own choices: haptic feedback, held on the page and
/// acted on nowhere yet. The language belongs to the app's
/// `LocalisationBloc`, which the page changes directly.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsHapticsToggled>(
      (event, emit) => emit(state.copyWith(haptics: event.on)),
    );
  }
}
