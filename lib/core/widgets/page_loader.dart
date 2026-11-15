import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/loading/loadable.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_pulse.dart';
import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';

/// A page's body behind the [LoadingPhase] of the bloc [B] that fetches its
/// data: the page's own [skeleton] while it loads, then [child], faded in
/// over it. A failed load offers to try again. Loading starts the first
/// time the page is on screen, so a tab kept behind another loads when it
/// is opened, not at launch; data already loaded is not fetched again.
class PageLoader<B extends StateStreamable<S>, S extends Loadable>
    extends StatelessWidget
    implements LocalisationConsumer {
  const PageLoader({
    super.key,
    required this.skeleton,
    required this.load,
    required this.child,
  });

  /// The page's layout in placeholder shapes, drawn on the page's colour.
  final Widget skeleton;

  /// Asks [B] for the page's data: on first showing, and on trying again.
  final void Function(B bloc) load;

  final Widget child;

  @override
  List<String> get namespaces => const [Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as GeneralLocale),
  );

  Widget _build(BuildContext context, GeneralLocale general) => _StartWhenShown(
    onShown: () {
      final bloc = context.read<B>();
      if (bloc.state.phase != LoadingPhase.loaded) load(bloc);
    },
    child: BlocSelector<B, S, LoadingPhase>(
      selector: (state) => state.phase,
      builder: (context, phase) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        child: switch (phase) {
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
                semanticLabel: general.semantics.didntLoad,
                action: RoundIconButton(
                  icon: CupertinoIcons.arrow_clockwise,
                  label: general.semantics.tryAgain,
                  foreground: KeelColors.azure.of(context),
                  background: KeelColors.mist.of(context),
                  onPressed: () => load(context.read<B>()),
                ),
              ),
            ),
          ),
        },
      ),
    ),
  );
}

/// Calls [onShown] the first time the page is on screen. Tab containers
/// keep a hidden page with its tickers off, or behind a [Visibility]; either
/// means it is not on screen yet.
class _StartWhenShown extends StatefulWidget {
  const _StartWhenShown({required this.onShown, required this.child});

  final VoidCallback onShown;
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
      widget.onShown();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
