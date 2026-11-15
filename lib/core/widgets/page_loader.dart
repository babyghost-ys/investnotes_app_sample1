import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/loading/page_load_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_pulse.dart';
import 'package:investnotes_app_sample1/data/models/loading_phase.dart';

/// A page's body behind its [LoadingPhase]: the page's own [skeleton] while
/// it loads, then [child], faded in over it. A failed load offers to try
/// again. Loading starts the first time the page is on screen, so a tab
/// kept behind another loads when it is opened, not at launch.
class PageLoader extends StatelessWidget {
  const PageLoader({super.key, required this.skeleton, required this.child});

  /// The page's layout in placeholder shapes, drawn on the page's colour.
  final Widget skeleton;

  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PageLoadBloc(),
    child: _StartWhenShown(
      child: BlocBuilder<PageLoadBloc, PageLoadState>(
        builder: (context, state) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          child: switch (state.phase) {
            LoadingPhase.loading => SkeletonPulse(
              key: const ValueKey(LoadingPhase.loading),
              child: skeleton,
            ),
            LoadingPhase.loaded => KeyedSubtree(
              key: const ValueKey(LoadingPhase.loaded),
              child: child,
            ),
            LoadingPhase.failed => ColoredBox(
              key: const ValueKey(LoadingPhase.failed),
              color: KeelColors.page.of(context),
              child: Center(
                child: EmptyState(
                  icon: CupertinoIcons.exclamationmark_circle,
                  semanticLabel: 'Didn’t load',
                  action: RoundIconButton(
                    icon: CupertinoIcons.arrow_clockwise,
                    label: 'Try again',
                    foreground: KeelColors.azure.of(context),
                    background: KeelColors.mist.of(context),
                    onPressed: () => context.read<PageLoadBloc>().add(
                      const PageLoadStarted(),
                    ),
                  ),
                ),
              ),
            ),
          },
        ),
      ),
    ),
  );
}

/// Starts the page's load the first time it is on screen. Tab containers
/// keep a hidden page with its tickers off, or behind a [Visibility]; either
/// means it is not on screen yet.
class _StartWhenShown extends StatefulWidget {
  const _StartWhenShown({required this.child});

  final Widget child;

  @override
  State<_StartWhenShown> createState() => _StartWhenShownState();
}

class _StartWhenShownState extends State<_StartWhenShown> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final onScreen =
        TickerMode.valuesOf(context).enabled && Visibility.of(context);
    if (onScreen && !_started) {
      _started = true;
      context.read<PageLoadBloc>().add(const PageLoadStarted());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
