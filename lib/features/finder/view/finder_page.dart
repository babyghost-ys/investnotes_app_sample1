import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/finder_question.dart';
import 'package:investnotes_app_sample1/features/finder/bloc/finder_bloc.dart';
import 'package:investnotes_app_sample1/features/finder/widgets/answer_row.dart';
import 'package:investnotes_app_sample1/features/finder/widgets/step_bar.dart';

/// Starts "find my note" afresh from its first question.
Future<void> startFinder(BuildContext context) {
  context.read<FinderBloc>().add(const FinderRestarted());
  return context.push<void>(KeelRoutes.finderStep(0));
}

/// One question of the finder.
class FinderPage extends StatelessWidget {
  const FinderPage({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final question = finderQuestions[step];
    final last = step == finderQuestions.length - 1;
    final insets = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: BlocBuilder<FinderBloc, FinderState>(
        builder: (context, state) {
          final chosen = state.answers[step];
          final bloc = context.read<FinderBloc>();
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                insets.top + 18,
                20,
                insets.bottom + 40,
              ),
              children: [
                StepBar(step: step, count: finderQuestions.length),
                const SizedBox(height: 28),
                Text(
                  question.prompt,
                  style: TextStyle(
                    color: KeelColors.ink.of(context),
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 24),
                for (var i = 0; i < question.options.length; i++)
                  AnswerRow(
                    icon: question.options[i].icon,
                    text: question.options[i].text,
                    selected: chosen.contains(i),
                    multiple: question.multiple,
                    onTap: () => bloc.add(FinderOptionToggled(step, i)),
                  ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: RoundIconButton(
                    icon: last
                        ? CupertinoIcons.wand_stars
                        : CupertinoIcons.arrow_right,
                    label: last ? 'Show my notes' : 'Next question',
                    foreground: CupertinoColors.white,
                    background: KeelColors.azure.of(context),
                    size: 60,
                    iconSize: 24,
                    onPressed: () => context.push<void>(
                      last
                          ? KeelRoutes.finderResults
                          : KeelRoutes.finderStep(step + 1),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
