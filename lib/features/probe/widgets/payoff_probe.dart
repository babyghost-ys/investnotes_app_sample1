import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_chart.dart';
import 'package:investnotes_app_sample1/domain/models/payoff.dart';
import 'package:investnotes_app_sample1/features/probe/bloc/probe_bloc.dart';

/// Try a market move and see what the note pays: the number, the chart,
/// and a native slider to move along it.
class PayoffProbe extends StatelessWidget implements LocalisationConsumer {
  const PayoffProbe({super.key, required this.payoff});

  final Payoff payoff;

  @override
  List<String> get namespaces => const [Locales.product, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as ProductLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    ProductLocale words,
    GeneralLocale general,
  ) => BlocProvider(
    create: (_) => ProbeBloc(),
    child: BlocBuilder<ProbeBloc, ProbeState>(
      builder: (context, state) {
        final azure = KeelColors.azure.of(context);
        final muted = KeelColors.muted.of(context);
        final result = payoff.at(state.move);
        final f = Formats(general);
        final resultColor = result < 0 ? KeelColors.loss.of(context) : azure;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  f.percent(result, signed: true),
                  semanticsLabel: words.semantics.noteReturns(
                    value: f.percent(result, signed: true),
                  ),
                  style: TextStyle(
                    color: resultColor,
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
                      _Dash(color: muted),
                      const SizedBox(width: 6),
                      Text(
                        f.percent(state.move, signed: true),
                        semanticsLabel: words.semantics.marketMoves(
                          value: f.percent(state.move, signed: true),
                        ),
                        style: TextStyle(
                          color: muted,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // The figures above say what the chart shows at the slider's
            // move; the curve itself is for the eye.
            ExcludeSemantics(
              child: PayoffChart(
                payoff: payoff,
                move: state.move,
                lineColor: azure,
                marketColor: muted,
                gridColor: KeelColors.hairline.of(context),
                labelColor: muted,
                tickLabel: (tick) =>
                    tick == 0 ? '0' : f.percent(tick, signed: true),
              ),
            ),
            const SizedBox(height: 10),
            NativeSlider(
              value: state.move,
              min: PayoffChart.minMove,
              max: PayoffChart.maxMove,
              activeColor: azure,
              semanticLabel: words.semantics.marketMove,
              semanticValue: f.percent(state.move, signed: true),
              onChanged: (v) => context.read<ProbeBloc>().add(
                ProbeMoved((v * 100).roundToDouble() / 100),
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// A short dashed swatch: the chart's market line.
class _Dash extends StatelessWidget {
  const _Dash({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < 3; i++)
        Container(
          width: 5,
          height: 2,
          margin: const EdgeInsets.only(right: 3),
          color: color,
        ),
    ],
  );
}
