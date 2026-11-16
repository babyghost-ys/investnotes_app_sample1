import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/app/sheet_arguments.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/features/session/bloc/biometric_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';

/// Opens sign-in: on iOS a native sheet that rises over the whole screen,
/// elsewhere a full-screen dialog page.
///
/// An account that signs in with Face ID or Touch ID is welcomed back
/// first; otherwise sign-in opens on username and password.
Future<void> openSignIn(BuildContext context) async {
  final biometric = context.read<BiometricBloc>().state;
  if (NativeStyle.of(context) != NativeStyle.native) {
    await context.push<void>(
      biometric.enabled ? KeelRoutes.biometricSignIn : KeelRoutes.signIn,
    );
    return;
  }
  final session = context.read<SessionBloc>();
  // The first page's bar, as the sheet's own route sets it (sign_in_route).
  final words =
      context
              .read<LocalisationBloc>()
              .state
              .catalogue
              .all(const [Locales.session])
              .first
          as SessionLocale;
  final name = await NativeSheet.show<String>(
    context: context,
    route: 'signIn',
    arguments: SheetArguments.wrap(
      context,
      biometric.enabled
          ? {
              'biometricName': biometric.name,
              'biometricKind': biometric.kind!.name,
            }
          : null,
    ),
    fullScreen: true,
    backgroundColor: KeelColors.raised.of(context),
    // UIKit's own bar: across the top, or in the Duo's vertical bar.
    navigationBar: true,
    barColor: KeelColors.tide.of(context),
    barForeground: CupertinoColors.white,
    // The same faint shadow under the bar as on the app's own pages.
    barShadow: NativeTheme.of(context).barStyle.shadow,
    plainBarButtons: true,
    barTitleStyle: NativeTheme.of(context).barStyle.titleStyle,
    barTitle: biometric.enabled ? null : words.labels.signIn,
    barClose: true,
    barCloseTitle: biometric.enabled ? words.labels.home : null,
    // The sheet runs its own engine and router; see the native sheet app.
    builder: (_) => const SizedBox.shrink(),
  );
  if (name != null) session.add(SessionSignedIn(name));
}
