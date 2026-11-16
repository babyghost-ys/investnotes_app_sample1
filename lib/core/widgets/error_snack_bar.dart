import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Theme;

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A charcoal pill just above the tab bar that says something went wrong,
/// clear of the side bar where the system keeps one (an unfolded iPhone
/// Duo), since UIKit draws that bar above anything the app draws,
/// then slides away on its own after [duration]. Tapping it, or swiping it
/// down, puts it away sooner. One shows at a time.
abstract final class ErrorSnackBar {
  static OverlayEntry? _entry;
  static GlobalKey<_SnackState>? _key;

  static void show(
    BuildContext context,
    String message, {
    IconData icon = CupertinoIcons.exclamationmark_circle,
    Duration duration = const Duration(seconds: 4),
  }) {
    _entry?.remove();
    // Above the tab bar and home indicator, and beside a vertical bar, as
    // the page itself sees them.
    final insets = MediaQuery.paddingOf(context);
    final key = GlobalKey<_SnackState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Snack(
        key: key,
        insets: insets,
        icon: icon,
        message: message,
        duration: duration,
        onGone: () {
          if (_entry != entry) return;
          entry.remove();
          _entry = null;
        },
      ),
    );
    _entry = entry;
    _key = key;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  /// Slides the pill away early, as when what it reported is fixed.
  static void hide() => _key?.currentState?.dismiss();
}

class _Snack extends StatefulWidget {
  const _Snack({
    super.key,
    required this.insets,
    required this.icon,
    required this.message,
    required this.duration,
    required this.onGone,
  });

  final EdgeInsets insets;
  final IconData icon;
  final String message;
  final Duration duration;
  final VoidCallback onGone;

  @override
  State<_Snack> createState() => _SnackState();
}

class _SnackState extends State<_Snack> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    reverseDuration: const Duration(milliseconds: 220),
  )..forward();
  late final Animation<double> _curve = CurvedAnimation(
    parent: _motion,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, dismiss);
  }

  Future<void> dismiss() async {
    _timer?.cancel();
    if (!mounted || _motion.status == AnimationStatus.reverse) return;
    await _motion.reverse();
    widget.onGone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const foreground = Color(0xFFF2F4F7);
    return Positioned(
      left: widget.insets.left + 16,
      right: widget.insets.right + 16,
      bottom: widget.insets.bottom + 12,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _curve.value) * 24),
            child: child,
          ),
        ),
        child: GestureDetector(
          onTap: dismiss,
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 0) dismiss();
          },
          child: Semantics(
            liveRegion: true,
            label: widget.message,
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: const ShapeDecoration(
                  color: KeelColors.charcoal,
                  shape: StadiumBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, size: 20, color: foreground),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          // Laid in the root overlay, outside any page's
                          // text style: start from the app's body text.
                          style: Theme.of(context).textTheme.bodyMedium!.merge(
                            const TextStyle(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
