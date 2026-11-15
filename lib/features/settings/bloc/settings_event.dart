part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsLanguageChanged extends SettingsEvent {
  const SettingsLanguageChanged(this.language);

  final AppLanguage language;

  @override
  List<Object?> get props => [language];
}

final class SettingsHapticsToggled extends SettingsEvent {
  const SettingsHapticsToggled({required this.on});

  final bool on;

  @override
  List<Object?> get props => [on];
}
