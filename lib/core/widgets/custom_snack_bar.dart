import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A charcoal pill just above the tab bar that says something went wrong,
/// then slides away on its own after [duration]. Tapping it, or swiping it
/// down, puts it away sooner. One shows at a time.
///
/// A floating view of the [NativeOverlayContainer], so it lies over every
/// bar on screen, the iPhone Duo's vertical bar included, which UIKit draws
/// above the page itself.
abstract final class CustomSnackBar {
  static const _id = 'custom_snack_bar';
  static const _foreground = Color(0xFFF2F4F7);

  static void show(
    BuildContext context,
    String message, {
    String sfSymbol = 'exclamationmark.circle',
    IconData icon = CupertinoIcons.exclamationmark_circle,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Above the tab bar and home indicator, as the page itself sees them.
    final bottom = MediaQuery.paddingOf(context).bottom;
    NativeOverlayContainer.float(
      _id,
      NativeOverlayFloat(
        content: NativeOverlayContent(
          sfSymbol: sfSymbol,
          icon: icon,
          text: message,
          foreground: _foreground,
          fontSize: 16,
          symbolSize: 20,
          fontWeight: FontWeight.w500,
        ),
        color: KeelColors.charcoal,
        offset: bottom + 12,
      ),
      duration: duration,
    );
  }

  /// Slides the pill away early, as when what it reported is fixed.
  static void hide() => NativeOverlayContainer.unfloat(_id);
}
