import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/core/loading/loadable.dart';
import 'package:investnotes_app_sample1/domain/models/holding.dart';
import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';
import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';

part 'my_notes_event.dart';
part 'my_notes_state.dart';

/// The notes the signed-in investor holds, largest first.
class MyNotesBloc extends Bloc<MyNotesEvent, MyNotesState> {
  MyNotesBloc(this._repository) : super(const MyNotesState()) {
    on<MyNotesRequested>(transformer: droppable(), (event, emit) async {
      emit(MyNotesState(holdings: state.holdings));
      try {
        final holdings = [...await _repository.fetchHoldings()]
          ..sort((a, b) => b.value.compareTo(a.value));
        emit(MyNotesState(holdings: holdings, phase: LoadingPhase.loaded));
      } on NotesUnavailable {
        emit(
          MyNotesState(holdings: state.holdings, phase: LoadingPhase.failed),
        );
      }
    });
  }

  final NotesRepository _repository;
}

/// Asks [bloc] for the holdings, for the tab that shows them.
void requestHoldings(MyNotesBloc bloc) => bloc.add(const MyNotesRequested());
