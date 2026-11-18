import 'package:material_ui/material_ui.dart';

/// Android's page transition (predictive back, else fade-forwards) with the
/// app's solid bar kept solid while pages move.
///
/// Fade-forwards fades the old page out and the new one in over a plain
/// surface, so for a moment both bars are half transparent and the bar
/// flashes pale. Here the backdrop under the old page carries the bar's
/// [barColor] at the bar's height above the page [background]: the bars'
/// titles and buttons still slide and fade, the band itself never does.
class SolidBarPageTransitionsBuilder extends PageTransitionsBuilder {
  const SolidBarPageTransitionsBuilder({
    required this.barColor,
    required this.background,
  });

  /// The solid bar's colour, painted behind the bar while pages move.
  final Color barColor;

  /// The page background, painted behind the rest of the page.
  final Color background;

  // Transparent, so the backdrop below shows through where it used to paint
  // the plain surface.
  static const _inner = PredictiveBackPageTransitionsBuilder(
    fallbackColor: Color(0x00000000),
  );

  @override
  Duration get transitionDuration => _inner.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _inner.reverseTransitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => _SolidBarBackdrop(
    animation: secondaryAnimation,
    barColor: barColor,
    background: background,
    child: _inner.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    ),
  );
}

/// The page background with the bar's band on top, under a page while
/// another moves over it ([animation] is that page's secondary animation).
class _SolidBarBackdrop extends StatelessWidget {
  const _SolidBarBackdrop({
    required this.animation,
    required this.barColor,
    required this.background,
    required this.child,
  });

  final Animation<double> animation;
  final Color barColor;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final barHeight = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return AnimatedBuilder(
      animation: animation,
      // The child keeps its place in the tree whether or not the backdrop
      // paints, so the page never rebuilds from scratch.
      builder: (context, child) => CustomPaint(
        painter: animation.isAnimating
            ? _BackdropPainter(
                barColor: barColor,
                background: background,
                barHeight: barHeight,
              )
            : null,
        child: child,
      ),
      child: child,
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({
    required this.barColor,
    required this.background,
    required this.barHeight,
  });

  final Color barColor;
  final Color background;
  final double barHeight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, barHeight),
      Paint()..color = barColor,
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.barColor != barColor ||
      old.background != background ||
      old.barHeight != barHeight;
}
