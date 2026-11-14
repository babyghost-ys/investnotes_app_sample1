part of 'my_notes_bloc.dart';

sealed class MyNotesEvent extends Equatable {
  const MyNotesEvent();

  @override
  List<Object?> get props => [];
}

final class MyNotesStarted extends MyNotesEvent {
  const MyNotesStarted();
}
