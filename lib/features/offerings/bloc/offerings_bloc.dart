import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/core/loading/loadable.dart';
import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/offering.dart';
import 'package:investnotes_app_sample1/domain/models/offering_filter.dart';
import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';

part 'offerings_event.dart';
part 'offerings_state.dart';

/// Open offerings: loading them, the selected note type, the filter, and
/// saved notes. A failed load stays failed until someone asks again.
class OfferingsBloc extends Bloc<OfferingsEvent, OfferingsState> {
  OfferingsBloc(this._repository) : super(const OfferingsState()) {
    // One fetch at a time: asking again while one runs changes nothing.
    on<OfferingsRequested>(transformer: droppable(), (event, emit) async {
      emit(state.copyWith(phase: LoadingPhase.loading));
      try {
        final all = await _repository.fetchOfferings();
        emit(state.copyWith(all: all, phase: LoadingPhase.loaded));
      } on NotesUnavailable {
        emit(state.copyWith(phase: LoadingPhase.failed));
      }
    });
    on<OfferingsTypeSelected>(
      (event, emit) => emit(state.copyWith(type: event.type)),
    );
    on<OfferingsFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
    on<OfferingSelected>(
      (event, emit) => emit(state.copyWith(selectedId: () => event.id)),
    );
    on<OfferingSaveToggled>((event, emit) {
      final saved = {...state.saved};
      if (!saved.remove(event.id)) saved.add(event.id);
      emit(state.copyWith(saved: saved));
    });
  }

  final NotesRepository _repository;
}

/// Asks [bloc] for the offerings, for a page that shows them.
void requestOfferings(OfferingsBloc bloc) =>
    bloc.add(const OfferingsRequested());
