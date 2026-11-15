import 'package:investnotes_app_sample1/data/models/json.dart';

/// A payoff as the API sends it. Rates are fractions.
class PayoffModel {
  const PayoffModel({
    required this.type,
    required this.participation,
    required this.cap,
    required this.buffer,
    required this.coupon,
    required this.barrier,
  });

  factory PayoffModel.fromJson(Json json) => PayoffModel(
    type: json['type'] as String,
    participation: JsonRead.number(json['participation']),
    cap: JsonRead.numberOrNull(json['cap']),
    buffer: JsonRead.number(json['buffer']),
    coupon: JsonRead.number(json['coupon']),
    barrier: JsonRead.number(json['barrier']),
  );

  final String type;
  final double participation;
  final double? cap;
  final double buffer;
  final double coupon;
  final double barrier;

  Json toJson() => {
    'type': type,
    'participation': participation,
    'cap': cap,
    'buffer': buffer,
    'coupon': coupon,
    'barrier': barrier,
  };
}
