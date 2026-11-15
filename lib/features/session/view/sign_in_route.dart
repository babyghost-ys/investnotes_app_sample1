import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';
import 'package:material_ui/material_ui.dart' show MaterialPage;

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/features/account/view/find_username_page.dart';
import 'package:investnotes_app_sample1/features/account/view/register_page.dart';
import 'package:investnotes_app_sample1/features/account/view/reset_password_page.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_bar_host.dart';
import 'package:investnotes_app_sample1/features/session/view/biometric_sign_in_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';
import 'package:investnotes_app_sample1/features/session/widgets/sheet_bar_binder.dart';

/// Namespaces the flow's bars read their words from.
const _barNamespaces = [Locales.session, Locales.account];

/// A bar's words, from the session's and the account's namespaces.
typedef FlowWords = String Function(
  SessionLocale session,
  AccountLocale account,
);

/// A page of the sign-in flow.
///
/// In the iOS [sheet] each page is an [NativeScaffold] in a native page
/// of the sheet's navigation: UIKit pushes and pops whole pages, bar and
/// all, with its own back and swipe ([SheetBarBinder]). Elsewhere the
/// [first] page rises as a full-screen dialog and the rest push over it.
///
/// The [first] page carries the close control, an xmark or [closeTitle] in
/// words; pages pushed over it have back.
///
/// [title] and [closeTitle] are read in the language in use, so an open
/// flow turns with the rest of the app.
Page<void> _page(
  GoRouterState state, {
  required bool sheet,
  required FlowWords? title,
  required Widget child,
  bool first = false,
  FlowWords? closeTitle,
}) {
  Widget worded(Widget Function(String? title, String? closeTitle) build) =>
      LocalisedBuilder.namespaces(
        namespaces: _barNamespaces,
        builder: (context, locale) {
          final session = locale[0] as SessionLocale;
          final account = locale[1] as AccountLocale;
          return build(
            title?.call(session, account),
            closeTitle?.call(session, account),
          );
        },
      );

  if (sheet) {
    // UIKit moves the whole page; Flutter switches without a transition.
    return NoTransitionPage<void>(
      key: state.pageKey,
      child: FlowBarHost(
        builder: (context, action) => worded(
          (title, closeTitle) => NativeScaffold(
            body: SheetBarBinder(
              first: first,
              title: title,
              onClose: first ? SignInScope.of(context).onClose : null,
              closeTitle: closeTitle,
              action: action,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
  if (first) {
    return MaterialPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      child: worded(
        (title, closeTitle) => Builder(
          builder: (context) => NativeScaffold(
            extendBody: true,
            appBar: NativeAppBar(
              title: title,
              // A worded close replaces the dialog's own xmark.
              leading: closeTitle == null ? null : const SizedBox.shrink(),
              actions: closeTitle == null
                  ? null
                  : [
                      NativeAppBarAction(
                        title: closeTitle,
                        onPressed: SignInScope.of(context).onClose,
                      ),
                    ],
            ),
            body: child,
          ),
        ),
      ),
    );
  }
  return flowPage(state, title: title, child: child);
}

/// A flow page pushed in the app's own navigation, the bar carrying the
/// page's own control when it sets one.
NativePage<void> flowPage(
  GoRouterState state, {
  required FlowWords? title,
  required Widget child,
}) => NativePage<void>(
  key: state.pageKey,
  name: state.matchedLocation,
  child: FlowBarHost(
    builder: (context, action) => ValueListenableBuilder(
      valueListenable: action,
      builder: (context, bar, body) => LocalisedBuilder.namespaces(
        namespaces: _barNamespaces,
        builder: (context, locale) => NativeScaffold(
          extendBody: true,
          appBar: NativeAppBar(
            title:
                title?.call(
                  locale[0] as SessionLocale,
                  locale[1] as AccountLocale,
                ) ??
                '',
            actions: [
              if (bar != null)
                NativeAppBarAction(
                  icon: NativeIcon(
                    sfSymbol: bar.sfSymbol,
                    icon: CupertinoIcons.backward,
                  ),
                  label: bar.label,
                  onPressed: bar.onPressed,
                ),
            ],
          ),
          body: body!,
        ),
      ),
      child: child,
    ),
  ),
);

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
    title: (session, _) => session.labels.signIn,
    first: state.extra != SignInScope.fromBiometric,
    child: const SignInPage(),
  ),
  routes: [
    GoRoute(
      path: 'register',
      pageBuilder: (context, state) => _page(
        state,
        sheet: sheet,
        title: (_, account) => account.labels.register,
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: 'reset-password',
      pageBuilder: (context, state) => _page(
        state,
        sheet: sheet,
        title: (_, account) => account.labels.resetPassword,
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
        title: (_, account) => account.labels.findUsername,
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
        closeTitle: (session, _) => session.labels.home,
        child: const BiometricSignInPage(),
      ),
    );

/// Register on its own, pushed from Home at [path]. Finishing pops back
/// with the new account's name, the same way Back leaves, so the native
/// page goes as it came; whoever pushed it signs the account in.
GoRoute registerRoute({required String path}) => GoRoute(
  path: path,
  pageBuilder: (context, state) => flowPage(
    state,
    title: (_, account) => account.labels.register,
    child: Builder(
      builder: (context) => SignInScope(
        base: path,
        onSignedIn: (name) => context.pop(name),
        onClose: () => context.pop(),
        child: const RegisterPage(),
      ),
    ),
  ),
);
