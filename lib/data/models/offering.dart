import 'package:equatable/equatable.dart';

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
