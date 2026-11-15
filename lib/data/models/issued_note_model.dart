import 'package:investnotes_app_sample1/data/models/json.dart';

/// An issued note as the API sends it: enums by name, dates as ISO 8601.
class IssuedNoteModel {
  const IssuedNoteModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.status,
    required this.issued,
    required this.matures,
    required this.history,
  });

  factory IssuedNoteModel.fromJson(Json json) => IssuedNoteModel(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    currency: json['currency'] as String,
    status: json['status'] as String,
    issued: json['issued'] as String,
    matures: json['matures'] as String,
    history: JsonRead.numbers(json['history']),
  );

  final String id;
  final String name;
  final String type;
  final String currency;
  final String status;
  final String issued;
  final String matures;
  final List<double> history;

  Json toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'currency': currency,
    'status': status,
    'issued': issued,
    'matures': matures,
    'history': history,
  };
}
