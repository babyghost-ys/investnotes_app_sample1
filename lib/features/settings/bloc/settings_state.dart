part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  const SettingsState({this.haptics = false});

  final bool haptics;

  SettingsState copyWith({bool? haptics}) =>
      SettingsState(haptics: haptics ?? this.haptics);

  @override
  List<Object?> get props => [haptics];
}
