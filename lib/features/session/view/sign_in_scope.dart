import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/data/models/biometric_kind.dart';

/// The account that signs in with Face ID or Touch ID, and which.
typedef BiometricAccount = ({String name, BiometricKind kind});

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
    this.sheet = false,
    this.biometric,
  });

  /// Sent with sign-in when it is pushed from the biometric welcome.
  static const fromBiometric = 'fromBiometric';

  /// Set when the flow opens on the biometric welcome.
  final BiometricAccount? biometric;

  /// In the iOS sheet, where pages push as whole native pages.
  final bool sheet;

  /// The location of the sign-in page in the router that holds it.
  final String base;

  /// The flow ends with [name] signed in.
  final ValueChanged<String> onSignedIn;

  /// The flow ends without signing in.
  final VoidCallback onClose;

  String get register => _at('register');

  /// Sign-in with username and password, pushed from the biometric welcome
  /// as one more page; its own links push over it as always.
  Future<void> pushPasswordSignIn(BuildContext context) =>
      push<void>(context, base, extra: fromBiometric);
  String get findUsername => _at('find-username');

  /// [username] is what was already typed on sign-in.
  String resetPassword(String username) => Uri(
    path: _at('reset-password'),
    queryParameters: username.isEmpty ? null : {'username': username},
  ).toString();

  /// Opens [location]. In the sheet the page in front is pictured first, so
  /// UIKit can push the new page whole once Flutter has drawn it.
  Future<T?> push<T>(
    BuildContext context,
    String location, {
    Object? extra,
  }) async {
    if (sheet) await NativeSheet.preparePush();
    if (!context.mounted) return null;
    return context.push<T>(location, extra: extra);
  }

  /// Leaves the page in front with [result]. In the sheet UIKit pops it
  /// first, and the Flutter route follows.
  Future<void> pop<T>(BuildContext context, [T? result]) async {
    if (sheet) await NativeSheet.popPage();
    if (context.mounted) context.pop(result);
  }

  String _at(String page) => base == '/' ? '/$page' : '$base/$page';

  static SignInScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SignInScope>()!;

  @override
  bool updateShouldNotify(SignInScope old) =>
      base != old.base || biometric != old.biometric;
}
