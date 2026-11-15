import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'education_event.dart';
part 'education_state.dart';

/// Which half of Education is showing: the films or the articles.
class EducationBloc extends Bloc<EducationEvent, EducationState> {
  EducationBloc() : super(const EducationState()) {
    on<EducationSegmentSelected>(
      (event, emit) => emit(EducationState(segment: event.segment)),
    );
  }
}
