import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

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
  });

  /// The sheet's first page, already in front when the sheet rises.
  final bool first;
  final String? title;
  final VoidCallback? onClose;
  final Widget child;

  @override
  State<SheetBarBinder> createState() => _SheetBarBinderState();
}

class _SheetBarBinderState extends State<SheetBarBinder> {
  bool _current = false;
  bool _shown = false;

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
    AdaptiveNativeSheet.onPagePopped = () {
      if (mounted) Navigator.of(context).pop();
    };
    if (_shown) {
      AdaptiveNativeSheet.setBar(title: widget.title, onClose: widget.onClose);
      AdaptiveNativeSheet.revealPage();
      return;
    }
    _shown = true;
    if (widget.first) {
      AdaptiveNativeSheet.setBar(title: widget.title, onClose: widget.onClose);
    } else {
      AdaptiveNativeSheet.pushPage(
        title: widget.title,
        onClose: widget.onClose,
      );
    }
  }
}
