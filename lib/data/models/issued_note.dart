import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';

/// A note already issued, tracked to today or to its maturity.
class IssuedNote extends Equatable {
  const IssuedNote({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.status,
    required this.issued,
    required this.matures,
    required this.history,
  });

  factory IssuedNote.fromJson(Json json) => IssuedNote(
    id: json['id'] as String,
    name: json['name'] as String,
    type: NoteType.values.byName(json['type'] as String),
    currency: Currency.values.byName(json['currency'] as String),
    status: IssuedStatus.values.byName(json['status'] as String),
    issued: JsonRead.date(json['issued']),
    matures: JsonRead.date(json['matures']),
    history: JsonRead.numbers(json['history']),
  );

  /// As the API sends it, for handing to a native sheet's own engine.
  Json toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'currency': currency.name,
    'status': status.name,
    'issued': issued.toUtc().toIso8601String(),
    'matures': matures.toUtc().toIso8601String(),
    'history': history,
  };

  final String id;
  final String name;
  final NoteType type;
  final Currency currency;
  final IssuedStatus status;
  final DateTime issued;
  final DateTime matures;

  /// Indicative value as a fraction of principal, oldest first.
  final List<double> history;

  /// Return since issue, from the latest value.
  double get change => history.last - 1;

  @override
  List<Object?> get props => [id];
}
