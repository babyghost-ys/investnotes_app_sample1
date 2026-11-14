import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/features/account/widgets/flow_bar.dart';

/// Holds a flow page's bar control for as long as the page lives, and
/// hands it to the page's bar through [builder].
class FlowBarHost extends StatefulWidget {
  const FlowBarHost({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    ValueNotifier<NativeSheetBarAction?> action,
  )
  builder;

  @override
  State<FlowBarHost> createState() => _FlowBarHostState();
}

class _FlowBarHostState extends State<FlowBarHost> {
  final _action = ValueNotifier<NativeSheetBarAction?>(null);

  @override
  void dispose() {
    _action.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FlowBar(action: _action, child: widget.builder(context, _action));
}
