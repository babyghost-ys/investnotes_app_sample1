import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/payoff_model.dart';

/// An offering as the API sends it: enums by name, dates as ISO 8601.
class OfferingModel {
  const OfferingModel({
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

  factory OfferingModel.fromJson(Json json) => OfferingModel(
    id: json['id'] as String,
    name: json['name'] as String,
    underlying: json['underlying'] as String,
    payoff: PayoffModel.fromJson(JsonRead.object(json['payoff'])),
    currency: json['currency'] as String,
    region: json['region'] as String,
    assetClass: json['assetClass'] as String,
    termYears: json['termYears'] as int,
    closes: json['closes'] as String,
    shareClass: json['shareClass'] as String,
    goal: json['goal'] as String,
    payout: json['payout'] as String,
  );

  final String id;
  final String name;
  final String underlying;
  final PayoffModel payoff;
  final String currency;
  final String region;
  final String assetClass;
  final int termYears;
  final String closes;
  final String shareClass;
  final String goal;
  final String payout;

  Json toJson() => {
    'id': id,
    'name': name,
    'underlying': underlying,
    'payoff': payoff.toJson(),
    'currency': currency,
    'region': region,
    'assetClass': assetClass,
    'termYears': termYears,
    'closes': closes,
    'shareClass': shareClass,
    'goal': goal,
    'payout': payout,
  };
}
