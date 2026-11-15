import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/payoff_model.dart';

/// An explainer as the API sends it.
class ExplainerModel {
  const ExplainerModel({
    required this.id,
    required this.title,
    required this.payoff,
    required this.path,
  });

  factory ExplainerModel.fromJson(Json json) => ExplainerModel(
    id: json['id'] as String,
    title: json['title'] as String,
    payoff: PayoffModel.fromJson(JsonRead.object(json['payoff'])),
    path: JsonRead.numbers(json['path']),
  );

  final String id;
  final String title;
  final PayoffModel payoff;
  final List<double> path;
}
