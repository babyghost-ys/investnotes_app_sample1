import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/payoff_model.dart';

/// A note's page as the API sends it: enums by name, dates as ISO 8601.
/// An offering has [closes] and no [status]; an issued note the reverse.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.underlying,
    required this.payoff,
    required this.currency,
    required this.region,
    required this.assetClass,
    required this.fundserv,
    required this.issueDate,
    required this.maturity,
    required this.closes,
    required this.status,
    required this.calledOn,
    required this.history,
  });

  factory ProductModel.fromJson(Json json) => ProductModel(
    id: json['id'] as String,
    name: json['name'] as String,
    underlying: json['underlying'] as String,
    payoff: PayoffModel.fromJson(JsonRead.object(json['payoff'])),
    currency: json['currency'] as String,
    region: json['region'] as String,
    assetClass: json['assetClass'] as String,
    fundserv: json['fundserv'] as String,
    issueDate: json['issueDate'] as String,
    maturity: json['maturity'] as String,
    closes: json['closes'] as String?,
    status: json['status'] as String?,
    calledOn: json['calledOn'] as String?,
    history: JsonRead.numbers(json['history']),
  );

  final String id;
  final String name;
  final String underlying;
  final PayoffModel payoff;
  final String currency;
  final String region;
  final String assetClass;
  final String fundserv;
  final String issueDate;
  final String maturity;
  final String? closes;
  final String? status;
  final String? calledOn;
  final List<double> history;
}
