import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';

part 'education_search_event.dart';
part 'education_search_state.dart';

/// The note type and filter chosen on Education's search, kept apart from
/// the Offerings tab's own.
class EducationSearchBloc
    extends Bloc<EducationSearchEvent, EducationSearchState> {
  EducationSearchBloc() : super(const EducationSearchState()) {
    on<EducationSearchTypeSelected>(
      (event, emit) => emit(state.copyWith(type: event.type)),
    );
    on<EducationSearchFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
  }
}
