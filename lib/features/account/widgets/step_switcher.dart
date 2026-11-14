import 'package:cupertino_ui/cupertino_ui.dart';

/// Moves between a flow's steps: the new one fades in as it settles from
/// the trailing side. The step left behind gives up the keyboard, so typing
/// never lands in a field that is fading away.
class StepSwitcher extends StatefulWidget {
  const StepSwitcher({super.key, required this.step, required this.child});

  final Object step;
  final Widget child;

  @override
  State<StepSwitcher> createState() => _StepSwitcherState();
}

class _StepSwitcherState extends State<StepSwitcher> {
  @override
  void didUpdateWidget(StepSwitcher old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 280),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    child: KeyedSubtree(key: ValueKey(widget.step), child: widget.child),
  );
}
