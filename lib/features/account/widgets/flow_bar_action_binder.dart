import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/features/account/widgets/flow_bar.dart';

/// Puts [action] in the bar of the flow page around it, or clears the
/// bar's control when it is null. The bar changes after the frame, never
/// while it is being built.
class FlowBarActionBinder extends StatefulWidget {
  const FlowBarActionBinder({
    super.key,
    required this.action,
    required this.child,
  });

  final NativeSheetBarAction? action;
  final Widget child;

  @override
  State<FlowBarActionBinder> createState() => _FlowBarActionBinderState();
}

class _FlowBarActionBinderState extends State<FlowBarActionBinder> {
  ValueNotifier<NativeSheetBarAction?>? _bar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bar = FlowBar.maybeOf(context);
    _apply();
  }

  @override
  void didUpdateWidget(FlowBarActionBinder old) {
    super.didUpdateWidget(old);
    if ((old.action == null) != (widget.action == null)) _apply();
  }

  void _apply() {
    final action = widget.action;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bar?.value = action;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
