import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/features/connectivity/widgets/network_lost_bar.dart';

/// Routes of the strip below the status bar (see [NativeOverlayContainer]).
abstract final class CommonOverlay {
  static const networkLost = 'networkLost';

  /// The words, loaded by whichever engine draws the strip: the app's own
  /// in `main`, the overlay's in `commonOverlayMain`.
  static LocaleLibrary? library;

  /// Builds a route's content, in the overlay's own engine on iOS and in
  /// the app's isolate elsewhere. It speaks the language the app spoke
  /// when it was shown, sent in [arguments].
  static Widget build(BuildContext context, String route, Object? arguments) {
    final language = (arguments as Map?)?['language'] as String? ?? 'en';
    return BlocProvider(
      create: (_) =>
          LocalisationBloc.fixed(library: library!, language: language),
      child: switch (route) {
        networkLost => const NetworkLostBar(),
        _ => throw ArgumentError.value(route, 'route', 'Unknown overlay'),
      },
    );
  }

  static Future<void> showNetworkLost(String language) =>
      NativeOverlayContainer.show(
        networkLost,
        arguments: {'language': language},
        color: NetworkLostBar.background,
        // Says it once and gets out of the way; it comes back on the next
        // loss.
        duration: const Duration(seconds: 3),
      );
}
