part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    this.language = AppLanguage.system,
    this.haptics = false,
  });

  final AppLanguage language;
  final bool haptics;

  SettingsState copyWith({AppLanguage? language, bool? haptics}) =>
      SettingsState(
        language: language ?? this.language,
        haptics: haptics ?? this.haptics,
      );

  @override
  List<Object?> get props => [language, haptics];
}
