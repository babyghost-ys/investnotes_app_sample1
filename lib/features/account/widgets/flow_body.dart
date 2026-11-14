import 'package:cupertino_ui/cupertino_ui.dart';

/// One step's content: scrolls, leaves room for the keyboard and lets a
/// drag put the keyboard away.
class FlowBody extends StatelessWidget {
  const FlowBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: EdgeInsets.fromLTRB(
      24,
      28,
      24,
      32 +
          MediaQuery.viewInsetsOf(context).bottom +
          MediaQuery.paddingOf(context).bottom,
    ),
    children: children,
  );
}
