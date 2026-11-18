import 'dart:ui' show DisplayFeatureType;

import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A list and the item it opens, laid out for the window it is in, the way
/// UIKit's split view does it.
///
/// On a window big enough both ways, such as an unfolded iPhone Duo, the
/// [master] sits on the left and the [detail] on the right, split at the
/// hinge when the display reports one.
///
/// On a single pane, an iPhone or a folded Duo, only the [master] shows and
/// an item opens as its own pushed page ([open]): its own bar and Back, the
/// tab bar hidden, the native slide and swipe-back.
///
/// The open item stays on screen as the window changes, with no slide:
/// a split that collapses (a Duo folding) with an item open beside the list
/// hands it to its own page, pushed in place over the list ([onCollapse]),
/// so Back slides to the list; an item's page in front when the window
/// splits again (a Duo unfolding) hands it back beside the list
/// (`SplitDetailPage`).
class ResponsiveMasterDetail extends StatefulWidget {
  const ResponsiveMasterDetail({
    super.key,
    required this.master,
    this.detail,
    this.placeholder,
    this.onCollapse,
    bool? opened,
  }) : opened = opened ?? detail != null;

  /// The list.
  final Widget? master;

  /// The open item. Give it a key per item, so a new one fades in and each
  /// keeps its own state.
  final Widget? detail;

  /// Fills the detail pane while nothing is open.
  final Widget? placeholder;

  /// Opens [detail] as its own page, in place: the window stopped splitting
  /// with it open beside the list. The caller runs [open] with `inPlace`.
  final VoidCallback? onCollapse;

  /// Whether the person opened [detail], rather than the split showing a
  /// first item so its pane is never empty. Only an opened item carries on
  /// as its own page when the split collapses.
  final bool opened;

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

  /// Opens an item: beside the list in a split window ([select]); anywhere
  /// else as its own page ([push]), sliding in, or appearing in place when
  /// it takes over from the split ([inPlace]). [onClosed] runs once that
  /// page is closed by going back to a single pane.
  static Future<void> open(
    BuildContext context, {
    required VoidCallback select,
    required Future<void> Function({required bool inPlace}) push,
    VoidCallback? onClosed,
    bool inPlace = false,
  }) async {
    if (isSplit(context)) {
      select();
      return;
    }
    await push(inPlace: inPlace);
    if (context.mounted && !isSplit(context)) onClosed?.call();
  }

  @override
  State<ResponsiveMasterDetail> createState() => _ResponsiveMasterDetailState();
}

class _ResponsiveMasterDetailState extends State<ResponsiveMasterDetail> {
  /// Carry the list and the item across a fold or unfold, so what was typed,
  /// where each was scrolled and what has loaded survive the change of
  /// layout.
  final _masterKey = GlobalKey();
  final _detailKeys = <Key?, GlobalKey>{};

  bool? _wasSplit;

  /// A hand-over to the item's own page is on its way: a window that wobbles
  /// across the split threshold mid fold must not push the item twice.
  bool _collapsing = false;

  Widget? get master => widget.master == null
      ? null
      : KeyedSubtree(key: _masterKey, child: widget.master!);

  Widget? get detail {
    final detail = widget.detail;
    if (detail == null) return null;
    _detailKeys.removeWhere((key, _) => key != detail.key);
    return KeyedSubtree(
      key: _detailKeys.putIfAbsent(detail.key, GlobalKey.new),
      child: detail,
    );
  }

  Widget? get placeholder => widget.placeholder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final split = ResponsiveMasterDetail.isSplit(context);
    final collapsed = _wasSplit == true && !split;
    _wasSplit = split;
    final collapse = widget.onCollapse;
    if (!collapsed || _collapsing || collapse == null) return;
    if (widget.detail == null || !widget.opened) return;
    // Only for the page in view: not a tab kept behind another, not a page
    // covered by another.
    if (!TickerMode.valuesOf(context).enabled) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    _collapsing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _collapsing = false;
      if (!mounted || ResponsiveMasterDetail.isSplit(context)) return;
      collapse();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveMasterDetail.isSplit(context)) {
      return master ?? const SizedBox.shrink();
    }
    final shown = detail;
    return LayoutBuilder(
      builder: (context, constraints) {
        final split = _split(context, constraints.maxWidth);
        final media = MediaQuery.of(context);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: split.masterWidth,
              child: _pane(media, keepLeft: true, child: master),
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
                      shown ??
                      placeholder ??
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
