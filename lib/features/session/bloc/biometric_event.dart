part of 'biometric_bloc.dart';

sealed class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => [];
}

final class BiometricStarted extends BiometricEvent {
  const BiometricStarted();
}

/// Biometric sign-in switched [on] for the account [name]. [reason] is
/// what the system's prompt says, in the app's language.
final class BiometricToggled extends BiometricEvent {
  const BiometricToggled({
    required this.on,
    required this.name,
    required this.reason,
  });

  final bool on;
  final String name;
  final String reason;

  @override
  List<Object?> get props => [on, name, reason];
}

final class BiometricAccountSignedIn extends BiometricEvent {
  const BiometricAccountSignedIn(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}
