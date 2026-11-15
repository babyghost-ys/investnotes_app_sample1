import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/features/connectivity/widgets/network_lost_bar.dart';

/// Routes of the strip below the status bar (see [NativeOverlayContainer]).
///
/// On iOS the strip is drawn natively from its symbol and text, so it runs
/// no engine of its own; elsewhere [build] draws it in the app's isolate.
abstract final class CommonOverlay {
  static const networkLost = 'networkLost';

  /// Builds a route's content where the strip is not native (not iOS). Its
  /// words come in [arguments], already in the app's language.
  static Widget build(BuildContext context, String route, Object? arguments) =>
      switch (route) {
        networkLost => NetworkLostBar(
          text: (arguments! as Map)['text']! as String,
        ),
        _ => throw ArgumentError.value(route, 'route', 'Unknown overlay'),
      };

  /// Shown in the language [localisation] speaks.
  static Future<void> showNetworkLost(LocalisationBloc localisation) {
    final words =
        localisation.state.catalogue[Locales.connectivity]
            as ConnectivityLocale;
    final text = words.labels.noConnection;
    return NativeOverlayContainer.show(
      networkLost,
      color: NetworkLostBar.background,
      arguments: {'text': text},
      content: NativeOverlayContent(
        sfSymbol: 'wifi.slash',
        text: text,
        foreground: NetworkLostBar.foreground,
      ),
      // Says it once and gets out of the way; it comes back on the next
      // loss.
      duration: const Duration(seconds: 3),
    );
  }
}
