part of 'finder_bloc.dart';

/// An offering and how many of the answered questions it satisfies.
class FinderMatch {
  const FinderMatch(this.offering, this.hits, this.of);

  final Offering offering;
  final int hits;
  final int of;

  bool get exact => hits == of;
}

final class FinderState extends Equatable {
  const FinderState({required this.offerings, required this.answers});

  final List<Offering> offerings;

  /// Chosen option indexes per question; empty means any.
  final List<Set<int>> answers;

  /// Offerings meeting every answer. When none does, the closest three.
  List<FinderMatch> get matches {
    final asked = [
      for (var q = 0; q < finderQuestions.length; q++)
        if (answers[q].isNotEmpty) q,
    ];
    final scored =
        [
          for (final o in offerings)
            FinderMatch(
              o,
              asked
                  .where(
                    (q) => answers[q].any(
                      (i) => finderQuestions[q].options[i].admits(o),
                    ),
                  )
                  .length,
              asked.length,
            ),
        ]..sort((a, b) {
          final byHits = b.hits.compareTo(a.hits);
          return byHits != 0
              ? byHits
              : a.offering.closes.compareTo(b.offering.closes);
        });
    final exact = scored.where((m) => m.exact).toList();
    return exact.isNotEmpty ? exact : scored.take(3).toList();
  }

  FinderState withAnswer(int question, Set<int> chosen) => FinderState(
    offerings: offerings,
    answers: [
      for (var q = 0; q < answers.length; q++)
        q == question ? chosen : answers[q],
    ],
  );

  @override
  List<Object?> get props => [offerings, answers];
}
