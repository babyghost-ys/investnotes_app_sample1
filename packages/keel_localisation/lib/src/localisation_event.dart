part of 'localisation_bloc.dart';

sealed class LocalisationEvent extends Equatable {
  const LocalisationEvent();

  @override
  List<Object?> get props => [];
}

/// The person picked a language; null follows the device.
final class LocalisationChoiceChanged extends LocalisationEvent {
  const LocalisationChoiceChanged(this.choice);

  final String? choice;

  @override
  List<Object?> get props => [choice];
}

/// The device's languages changed while the app follows them.
final class LocalisationSystemLocalesChanged extends LocalisationEvent {
  const LocalisationSystemLocalesChanged(this.locales);

  final List<Locale> locales;

  @override
  List<Object?> get props => [locales];
}
