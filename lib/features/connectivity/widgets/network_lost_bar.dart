import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// The strip shown below the status bar while the device has no network,
/// where it is drawn in Flutter (not iOS, which draws the same symbol and
/// text natively). Its colours are fixed and hold in light and dark mode.
class NetworkLostBar extends StatelessWidget {
  const NetworkLostBar({super.key, required this.text});

  static const Color background = KeelColors.charcoal;

  static const Color foreground = Color(0xFFF2F4F7);

  /// "No connection", in the app's language.
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: text,
    child: ExcludeSemantics(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.wifi_slash, size: 17, color: foreground),
            const SizedBox(width: 8),
            Text(
              text,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                color: foreground,
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
