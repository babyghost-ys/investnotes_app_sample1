/// The rules Keel holds a username, email, password and emailed code to.
abstract final class Credentials {
  static final _username = RegExp(r'^[A-Za-z0-9._]{4,}$');
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static final _letter = RegExp('[A-Za-z]');
  static final _digit = RegExp(r'\d');
  static final _code = RegExp(r'^\d{6}$');

  /// Four or more letters, digits, dots or underscores.
  static bool username(String value) => _username.hasMatch(value.trim());

  static bool email(String value) => _email.hasMatch(value.trim());

  static bool longEnough(String password) => password.length >= 8;

  static bool lettersAndDigits(String password) =>
      _letter.hasMatch(password) && _digit.hasMatch(password);

  static bool password(String password) =>
      longEnough(password) && lettersAndDigits(password);

  static bool code(String value) => _code.hasMatch(value);

  /// `marina@keel.com` as `m•••@keel.com`, for showing where a code went.
  static String masked(String email) {
    final at = email.trim().indexOf('@');
    if (at < 1) return email.trim();
    final address = email.trim();
    return '${address[0]}•••${address.substring(at)}';
  }

  /// [masked] as it should be spoken: "m, then hidden, at keel.com".
  static String spokenMasked(String email) {
    final address = email.trim();
    final at = address.indexOf('@');
    if (at < 1) return address;
    return '${address[0]}, then hidden, at ${address.substring(at + 1)}';
  }
}
