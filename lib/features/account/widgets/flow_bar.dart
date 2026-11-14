import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

/// The trailing control a sign-in flow page puts in its own bar, such as
/// going back a step. Pages below set it through [FlowBarActionBinder]; the
/// page's bar, native in the iOS sheet or the app's own elsewhere, shows it.
class FlowBar extends InheritedWidget {
  const FlowBar({super.key, required this.action, required super.child});

  final ValueNotifier<NativeSheetBarAction?> action;

  static ValueNotifier<NativeSheetBarAction?>? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<FlowBar>()?.action;

  @override
  bool updateShouldNotify(FlowBar old) => action != old.action;
}
