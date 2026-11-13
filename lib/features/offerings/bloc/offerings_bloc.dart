import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'offerings_event.dart';
part 'offerings_state.dart';

/// Open offerings: the selected note type, the filter, and saved notes.
class OfferingsBloc extends Bloc<OfferingsEvent, OfferingsState> {
  OfferingsBloc(NotesRepository repository)
    : super(OfferingsState(all: repository.offerings)) {
    on<OfferingsTypeSelected>(
      (event, emit) => emit(state.copyWith(type: event.type)),
    );
    on<OfferingsFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
    on<OfferingSaveToggled>((event, emit) {
      final saved = {...state.saved};
      if (!saved.remove(event.id)) saved.add(event.id);
      emit(state.copyWith(saved: saved));
    });
  }
}
