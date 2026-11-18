import 'dart:ui' show DisplayFeatureType;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A list and the item it opens, laid out for the window it is in.
///
/// On a window big enough both ways, such as an unfolded iPhone Duo, the
/// [master] sits on the left and the [detail] on the right, split at the
/// hinge when the display reports one.
///
/// On iPhone Duo folded, the open [detail] takes the list's place on this
/// same page, and Back closes it ([onClose]) to show the list again.
/// Folding and unfolding therefore only change the layout: nothing is pushed
/// or popped, and the item stays on screen the whole time.
///
/// On any other single pane, such as an iPhone, only the [master] shows and
/// the caller pushes the item as its own page, so the native push and
/// swipe-back stay as they are. Open items with [open], which picks the
/// right one for the window.
class ResponsiveMasterDetail extends StatefulWidget {
  const ResponsiveMasterDetail({
    super.key,
    required this.master,
    this.detail,
    this.placeholder,
    this.onClose,
    bool? opened,
  }) : opened = opened ?? detail != null;

  /// The list.
  final Widget? master;

  /// The open item. Give it a key per item, so a new one fades in and each
  /// keeps its own state.
  final Widget? detail;

  /// Fills the detail pane while nothing is open.
  final Widget? placeholder;

  /// Closes the open item: Back runs it while the item shows in the list's
  /// place on a folded Duo.
  final VoidCallback? onClose;

  /// Whether the person opened [detail], rather than the split showing a
  /// first item so its pane is never empty. Only an opened item takes the
  /// list's place on a folded Duo.
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

  /// Whether an opened item stays on the list's own page: beside the list
  /// in a split window, or in its place on iPhone Duo (folded, its cover
  /// display holds the system's vertical bar strip, which no other iPhone
  /// has), so a fold or an unfold never has a page to push or pop.
  static bool opensInPlace(BuildContext context) =>
      isSplit(context) || DuoPoseScope.of(context) != null;

  /// Whether an opened item takes the list's place: a folded Duo.
  static bool showsInPlace(BuildContext context) =>
      !isSplit(context) && DuoPoseScope.of(context) != null;

  /// Opens an item: [select] always runs, so this page can show it; where
  /// it does not ([opensInPlace]), [push] opens its own page too, and
  /// [onClosed] runs once that page is closed.
  static Future<void> open(
    BuildContext context, {
    required VoidCallback select,
    required Future<void> Function() push,
    VoidCallback? onClosed,
  }) async {
    select();
    if (opensInPlace(context)) return;
    await push();
    if (context.mounted && !opensInPlace(context)) onClosed?.call();
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

  /// Lets Back close an item shown in the list's place.
  LocalHistoryEntry? _back;
  bool _droppingBack = false;
  bool _syncScheduled = false;

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

  /// Whether the open item shows in the list's place right now.
  bool get _inPlace =>
      widget.detail != null &&
      widget.opened &&
      ResponsiveMasterDetail.showsInPlace(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleBackSync();
  }

  @override
  void didUpdateWidget(ResponsiveMasterDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleBackSync();
  }

  @override
  void dispose() {
    _droppingBack = true;
    final back = _back;
    _back = null;
    if (back != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => back.remove());
    }
    super.dispose();
  }

  // A route's history changes outside the build.
  void _scheduleBackSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) _syncBack();
    });
  }

  /// Holds a Back entry on this page's route exactly while the item shows
  /// in the list's place on the page in view (not a tab kept offstage).
  void _syncBack() {
    final route = ModalRoute.of(context);
    final wanted =
        route != null &&
        _inPlace &&
        widget.onClose != null &&
        TickerMode.valuesOf(context).enabled;
    if (wanted && _back == null) {
      final back = LocalHistoryEntry(
        onRemove: () {
          if (_back == null) return;
          _back = null;
          if (!_droppingBack && mounted) widget.onClose?.call();
        },
      );
      _back = back;
      route.addLocalHistoryEntry(back);
    } else if (!wanted && _back != null) {
      final back = _back!;
      _back = null;
      _droppingBack = true;
      back.remove();
      _droppingBack = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveMasterDetail.isSplit(context)) {
      final inPlace = _inPlace;
      return Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: inPlace,
            child: TickerMode(
              enabled: !inPlace,
              child: master ?? const SizedBox.shrink(),
            ),
          ),
          if (inPlace) detail!,
        ],
      );
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
