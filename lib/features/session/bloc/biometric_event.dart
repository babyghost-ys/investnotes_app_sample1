part of 'biometric_bloc.dart';

sealed class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => [];
}

final class BiometricStarted extends BiometricEvent {
  const BiometricStarted();
}

/// Biometric sign-in switched [on] for the account [name].
final class BiometricToggled extends BiometricEvent {
  const BiometricToggled({required this.on, required this.name});

  final bool on;
  final String name;

  @override
  List<Object?> get props => [on, name];
}

final class BiometricAccountSignedIn extends BiometricEvent {
  const BiometricAccountSignedIn(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}
