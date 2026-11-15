import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/domain/models/finder_question.dart';
import 'package:investnotes_app_sample1/features/finder/bloc/finder_bloc.dart';
import 'package:investnotes_app_sample1/features/finder/widgets/answer_row.dart';
import 'package:investnotes_app_sample1/features/finder/widgets/step_bar.dart';

/// Starts "find my note" afresh from its first question.
Future<void> startFinder(BuildContext context) {
  context.read<FinderBloc>().add(const FinderRestarted());
  return context.push<void>(KeelRoutes.finderStep(0));
}

/// One question of the finder.
class FinderPage extends StatelessWidget implements LocalisationConsumer {
  const FinderPage({super.key, required this.step});

  final int step;

  @override
  List<String> get namespaces => const [Locales.finder, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as FinderLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    FinderLocale finder,
    GeneralLocale general,
  ) {
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
                StepBar(
                  step: step,
                  count: finderQuestions.length,
                  label: finder.semantics.step(
                    step: step + 1,
                    count: finderQuestions.length,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  question.prompt(finder, general),
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
                    text: question.options[i].text(finder, general),
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
                    label: last
                        ? finder.semantics.showNotes
                        : finder.semantics.nextQuestion,
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
