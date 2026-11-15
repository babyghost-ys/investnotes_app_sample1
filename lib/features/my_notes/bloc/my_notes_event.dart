part of 'my_notes_bloc.dart';

sealed class MyNotesEvent extends Equatable {
  const MyNotesEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the holdings: on first showing the tab, and on trying again.
final class MyNotesRequested extends MyNotesEvent {
  const MyNotesRequested();
}
