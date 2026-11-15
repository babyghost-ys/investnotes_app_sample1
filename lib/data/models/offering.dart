import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/payoff.dart';

/// A note open for subscription.
class Offering extends Equatable {
  const Offering({
    required this.id,
    required this.name,
    required this.underlying,
    required this.payoff,
    required this.currency,
    required this.region,
    required this.assetClass,
    required this.termYears,
    required this.closes,
    required this.shareClass,
    required this.goal,
    required this.payout,
  });

  factory Offering.fromJson(Json json) => Offering(
    id: json['id'] as String,
    name: json['name'] as String,
    underlying: json['underlying'] as String,
    payoff: Payoff.fromJson(json['payoff'] as Json),
    currency: Currency.values.byName(json['currency'] as String),
    region: Region.values.byName(json['region'] as String),
    assetClass: AssetClass.values.byName(json['assetClass'] as String),
    termYears: json['termYears'] as int,
    closes: JsonRead.date(json['closes']),
    shareClass: ShareClass.values.byName(json['shareClass'] as String),
    goal: NoteGoal.values.byName(json['goal'] as String),
    payout: Payout.values.byName(json['payout'] as String),
  );

  /// As the API sends it, for handing to a native sheet's own engine.
  Json toJson() => {
    'id': id,
    'name': name,
    'underlying': underlying,
    'payoff': payoff.toJson(),
    'currency': currency.name,
    'region': region.name,
    'assetClass': assetClass.name,
    'termYears': termYears,
    'closes': closes.toUtc().toIso8601String(),
    'shareClass': shareClass.name,
    'goal': goal.name,
    'payout': payout.name,
  };

  final String id;
  final String name;
  final String underlying;
  final Payoff payoff;
  final Currency currency;
  final Region region;
  final AssetClass assetClass;
  final int termYears;
  final DateTime closes;
  final ShareClass shareClass;
  final NoteGoal goal;
  final Payout payout;

  NoteType get type => payoff.type;

  /// The figure people compare notes by: the cap, the coupon, or the
  /// participation when the upside is uncapped.
  double get headline => switch (type) {
    NoteType.auto => payoff.coupon,
    _ => payoff.cap ?? payoff.participation,
  };

  bool get headlineIsRate => type == NoteType.auto || payoff.cap != null;

  @override
  List<Object?> get props => [id];
}
