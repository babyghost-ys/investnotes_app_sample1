import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:investnotes_app_sample1/data/models/biometric_kind.dart';

/// The device's biometric check, and who on this device signs in with it.
///
/// Only the account name is kept: this sample has no server, so a passing
/// check is what signs that account back in.
class BiometricRepository {
  BiometricRepository();

  static const _nameKey = 'biometric.name';

  final _auth = LocalAuthentication();

  /// What this device checks, or null when it has no biometric enrolled.
  Future<BiometricKind?> kind() async {
    try {
      if (!await _auth.canCheckBiometrics) return null;
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return BiometricKind.face;
      if (types.isEmpty) return null;
      return BiometricKind.fingerprint;
    } on Exception {
      return null;
    }
  }

  /// Asks for the biometric; true when it matched.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on LocalAuthException {
      return false;
    }
  }

  /// The account that signs in with the biometric, if any.
  Future<String?> enrolledName() async =>
      (await SharedPreferences.getInstance()).getString(_nameKey);

  Future<void> enrol(String name) async =>
      (await SharedPreferences.getInstance()).setString(_nameKey, name);

  Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove(_nameKey);
}
