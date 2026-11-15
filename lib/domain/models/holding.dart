import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/issued_note.dart';

/// A note the signed-in investor holds, and how much went into it.
class Holding extends Equatable {
  const Holding({required this.note, required this.principal});

  final IssuedNote note;

  /// Amount invested at issue, in the note's currency.
  final double principal;

  /// Indicative value today.
  double get value => principal * note.history.last;

  @override
  List<Object?> get props => [note, principal];
}
