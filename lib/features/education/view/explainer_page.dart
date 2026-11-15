import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/domain/models/explainer.dart';
import 'package:investnotes_app_sample1/features/education/bloc/explainer_bloc.dart';
import 'package:investnotes_app_sample1/features/education/widgets/explainer_stage.dart';

/// An explainer film, playing from the moment it opens: the frame, what the
/// note and the market have done so far, and play, pause and scrub.
class ExplainerPage extends StatelessWidget {
  const ExplainerPage({super.key, required this.explainer});

  final Explainer explainer;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ExplainerBloc(),
    child: _Player(explainer: explainer),
  );
}

class _Player extends StatefulWidget implements LocalisationConsumer {
  const _Player({required this.explainer});

  final Explainer explainer;

  @override
  List<String> get namespaces => const [Locales.education, Locales.general];

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> with SingleTickerProviderStateMixin {
  static const _length = Duration(seconds: 9);

  late final AnimationController _clock =
      AnimationController(vsync: this, duration: _length)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            HapticFeedback.lightImpact();
            context.read<ExplainerBloc>().add(const ExplainerFinished());
          }
        })
        ..forward();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _toggle(ExplainerState state) {
    final bloc = context.read<ExplainerBloc>();
    switch (state.phase) {
      case PlaybackPhase.playing:
        _clock.stop();
        bloc.add(const ExplainerPaused());
      case PlaybackPhase.paused:
        _clock.forward();
        bloc.add(const ExplainerPlayed());
      case PlaybackPhase.ended:
        _clock.forward(from: 0);
        bloc.add(const ExplainerPlayed());
    }
  }

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: widget,
    builder: (context, locale) => _build(
      context,
      locale[0] as EducationLocale,
      locale[1] as GeneralLocale,
    ),
  );

  Widget _build(
    BuildContext context,
    EducationLocale words,
    GeneralLocale general,
  ) {
    final insets = MediaQuery.paddingOf(context);
    final explainer = widget.explainer;
    final f = Formats(general);
    final azure = KeelColors.azure.of(context);
    final muted = KeelColors.muted.of(context);
    final stage = AnimatedBuilder(
      animation: _clock,
      builder: (context, _) => AspectRatio(
        aspectRatio: 5 / 4,
        child: ExcludeSemantics(
          child: ExplainerStage(explainer: explainer, progress: _clock.value),
        ),
      ),
    );
    final panel = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          explainer.title,
          style: TextStyle(
            color: KeelColors.ink.of(context),
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _clock,
          builder: (context, _) {
            final move = explainer.moveAt(_clock.value);
            final result = explainer.payoff.at(move);
            return _Figures(
              note: f.percent(result, signed: true),
              market: f.percent(move, signed: true),
              noteColor: result < -0.0001 ? KeelColors.loss.of(context) : azure,
              mutedColor: muted,
              spokenNote: words.semantics.noteReturns(
                value: f.percent(result, signed: true),
              ),
              spokenMarket: words.semantics.marketMoves(
                value: f.percent(move, signed: true),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        BlocBuilder<ExplainerBloc, ExplainerState>(
          builder: (context, state) => Row(
            children: [
              RoundIconButton(
                icon: switch (state.phase) {
                  PlaybackPhase.playing => CupertinoIcons.pause_fill,
                  PlaybackPhase.paused => CupertinoIcons.play_fill,
                  PlaybackPhase.ended => CupertinoIcons.arrow_counterclockwise,
                },
                label: switch (state.phase) {
                  PlaybackPhase.playing => words.semantics.pause,
                  PlaybackPhase.paused => words.semantics.play,
                  PlaybackPhase.ended => words.semantics.replay,
                },
                foreground: CupertinoColors.white,
                background: azure,
                size: 52,
                iconSize: 22,
                onPressed: () => _toggle(state),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedBuilder(
                  animation: _clock,
                  builder: (context, _) => NativeSlider(
                    value: _clock.value,
                    activeColor: azure,
                    semanticLabel: words.semantics.position,
                    semanticValue: f.percent(_clock.value),
                    onChangeStart: (_) {
                      if (state.playing) {
                        _clock.stop();
                        context.read<ExplainerBloc>().add(
                          const ExplainerPaused(),
                        );
                      }
                    },
                    onChanged: (v) => _clock.value = v,
                    onChangeEnd: (v) {
                      if (v >= 1) {
                        context.read<ExplainerBloc>().add(
                          const ExplainerFinished(),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: LayoutBuilder(
          builder: (context, box) {
            final padding = EdgeInsets.fromLTRB(
              24 + insets.left,
              insets.top + 16,
              24 + insets.right,
              insets.bottom + 24,
            );
            final width = box.maxWidth - padding.horizontal;
            final height = box.maxHeight - padding.vertical;
            // Wide and short (an unfolded device, a phone on its side): the
            // film fills the height, its figures and controls beside it.
            if (width >= 640 && width > height * 1.2) {
              final stageWidth = (height * 1.25).clamp(240.0, width * 0.6);
              return Padding(
                padding: padding,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: stageWidth, child: stage),
                      const SizedBox(width: 32),
                      SizedBox(
                        width: (width - stageWidth - 32).clamp(240.0, 420.0),
                        child: panel,
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView(
              padding: padding,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [stage, const SizedBox(height: 22), panel],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// What the note returns at this moment, large, and the market's move
/// beside it with the market line's dashed swatch.
class _Figures extends StatelessWidget {
  const _Figures({
    required this.note,
    required this.market,
    required this.noteColor,
    required this.mutedColor,
    required this.spokenNote,
    required this.spokenMarket,
  });

  final String note;
  final String market;
  final Color noteColor;
  final Color mutedColor;
  final String spokenNote;
  final String spokenMarket;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        note,
        semanticsLabel: spokenNote,
        style: TextStyle(
          color: noteColor,
          fontSize: 52,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.6,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 5,
                height: 2,
                margin: const EdgeInsets.only(right: 3),
                color: mutedColor,
              ),
            const SizedBox(width: 6),
            Text(
              market,
              semanticsLabel: spokenMarket,
              style: TextStyle(
                color: mutedColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
