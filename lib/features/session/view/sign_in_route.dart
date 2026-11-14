import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show MaterialPage;

import 'package:investnotes_app_sample1/app/keel_page.dart';
import 'package:investnotes_app_sample1/features/account/view/find_username_page.dart';
import 'package:investnotes_app_sample1/features/account/view/register_page.dart';
import 'package:investnotes_app_sample1/features/account/view/reset_password_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';
import 'package:investnotes_app_sample1/features/session/widgets/sheet_bar_binder.dart';

/// Sign-in and the pages it leads to, at [path].
///
/// In the iOS [sheet] each page is an [AdaptiveScaffold] under the sheet's
/// native navigation bar, which shows the page's title, back and close
/// ([SheetBarBinder]); the pages push with Flutter's own transition and
/// swipe-back inside the sheet's engine. Elsewhere sign-in rises as a full-screen
/// dialog and the rest push over it.
GoRoute signInRoute({required String path, required bool sheet}) {
  Page<void> page(
    GoRouterState state, {
    required String title,
    required Widget child,
    bool first = false,
  }) {
    if (sheet) {
      return CupertinoPage<void>(
        key: state.pageKey,
        child: Builder(
          builder: (context) => AdaptiveScaffold(
            body: SheetBarBinder(
              // Sign-in's brand band says what it is; its bar stays bare.
              title: first ? null : title,
              onBack: first ? null : () => Navigator.maybePop(context),
              onClose: first ? SignInScope.of(context).onClose : null,
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
        child: AdaptiveScaffold(
          extendBody: true,
          appBar: AdaptiveAppBar(title: title),
          body: child,
        ),
      );
    }
    return keelPage(state, title: title, child: child);
  }

  return GoRoute(
    path: path,
    pageBuilder: (context, state) =>
        page(state, title: 'Sign in', first: true, child: const SignInPage()),
    routes: [
      GoRoute(
        path: 'register',
        pageBuilder: (context, state) =>
            page(state, title: 'Register', child: const RegisterPage()),
      ),
      GoRoute(
        path: 'reset-password',
        pageBuilder: (context, state) => page(
          state,
          title: 'Reset password',
          child: ResetPasswordPage(
            username: state.uri.queryParameters['username'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: 'find-username',
        pageBuilder: (context, state) => page(
          state,
          title: 'Find username',
          child: const FindUsernamePage(),
        ),
      ),
    ],
  );
}
