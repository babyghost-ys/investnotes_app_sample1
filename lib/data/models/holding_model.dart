import 'package:investnotes_app_sample1/data/models/issued_note_model.dart';
import 'package:investnotes_app_sample1/data/models/json.dart';

/// A holding as the API sends it.
class HoldingModel {
  const HoldingModel({required this.note, required this.principal});

  factory HoldingModel.fromJson(Json json) => HoldingModel(
    note: IssuedNoteModel.fromJson(JsonRead.object(json['note'])),
    principal: JsonRead.number(json['principal']),
  );

  final IssuedNoteModel note;
  final double principal;
}
