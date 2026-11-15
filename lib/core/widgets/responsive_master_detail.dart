import 'dart:ui' show DisplayFeatureType;

import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A list and the item it opens, laid out for the window it is in.
///
/// On a window big enough both ways, such as an unfolded iPhone Duo, the
/// [master] sits on the left and the [detail] on the right, split at the
/// hinge when the display reports one. Anywhere else, such as an iPhone in
/// either orientation, only the [master] shows: the caller pushes the detail
/// as its own page, so the native push and swipe-back stay as they are.
///
/// Open items with [open], which picks the right one of the two for the
/// window. When a split window becomes a single pane (the Duo folds) while
/// an item is open, [onCollapse] runs, so the caller can push that item; the
/// pushed page wraps itself in a `ResponsiveDetailPage`, which steps back
/// to the split once the window is wide again.
class ResponsiveMasterDetail extends StatefulWidget {
  const ResponsiveMasterDetail({
    super.key,
    required this.master,
    this.detail,
    this.placeholder,
    this.onCollapse,
  });

  /// The list.
  final Widget? master;

  /// The open item, shown beside the list in a split window. Give it a key
  /// per item so a new one fades in.
  final Widget? detail;

  /// Fills the detail pane while nothing is open.
  final Widget? placeholder;

  /// Runs when the window stops splitting while [detail] is set.
  final VoidCallback? onCollapse;

  /// The smallest window width that splits.
  static const minSplitWidth = 640.0;

  /// The smallest shorter side that splits. Keeps an iPhone turned on its
  /// side, which is wide but short, on a single pane.
  static const minSplitShortestSide = 500.0;

  /// Whether a window of this context's size shows both panes.
  static bool isSplit(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= minSplitWidth &&
        size.shortestSide >= minSplitShortestSide;
  }

  /// Opens an item: [select] always runs, so the detail pane can show it;
  /// on a single pane [push] then runs too. [onClosed] runs once a pushed
  /// item is closed by going back, not by the window splitting.
  static Future<void> open(
    BuildContext context, {
    required VoidCallback select,
    required Future<void> Function() push,
    VoidCallback? onClosed,
  }) async {
    select();
    if (isSplit(context)) return;
    await push();
    if (context.mounted && !isSplit(context)) onClosed?.call();
  }

  @override
  State<ResponsiveMasterDetail> createState() => _ResponsiveMasterDetailState();
}

class _ResponsiveMasterDetailState extends State<ResponsiveMasterDetail> {
  bool? _wasSplit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final split = ResponsiveMasterDetail.isSplit(context);
    final collapsed = _wasSplit == true && !split;
    _wasSplit = split;
    if (!collapsed || widget.detail == null || widget.onCollapse == null) {
      return;
    }
    // Only for the page in front: not a tab kept offstage, not a page
    // covered by another.
    if (!TickerMode.valuesOf(context).enabled) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final collapse = widget.onCollapse!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !ResponsiveMasterDetail.isSplit(context)) collapse();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveMasterDetail.isSplit(context)) {
      return widget.master ?? widget.detail ?? const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final split = _split(context, constraints.maxWidth);
        final media = MediaQuery.of(context);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: split.masterWidth,
              child: _pane(media, keepLeft: true, child: widget.master),
            ),
            SizedBox(
              width: split.gap,
              child: ColoredBox(color: KeelColors.hairline.of(context)),
            ),
            Expanded(
              child: _pane(
                media,
                keepLeft: false,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, ?current],
                  ),
                  child:
                      widget.detail ??
                      widget.placeholder ??
                      ColoredBox(
                        key: const ValueKey('empty'),
                        color: KeelColors.page.of(context),
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Where the panes divide. A hinge or fold running top to bottom decides
  /// it; otherwise the list takes a reading width and the item the rest.
  ({double masterWidth, double gap}) _split(
    BuildContext context,
    double width,
  ) {
    final media = MediaQuery.of(context);
    for (final feature in media.displayFeatures) {
      final bounds = feature.bounds;
      final vertical =
          bounds.top <= 0 && bounds.bottom >= media.size.height - 1;
      if (feature.type != DisplayFeatureType.cutout &&
          vertical &&
          bounds.left > 0 &&
          bounds.right < width) {
        return (
          masterWidth: bounds.left,
          gap: bounds.width > 0 ? bounds.width : 1 / media.devicePixelRatio,
        );
      }
    }
    final gap = 1 / media.devicePixelRatio;
    return (masterWidth: (width * 0.4).clamp(320.0, 420.0), gap: gap);
  }

  /// A pane keeps only the safe area on its own outer side, so the Duo's
  /// strip and the bars clear the pane that touches them.
  Widget _pane(MediaQueryData media, {required bool keepLeft, Widget? child}) {
    EdgeInsets side(EdgeInsets e) =>
        keepLeft ? e.copyWith(right: 0) : e.copyWith(left: 0);
    return ClipRect(
      child: MediaQuery(
        data: media.copyWith(
          padding: side(media.padding),
          viewPadding: side(media.viewPadding),
          viewInsets: side(media.viewInsets),
          displayFeatures: const [],
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
