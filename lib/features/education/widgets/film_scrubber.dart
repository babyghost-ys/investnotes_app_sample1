import 'package:cupertino_ui/cupertino_ui.dart';

/// A film's progress as a thin track with a thumb; drag or tap to seek.
class FilmScrubber extends StatelessWidget {
  const FilmScrubber({
    super.key,
    required this.progress,
    required this.onSeek,
    required this.label,
    required this.value,
  });

  /// From 0 to 1.
  final double progress;
  final ValueChanged<double> onSeek;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    slider: true,
    label: label,
    value: value,
    child: LayoutBuilder(
      builder: (context, box) {
        void seek(Offset local) =>
            onSeek((local.dx / box.maxWidth).clamp(0.0, 1.0));
        final p = progress.clamp(0.0, 1.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => seek(d.localPosition),
          onHorizontalDragStart: (d) => seek(d.localPosition),
          onHorizontalDragUpdate: (d) => seek(d.localPosition),
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: p,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  left: (box.maxWidth - 14) * p,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
