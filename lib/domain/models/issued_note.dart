import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/note_enums.dart';

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
