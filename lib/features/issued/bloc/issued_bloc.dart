import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/issued_filter.dart';
import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'issued_event.dart';
part 'issued_state.dart';

/// Notes already issued, filtered, with the rows the user has opened.
class IssuedBloc extends Bloc<IssuedEvent, IssuedState> {
  IssuedBloc(NotesRepository repository)
    : super(IssuedState(all: repository.issued)) {
    on<IssuedFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
    on<IssuedRowToggled>((event, emit) {
      final expanded = {...state.expanded};
      if (!expanded.remove(event.id)) expanded.add(event.id);
      emit(state.copyWith(expanded: expanded));
    });
  }
}
