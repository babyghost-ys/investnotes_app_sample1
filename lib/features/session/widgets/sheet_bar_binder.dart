import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

/// Tells the sign-in sheet's native navigation bar what to show while this
/// page is in front: its [title], and back or close.
class SheetBarBinder extends StatefulWidget {
  const SheetBarBinder({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.onClose,
  });

  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final Widget child;

  @override
  State<SheetBarBinder> createState() => _SheetBarBinderState();
}

class _SheetBarBinderState extends State<SheetBarBinder> {
  bool _current = false;

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the page comes to the front again after a pop.
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current && !_current) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AdaptiveNativeSheet.setBar(
          title: widget.title,
          onBack: widget.onBack,
          onClose: widget.onClose,
        );
      });
    }
    _current = current;
    return widget.child;
  }
}
