import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

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
  });

  final Set<Currency> currencies;
  final Set<Region> regions;
  final Set<AssetClass> assetClasses;
  final OfferingSort sort;
  final bool descending;

  /// Only offerings still open on this day or closing before it; null
  /// means any.
  final DateTime? closesBy;

  int get activeCount =>
      (currencies.isEmpty ? 0 : 1) +
      (regions.isEmpty ? 0 : 1) +
      (assetClasses.isEmpty ? 0 : 1) +
      (sort == OfferingSort.closing && !descending ? 0 : 1) +
      (closesBy == null ? 0 : 1);

  bool matches(Offering o) =>
      (currencies.isEmpty || currencies.contains(o.currency)) &&
      (regions.isEmpty || regions.contains(o.region)) &&
      (assetClasses.isEmpty || assetClasses.contains(o.assetClass)) &&
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
  }) => OfferingFilter(
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
  ];
}
