import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

/// Ties a page of the sign-in sheet to its native page. Arriving, it has
/// UIKit push a whole new page once it has drawn (the first page only sets
/// the bar); in front again after a pop, it lifts the picture that covered
/// it. While in front, a native back or swipe pops it.
class SheetBarBinder extends StatefulWidget {
  const SheetBarBinder({
    super.key,
    required this.first,
    required this.title,
    required this.child,
    this.onClose,
    this.closeTitle,
    this.action,
  });

  /// The sheet's first page, already in front when the sheet rises.
  final bool first;
  final String? title;
  final VoidCallback? onClose;

  /// The close control in words instead of an xmark.
  final String? closeTitle;

  /// The page's own control at the trailing end, which it may change.
  final ValueListenable<NativeSheetBarAction?>? action;
  final Widget child;

  @override
  State<SheetBarBinder> createState() => _SheetBarBinderState();
}

class _SheetBarBinderState extends State<SheetBarBinder> {
  bool _current = false;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    widget.action?.addListener(_actionChanged);
  }

  @override
  void didUpdateWidget(SheetBarBinder old) {
    super.didUpdateWidget(old);
    if (old.action != widget.action) {
      old.action?.removeListener(_actionChanged);
      widget.action?.addListener(_actionChanged);
    }
  }

  @override
  void dispose() {
    widget.action?.removeListener(_actionChanged);
    super.dispose();
  }

  /// The page changed its control while in front: the bar follows.
  void _actionChanged() {
    if (_shown && _current) _setBar();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the page comes to the front again after a pop.
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current && !_current) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _arrive());
    }
    _current = current;
    return widget.child;
  }

  void _arrive() {
    if (!mounted) return;
    NativeSheet.onPagePopped = () {
      if (mounted) Navigator.of(context).pop();
    };
    if (_shown) {
      _setBar();
      NativeSheet.revealPage();
      return;
    }
    _shown = true;
    if (widget.first) {
      _setBar();
    } else {
      NativeSheet.pushPage(
        title: widget.title,
        onClose: widget.onClose,
        closeTitle: widget.closeTitle,
        action: widget.action?.value,
      );
    }
  }

  void _setBar() => NativeSheet.setBar(
    title: widget.title,
    onClose: widget.onClose,
    closeTitle: widget.closeTitle,
    action: widget.action?.value,
  );
}
