import 'package:cupertino_ui/cupertino_ui.dart';

/// Holds a page's skeleton: every [Bone] below it breathes in step, slowly
/// fading and returning, until the real content takes its place. Still when
/// the system asks for less motion.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  /// The shared opacity for the bones below [context]; fully opaque when
  /// there is no pulse above them.
  static Animation<double> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Pulse>()?.opacity ??
      kAlwaysCompleteAnimation;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: 0.45,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Loading',
    excludeSemantics: true,
    child: _Pulse(
      opacity: _still ? kAlwaysCompleteAnimation : _opacity,
      child: widget.child,
    ),
  );
}

class _Pulse extends InheritedWidget {
  const _Pulse({required this.opacity, required super.child});

  final Animation<double> opacity;

  @override
  bool updateShouldNotify(_Pulse old) => old.opacity != opacity;
}
