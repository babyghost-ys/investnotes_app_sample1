/// The biometric a device signs in with.
enum BiometricKind {
  face('Face ID'),
  fingerprint('Touch ID');

  const BiometricKind(this.title);

  /// What iOS calls it; it names the switch and the sign-in control.
  final String title;
}
