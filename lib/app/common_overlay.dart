import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter/widgets.dart';

import 'package:investnotes_app_sample1/features/connectivity/widgets/network_lost_bar.dart';

/// Routes of the strip below the status bar (see [NativeOverlayContainer]).
abstract final class CommonOverlay {
  static const networkLost = 'networkLost';

  /// Builds a route's content, in the overlay's own engine on iOS and in
  /// the app's isolate elsewhere.
  static Widget build(BuildContext context, String route, Object? arguments) =>
      switch (route) {
        networkLost => const NetworkLostBar(),
        _ => throw ArgumentError.value(route, 'route', 'Unknown overlay'),
      };

  static Future<void> showNetworkLost() => NativeOverlayContainer.show(
    networkLost,
    color: NetworkLostBar.background,
    // Says it once and gets out of the way; it comes back on the next loss.
    duration: const Duration(seconds: 3),
  );
}
