part of 'localisation_bloc.dart';

final class LocalisationState extends Equatable {
  const LocalisationState({required this.choice, required this.catalogue});

  /// What the person picked; null follows the device.
  final String? choice;

  /// Every namespace in the language in use.
  final LocaleCatalogue catalogue;

  /// The language in use, such as `en` or `fr`.
  String get language => catalogue.language;

  @override
  List<Object?> get props => [choice, catalogue];
}
