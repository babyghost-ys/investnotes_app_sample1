import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_chart.dart';
import 'package:investnotes_app_sample1/data/models/payoff.dart';
import 'package:investnotes_app_sample1/features/probe/bloc/probe_bloc.dart';

/// Try a market move and see what the note pays: the number, the chart,
/// and a native slider to move along it.
class PayoffProbe extends StatelessWidget {
  const PayoffProbe({super.key, required this.payoff});

  final Payoff payoff;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProbeBloc(),
    child: BlocBuilder<ProbeBloc, ProbeState>(
      builder: (context, state) {
        final azure = KeelColors.azure.of(context);
        final muted = KeelColors.muted.of(context);
        final result = payoff.at(state.move);
        final resultColor = result < 0 ? KeelColors.loss.of(context) : azure;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formats.percent(result, signed: true),
                  semanticsLabel:
                      'Note returns ${Formats.percent(result, signed: true)}',
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
                        Formats.percent(state.move, signed: true),
                        semanticsLabel:
                            'Market moves ${Formats.percent(state.move, signed: true)}',
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
            PayoffChart(
              payoff: payoff,
              move: state.move,
              lineColor: azure,
              marketColor: muted,
              gridColor: KeelColors.hairline.of(context),
              labelColor: muted,
            ),
            const SizedBox(height: 10),
            AdaptiveSlider(
              value: state.move,
              min: PayoffChart.minMove,
              max: PayoffChart.maxMove,
              activeColor: azure,
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
