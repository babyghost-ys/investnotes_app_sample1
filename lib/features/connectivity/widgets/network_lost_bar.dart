import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// The strip shown below the status bar while the device has no network.
/// It runs in the overlay's own engine on iOS, so it reads nothing from the
/// app's theme: its colours are fixed and hold in light and dark mode.
class NetworkLostBar extends StatelessWidget implements LocalisationConsumer {
  const NetworkLostBar({super.key});

  static const Color background = KeelColors.charcoal;

  static const Color _foreground = Color(0xFFF2F4F7);

  @override
  List<String> get namespaces => const [Locales.connectivity];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as ConnectivityLocale),
  );

  Widget _build(BuildContext context, ConnectivityLocale connectivity) =>
      Semantics(
        liveRegion: true,
        label: connectivity.labels.noConnection,
        child: ExcludeSemantics(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.wifi_slash,
                  size: 17,
                  color: _foreground,
                ),
                const SizedBox(width: 8),
                Text(
                  connectivity.labels.noConnection,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    color: _foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
