import 'package:cupertino_ui/cupertino_ui.dart';

/// Where the sign-in flow lives and what finishing it means there.
///
/// On iOS the flow runs in its own native sheet, with its own router rooted
/// at `/`; finishing hands the name back to the page and closes the sheet.
/// Elsewhere it is part of the app's router under `/sign-in`; finishing
/// signs in and returns home.
class SignInScope extends InheritedWidget {
  const SignInScope({
    super.key,
    required this.base,
    required this.onSignedIn,
    required this.onClose,
    required super.child,
  });

  /// The location of the sign-in page in the router that holds it.
  final String base;

  /// The flow ends with [name] signed in.
  final ValueChanged<String> onSignedIn;

  /// The flow ends without signing in.
  final VoidCallback onClose;

  String get register => _at('register');
  String get findUsername => _at('find-username');

  /// [username] is what was already typed on sign-in.
  String resetPassword(String username) => Uri(
    path: _at('reset-password'),
    queryParameters: username.isEmpty ? null : {'username': username},
  ).toString();

  String _at(String page) => base == '/' ? '/$page' : '$base/$page';

  static SignInScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SignInScope>()!;

  @override
  bool updateShouldNotify(SignInScope old) => base != old.base;
}
