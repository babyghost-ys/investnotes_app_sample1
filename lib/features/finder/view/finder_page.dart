import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/app/push_page.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/finder_question.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/finder/bloc/finder_bloc.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_results_page.dart';
import 'package:investnotes_app_sample1/features/finder/widgets/answer_row.dart';
import 'package:investnotes_app_sample1/features/finder/widgets/step_bar.dart';

/// Starts "find my note" from its first question. The answers live for as
/// long as the first question's page does.
Future<void> startFinder(BuildContext context) async {
  final bloc = FinderBloc(context.read<NotesRepository>());
  await _pushStep(context, bloc, 0);
  await bloc.close();
}

Future<void> _pushStep(BuildContext context, FinderBloc bloc, int step) =>
    pushPage<void>(
      context,
      title: 'Find my note',
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: FinderPage(step: step),
      ),
    );

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
                    onPressed: () => last
                        ? pushPage<void>(
                            context,
                            title: 'Your notes',
                            actions: [
                              AdaptiveAppBarAction(
                                icon: const AdaptiveIcon(
                                  sfSymbol: 'checkmark',
                                  icon: CupertinoIcons.checkmark,
                                ),
                                label: 'Done',
                                onPressed: () => Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst),
                              ),
                            ],
                            builder: (_) => BlocProvider.value(
                              value: bloc,
                              child: const FinderResultsPage(),
                            ),
                          )
                        : _pushStep(context, bloc, step + 1),
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
