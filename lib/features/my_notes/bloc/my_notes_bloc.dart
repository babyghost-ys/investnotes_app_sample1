import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/holding.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'my_notes_event.dart';
part 'my_notes_state.dart';

/// The notes the signed-in investor holds, largest first.
class MyNotesBloc extends Bloc<MyNotesEvent, MyNotesState> {
  MyNotesBloc(this._repository) : super(const MyNotesState()) {
    on<MyNotesStarted>((event, emit) {
      final holdings = [..._repository.holdings]
        ..sort((a, b) => b.value.compareTo(a.value));
      emit(MyNotesState(holdings: holdings));
    });
  }

  final NotesRepository _repository;
}
