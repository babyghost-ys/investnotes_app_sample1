import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';

/// How far back issued notes reach, by issue date.
enum IssuedPeriod {
  all('All', null),
  year('1Y', 365),
  threeYears('3Y', 365 * 3),
  fiveYears('5Y', 365 * 5),
  custom('Custom', null);

  const IssuedPeriod(this.label, this.days);

  final String label;
  final int? days;
}

/// Narrows the issued list. Empty sets mean all.
class IssuedFilter extends Equatable {
  const IssuedFilter({
    this.statuses = const {},
    this.currencies = const {},
    this.types = const {},
    this.period = IssuedPeriod.all,
    this.from,
    this.to,
  });

  final Set<IssuedStatus> statuses;
  final Set<Currency> currencies;
  final Set<NoteType> types;
  final IssuedPeriod period;

  /// The issue-date range when [period] is custom.
  final DateTime? from;
  final DateTime? to;

  /// A custom range starting a year back, for when Custom is first chosen.
  static ({DateTime from, DateTime to}) defaultRange([DateTime? now]) {
    final today = now ?? DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    return (from: DateTime(day.year - 1, day.month, day.day), to: day);
  }

  int get activeCount =>
      (statuses.isEmpty ? 0 : 1) +
      (currencies.isEmpty ? 0 : 1) +
      (types.isEmpty ? 0 : 1) +
      (period == IssuedPeriod.all ? 0 : 1);

  List<IssuedNote> apply(Iterable<IssuedNote> source, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final days = period.days;
    final list =
        source
            .where(
              (n) =>
                  (statuses.isEmpty || statuses.contains(n.status)) &&
                  (currencies.isEmpty || currencies.contains(n.currency)) &&
                  (types.isEmpty || types.contains(n.type)) &&
                  (days == null || today.difference(n.issued).inDays <= days) &&
                  (period != IssuedPeriod.custom ||
                      ((from == null || !n.issued.isBefore(from!)) &&
                          (to == null ||
                              n.issued.isBefore(
                                to!.add(const Duration(days: 1)),
                              )))),
            )
            .toList()
          ..sort((a, b) => b.issued.compareTo(a.issued));
    return list;
  }

  IssuedFilter copyWith({
    Set<IssuedStatus>? statuses,
    Set<Currency>? currencies,
    Set<NoteType>? types,
    IssuedPeriod? period,
    DateTime? from,
    DateTime? to,
  }) => IssuedFilter(
    statuses: statuses ?? this.statuses,
    currencies: currencies ?? this.currencies,
    types: types ?? this.types,
    period: period ?? this.period,
    from: from ?? this.from,
    to: to ?? this.to,
  );

  Map<String, Object> encode() => {
    'statuses': statuses.map((e) => e.name).toList(),
    'currencies': currencies.map((e) => e.name).toList(),
    'types': types.map((e) => e.name).toList(),
    'period': period.name,
    'from': ?from?.toIso8601String(),
    'to': ?to?.toIso8601String(),
  };

  static IssuedFilter decode(Object value) {
    final map = Map<Object?, Object?>.from(value as Map);
    Set<String> names(String key) => (map[key] as List).cast<String>().toSet();
    return IssuedFilter(
      statuses: names('statuses').map(IssuedStatus.values.byName).toSet(),
      currencies: names('currencies').map(Currency.values.byName).toSet(),
      types: names('types').map(NoteType.values.byName).toSet(),
      period: IssuedPeriod.values.byName(map['period'] as String),
      from: map['from'] == null ? null : DateTime.parse(map['from'] as String),
      to: map['to'] == null ? null : DateTime.parse(map['to'] as String),
    );
  }

  @override
  List<Object?> get props => [statuses, currencies, types, period, from, to];
}
