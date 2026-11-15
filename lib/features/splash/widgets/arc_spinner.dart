import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';

/// A thin arc turning on its own, a quarter of a circle and a little more.
class ArcSpinner extends StatefulWidget implements LocalisationConsumer {
  @override
  List<String> get namespaces => const [Locales.general];

  const ArcSpinner({super.key, required this.color, this.size = 30});

  final Color color;
  final double size;

  @override
  State<ArcSpinner> createState() => _ArcSpinnerState();
}

class _ArcSpinnerState extends State<ArcSpinner>
    with SingleTickerProviderStateMixin {
  late final _turn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: widget,
    builder: (context, locale) => _build(context, locale[0] as GeneralLocale),
  );

  Widget _build(BuildContext context, GeneralLocale general) => Semantics(
    label: general.semantics.loading,
    child: RotationTransition(
      turns: _turn,
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(painter: _ArcPainter(widget.color)),
      ),
    ),
  );
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width / 12;
    canvas.drawArc(
      Offset.zero & size,
      -math.pi / 2,
      math.pi * 0.6,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
