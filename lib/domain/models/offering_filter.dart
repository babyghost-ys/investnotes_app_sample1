import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/offering.dart';

enum OfferingSort { closing, headline, term }

/// Narrows and orders the offerings of one note type. Empty sets mean all.
class OfferingFilter extends Equatable {
  const OfferingFilter({
    this.currencies = const {},
    this.regions = const {},
    this.assetClasses = const {},
    this.sort = OfferingSort.closing,
    this.descending = false,
    this.closesBy,
    this.classes = const {},
    this.goals = const {},
    this.terms = const {},
    this.payouts = const {},
    this.minHeadline = 0,
  });

  /// The highest a minimum cap or coupon can be set to.
  static const double headlineCeiling = 0.5;

  final Set<Currency> currencies;
  final Set<Region> regions;
  final Set<AssetClass> assetClasses;
  final OfferingSort sort;
  final bool descending;

  /// Only offerings still open on this day or closing before it; null
  /// means any.
  final DateTime? closesBy;
  final Set<ShareClass> classes;
  final Set<NoteGoal> goals;
  final Set<TermBand> terms;
  final Set<Payout> payouts;

  /// Lowest cap or coupon to show. Uncapped notes always pass.
  final double minHeadline;

  int get activeCount =>
      (currencies.isEmpty ? 0 : 1) +
      (regions.isEmpty ? 0 : 1) +
      (assetClasses.isEmpty ? 0 : 1) +
      (sort == OfferingSort.closing && !descending ? 0 : 1) +
      (closesBy == null ? 0 : 1) +
      (classes.isEmpty ? 0 : 1) +
      (goals.isEmpty ? 0 : 1) +
      (terms.isEmpty ? 0 : 1) +
      (payouts.isEmpty ? 0 : 1) +
      (minHeadline > 0 ? 1 : 0);

  bool matches(Offering o) =>
      (currencies.isEmpty || currencies.contains(o.currency)) &&
      (regions.isEmpty || regions.contains(o.region)) &&
      (assetClasses.isEmpty || assetClasses.contains(o.assetClass)) &&
      (classes.isEmpty || classes.contains(o.shareClass)) &&
      (goals.isEmpty || goals.contains(o.goal)) &&
      (terms.isEmpty || terms.contains(TermBand.of(o.termYears))) &&
      (payouts.isEmpty || payouts.contains(o.payout)) &&
      (!o.headlineIsRate || o.headline >= minHeadline - 0.0001) &&
      (closesBy == null ||
          o.closes.isBefore(closesBy!.add(const Duration(days: 1))));

  List<Offering> apply(Iterable<Offering> source) {
    final list = source.where(matches).toList();
    int compare(Offering a, Offering b) => switch (sort) {
      OfferingSort.closing => a.closes.compareTo(b.closes),
      OfferingSort.headline => a.headline.compareTo(b.headline),
      OfferingSort.term => a.termYears.compareTo(b.termYears),
    };
    list.sort((a, b) => descending ? compare(b, a) : compare(a, b));
    return list;
  }

  OfferingFilter copyWith({
    Set<Currency>? currencies,
    Set<Region>? regions,
    Set<AssetClass>? assetClasses,
    OfferingSort? sort,
    bool? descending,
    DateTime? closesBy,
    bool clearClosesBy = false,
    Set<ShareClass>? classes,
    Set<NoteGoal>? goals,
    Set<TermBand>? terms,
    Set<Payout>? payouts,
    double? minHeadline,
  }) => OfferingFilter(
    terms: terms ?? this.terms,
    payouts: payouts ?? this.payouts,
    minHeadline: minHeadline ?? this.minHeadline,
    classes: classes ?? this.classes,
    goals: goals ?? this.goals,
    currencies: currencies ?? this.currencies,
    regions: regions ?? this.regions,
    assetClasses: assetClasses ?? this.assetClasses,
    sort: sort ?? this.sort,
    descending: descending ?? this.descending,
    closesBy: clearClosesBy ? null : closesBy ?? this.closesBy,
  );

  /// Plain values for the native sheet's platform channel.
  Map<String, Object> encode() => {
    'currencies': currencies.map((e) => e.name).toList(),
    'regions': regions.map((e) => e.name).toList(),
    'assetClasses': assetClasses.map((e) => e.name).toList(),
    'sort': sort.name,
    'descending': descending,
    'closesBy': ?closesBy?.toIso8601String(),
    'classes': classes.map((e) => e.name).toList(),
    'goals': goals.map((e) => e.name).toList(),
    'terms': terms.map((e) => e.name).toList(),
    'payouts': payouts.map((e) => e.name).toList(),
    'minHeadline': minHeadline,
  };

  static OfferingFilter decode(Object value) {
    final map = Map<Object?, Object?>.from(value as Map);
    Set<String> names(String key) => (map[key] as List).cast<String>().toSet();
    return OfferingFilter(
      currencies: names('currencies').map(Currency.values.byName).toSet(),
      regions: names('regions').map(Region.values.byName).toSet(),
      assetClasses: names('assetClasses').map(AssetClass.values.byName).toSet(),
      sort: OfferingSort.values.byName(map['sort'] as String),
      descending: map['descending'] as bool,
      classes: names('classes').map(ShareClass.values.byName).toSet(),
      goals: names('goals').map(NoteGoal.values.byName).toSet(),
      terms: names('terms').map(TermBand.values.byName).toSet(),
      payouts: names('payouts').map(Payout.values.byName).toSet(),
      minHeadline: (map['minHeadline'] as num).toDouble(),
      closesBy: map['closesBy'] == null
          ? null
          : DateTime.parse(map['closesBy'] as String),
    );
  }

  @override
  List<Object?> get props => [
    currencies,
    regions,
    assetClasses,
    sort,
    descending,
    closesBy,
    classes,
    goals,
    terms,
    payouts,
    minHeadline,
  ];
}
