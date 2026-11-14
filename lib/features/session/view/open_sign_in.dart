import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/app/keel_routes.dart';
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
  if (AdaptiveStyle.of(context) != AdaptiveStyle.native) {
    await context.push<void>(
      biometric.enabled ? KeelRoutes.biometricSignIn : KeelRoutes.signIn,
    );
    return;
  }
  final session = context.read<SessionBloc>();
  final name = await AdaptiveNativeSheet.show<String>(
    context: context,
    route: 'signIn',
    arguments: biometric.enabled
        ? {
            'biometricName': biometric.name,
            'biometricKind': biometric.kind!.name,
          }
        : null,
    fullScreen: true,
    backgroundColor: KeelColors.raised.of(context),
    // UIKit's own bar: across the top, or in the Duo's vertical bar.
    navigationBar: true,
    barColor: KeelColors.tide.of(context),
    barForeground: CupertinoColors.white,
    plainBarButtons: true,
    // The sheet runs its own engine and router; see the native sheet app.
    builder: (_) => const SizedBox.shrink(),
  );
  if (name != null) session.add(SessionSignedIn(name));
}
