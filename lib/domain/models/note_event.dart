import 'package:equatable/equatable.dart';

/// Something that happens to a note on a set date.
enum NoteEventKind { closes, issued, callCheck, called, matures }

class NoteEvent extends Equatable {
  const NoteEvent(this.kind, this.date);

  final NoteEventKind kind;
  final DateTime date;

  @override
  List<Object?> get props => [kind, date];
}
