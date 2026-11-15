import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

/// Words for the finder, read from its namespace and the general one.
typedef FinderWords = String Function(
  FinderLocale finder,
  GeneralLocale general,
);

/// One answer to a finder question, and which offerings it admits.
class FinderOption {
  const FinderOption(this.text, this.icon, this.admits);

  final FinderWords text;

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

  final FinderWords prompt;
  final List<FinderOption> options;
  final bool multiple;
}

final finderQuestions = <FinderQuestion>[
  FinderQuestion(
    prompt: (f, _) => f.labels.currencyPrompt,
    options: [
      for (final c in Currency.values)
        FinderOption((_, _) => c.code, switch (c) {
          Currency.usd => CupertinoIcons.money_dollar,
          Currency.eur => CupertinoIcons.money_euro,
          Currency.gbp => CupertinoIcons.money_pound,
        }, (o) => o.currency == c),
    ],
  ),
  FinderQuestion(
    prompt: (f, _) => f.labels.principalPrompt,
    options: [
      FinderOption(
        (f, _) => f.labels.principalAll,
        CupertinoIcons.shield_fill,
        (o) => o.payoff.protectsPrincipal,
      ),
      FinderOption(
        (f, _) => f.labels.principalMost,
        CupertinoIcons.shield_lefthalf_fill,
        (o) => o.type == NoteType.par,
      ),
      FinderOption(
        (f, _) => f.labels.principalIncome,
        CupertinoIcons.arrow_2_circlepath,
        (o) => o.type == NoteType.auto,
      ),
    ],
  ),
  FinderQuestion(
    prompt: (f, _) => f.labels.followPrompt,
    multiple: true,
    options: [
      FinderOption(
        (f, _) => f.labels.followShares,
        CupertinoIcons.graph_square,
        (o) => o.assetClass == AssetClass.equity,
      ),
      FinderOption(
        (f, _) => f.labels.followCommodities,
        CupertinoIcons.cube_box,
        (o) => o.assetClass == AssetClass.commodity,
      ),
      FinderOption(
        (f, _) => f.labels.followRates,
        CupertinoIcons.percent,
        (o) => o.assetClass == AssetClass.rates,
      ),
      FinderOption(
        (f, _) => f.labels.followMix,
        CupertinoIcons.square_stack_3d_up,
        (o) => o.assetClass == AssetClass.multiAsset,
      ),
    ],
  ),
  FinderQuestion(
    prompt: (f, _) => f.labels.termPrompt,
    options: [
      FinderOption(
        (f, _) => f.labels.termShort,
        CupertinoIcons.hourglass_bottomhalf_fill,
        (o) => o.termYears <= 3,
      ),
      FinderOption(
        (f, _) => f.labels.termMedium,
        CupertinoIcons.hourglass,
        (o) => o.termYears >= 4 && o.termYears <= 5,
      ),
      FinderOption(
        (f, _) => f.labels.termLong,
        CupertinoIcons.hourglass_tophalf_fill,
        (o) => o.termYears >= 6,
      ),
    ],
  ),
  FinderQuestion(
    prompt: (f, _) => f.labels.regionPrompt,
    multiple: true,
    options: [
      for (final r in Region.values)
        FinderOption(
          (_, g) => r.title(g),
          null,
          (o) => o.region == r || o.region == Region.global,
        ),
    ],
  ),
];
