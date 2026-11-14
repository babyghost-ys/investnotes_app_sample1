import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show MaterialPage;

import 'package:investnotes_app_sample1/app/keel_page.dart';
import 'package:investnotes_app_sample1/features/account/view/find_username_page.dart';
import 'package:investnotes_app_sample1/features/account/view/register_page.dart';
import 'package:investnotes_app_sample1/features/account/view/reset_password_page.dart';
import 'package:investnotes_app_sample1/features/session/view/biometric_sign_in_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';
import 'package:investnotes_app_sample1/features/session/widgets/sheet_bar_binder.dart';

/// A page of the sign-in flow.
///
/// In the iOS [sheet] each page is an [AdaptiveScaffold] in a native page
/// of the sheet's navigation: UIKit pushes and pops whole pages, bar and
/// all, with its own back and swipe ([SheetBarBinder]). Elsewhere the
/// [first] page rises as a full-screen dialog and the rest push over it.
///
/// The [first] page carries the close control, an xmark or [closeTitle] in
/// words; pages pushed over it have back.
Page<void> _page(
  GoRouterState state, {
  required bool sheet,
  required String? title,
  required Widget child,
  bool first = false,
  String? closeTitle,
}) {
  if (sheet) {
    // UIKit moves the whole page; Flutter switches without a transition.
    return NoTransitionPage<void>(
      key: state.pageKey,
      child: Builder(
        builder: (context) => AdaptiveScaffold(
          body: SheetBarBinder(
            first: first,
            title: title,
            onClose: first ? SignInScope.of(context).onClose : null,
            closeTitle: closeTitle,
            child: child,
          ),
        ),
      ),
    );
  }
  if (first) {
    return MaterialPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      child: Builder(
        builder: (context) => AdaptiveScaffold(
          extendBody: true,
          appBar: AdaptiveAppBar(
            title: title,
            // A worded close replaces the dialog's own xmark.
            leading: closeTitle == null ? null : const SizedBox.shrink(),
            actions: closeTitle == null
                ? null
                : [
                    AdaptiveAppBarAction(
                      title: closeTitle,
                      onPressed: SignInScope.of(context).onClose,
                    ),
                  ],
          ),
          body: child,
        ),
      ),
    );
  }
  return keelPage(state, title: title ?? '', child: child);
}

/// Sign-in and the pages it leads to, at [path].
///
/// It is the flow's first page, unless pushed from the biometric welcome
/// ([SignInScope.fromBiometric]); then it is one more page on the same
/// stack, and Register and the forgotten username and password push over it
/// as they always do.
GoRoute signInRoute({required String path, required bool sheet}) => GoRoute(
  path: path,
  pageBuilder: (context, state) => _page(
    state,
    sheet: sheet,
    title: 'Sign in',
    first: state.extra != SignInScope.fromBiometric,
    child: const SignInPage(),
  ),
  routes: [
    GoRoute(
      path: 'register',
      pageBuilder: (context, state) => _page(
        state,
        sheet: sheet,
        title: 'Register',
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: 'reset-password',
      pageBuilder: (context, state) => _page(
        state,
        sheet: sheet,
        title: 'Reset password',
        child: ResetPasswordPage(
          username: state.uri.queryParameters['username'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: 'find-username',
      pageBuilder: (context, state) => _page(
        state,
        sheet: sheet,
        title: 'Find username',
        child: const FindUsernamePage(),
      ),
    ),
  ],
);

/// The welcome back for an account that signs in with Face ID or Touch ID,
/// at [path]: always the flow's first page, leaving by Home.
GoRoute biometricSignInRoute({required String path, required bool sheet}) =>
    GoRoute(
      path: path,
      pageBuilder: (context, state) => _page(
        state,
        sheet: sheet,
        title: null,
        first: true,
        closeTitle: 'Home',
        child: const BiometricSignInPage(),
      ),
    );
