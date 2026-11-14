part of 'biometric_bloc.dart';

final class BiometricState extends Equatable {
  const BiometricState({this.kind, this.name, this.checking = false});

  /// What the device checks; null when it has none.
  final BiometricKind? kind;

  /// The account that signs in with it; null when it is off.
  final String? name;

  /// The check that turns it on is showing.
  final bool checking;

  bool get enabled => kind != null && name != null;

  @override
  List<Object?> get props => [kind, name, checking];
}
