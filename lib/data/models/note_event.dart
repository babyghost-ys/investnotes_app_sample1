import 'package:equatable/equatable.dart';

/// Something that happens to a note on a set date.
enum NoteEventKind {
  closes('Subscription closes'),
  issued('Issued'),
  callCheck('Call check'),
  called('Called'),
  matures('Matures');

  const NoteEventKind(this.title);

  final String title;
}

class NoteEvent extends Equatable {
  const NoteEvent(this.kind, this.date);

  final NoteEventKind kind;
  final DateTime date;

  @override
  List<Object?> get props => [kind, date];
}
