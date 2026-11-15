import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// The strip shown below the status bar while the device has no network.
/// It runs in the overlay's own engine on iOS, so it reads nothing from the
/// app's theme: its colours are fixed and hold in light and dark mode.
class NetworkLostBar extends StatelessWidget {
  const NetworkLostBar({super.key});

  static const Color background = KeelColors.charcoal;

  static const Color _foreground = Color(0xFFF2F4F7);

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'No connection',
    child: const ExcludeSemantics(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.wifi_slash, size: 17, color: _foreground),
            SizedBox(width: 8),
            Text(
              'No connection',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
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
