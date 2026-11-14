import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

/// One answer to a finder question, and which offerings it admits.
class FinderOption {
  const FinderOption(this.text, this.icon, this.admits);

  final String text;

  /// Null when no icon says it better than the words.
  final IconData? icon;
  final bool Function(Offering offering) admits;
}

/// One step of "find my note". No answer means any.
class FinderQuestion {
  const FinderQuestion({
    required this.prompt,
    required this.options,
    this.multiple = false,
  });

  final String prompt;
  final List<FinderOption> options;
  final bool multiple;
}

final finderQuestions = <FinderQuestion>[
  FinderQuestion(
    prompt: 'Which currency will you invest in?',
    options: [
      for (final c in Currency.values)
        FinderOption(c.code, switch (c) {
          Currency.usd => CupertinoIcons.money_dollar,
          Currency.eur => CupertinoIcons.money_euro,
          Currency.gbp => CupertinoIcons.money_pound,
        }, (o) => o.currency == c),
    ],
  ),
  FinderQuestion(
    prompt: 'How much of your principal must come back?',
    options: [
      FinderOption(
        'All of it, whatever happens',
        CupertinoIcons.shield_fill,
        (o) => o.payoff.protectsPrincipal,
      ),
      FinderOption(
        'Most of it, with a buffer',
        CupertinoIcons.shield_lefthalf_fill,
        (o) => o.type == NoteType.par,
      ),
      FinderOption(
        'I want income and accept risk',
        CupertinoIcons.arrow_2_circlepath,
        (o) => o.type == NoteType.auto,
      ),
    ],
  ),
  FinderQuestion(
    prompt: 'What should your return follow?',
    multiple: true,
    options: [
      FinderOption(
        'Shares',
        CupertinoIcons.graph_square,
        (o) => o.assetClass == AssetClass.equity,
      ),
      FinderOption(
        'Commodities',
        CupertinoIcons.cube_box,
        (o) => o.assetClass == AssetClass.commodity,
      ),
      FinderOption(
        'Interest rates',
        CupertinoIcons.percent,
        (o) => o.assetClass == AssetClass.rates,
      ),
      FinderOption(
        'A mix',
        CupertinoIcons.square_stack_3d_up,
        (o) => o.assetClass == AssetClass.multiAsset,
      ),
    ],
  ),
  FinderQuestion(
    prompt: 'How long can you leave the money?',
    options: [
      FinderOption(
        'Up to 3 years',
        CupertinoIcons.hourglass_bottomhalf_fill,
        (o) => o.termYears <= 3,
      ),
      FinderOption(
        '4 to 5 years',
        CupertinoIcons.hourglass,
        (o) => o.termYears >= 4 && o.termYears <= 5,
      ),
      FinderOption(
        '6 years or more',
        CupertinoIcons.hourglass_tophalf_fill,
        (o) => o.termYears >= 6,
      ),
    ],
  ),
  FinderQuestion(
    prompt: 'Where do you want exposure?',
    multiple: true,
    options: [
      for (final r in Region.values)
        FinderOption(
          r.title,
          null,
          (o) => o.region == r || o.region == Region.global,
        ),
    ],
  ),
];
