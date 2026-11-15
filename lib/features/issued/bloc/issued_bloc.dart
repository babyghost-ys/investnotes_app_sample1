import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/core/loading/loadable.dart';
import 'package:investnotes_app_sample1/domain/models/issued_filter.dart';
import 'package:investnotes_app_sample1/domain/models/issued_note.dart';
import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';
import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';

part 'issued_event.dart';
part 'issued_state.dart';

/// Notes already issued, filtered, with the rows the user has opened.
class IssuedBloc extends Bloc<IssuedEvent, IssuedState> {
  IssuedBloc(this._repository) : super(const IssuedState()) {
    on<IssuedRequested>(transformer: droppable(), (event, emit) async {
      emit(state.copyWith(phase: LoadingPhase.loading));
      try {
        final all = await _repository.fetchIssued();
        emit(state.copyWith(all: all, phase: LoadingPhase.loaded));
      } on NotesUnavailable {
        emit(state.copyWith(phase: LoadingPhase.failed));
      }
    });
    on<IssuedFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
    on<IssuedRowToggled>((event, emit) {
      final expanded = {...state.expanded};
      if (!expanded.remove(event.id)) expanded.add(event.id);
      emit(state.copyWith(expanded: expanded));
    });
  }

  final NotesRepository _repository;
}

/// Asks [bloc] for the issued notes, for the tab that shows them.
void requestIssued(IssuedBloc bloc) => bloc.add(const IssuedRequested());
