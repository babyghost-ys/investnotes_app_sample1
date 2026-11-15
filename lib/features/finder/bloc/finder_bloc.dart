import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/finder_question.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

part 'finder_event.dart';
part 'finder_state.dart';

/// The answers given in "find my note". The offerings they lead to come
/// from the offerings already fetched (see [FinderState.matchesIn]).
class FinderBloc extends Bloc<FinderEvent, FinderState> {
  FinderBloc()
    : super(
        FinderState(
          answers: List.generate(finderQuestions.length, (_) => const {}),
        ),
      ) {
    on<FinderOptionToggled>((event, emit) {
      final question = finderQuestions[event.question];
      final current = state.answers[event.question];
      final Set<int> next;
      if (question.multiple) {
        next = {...current};
        if (!next.remove(event.option)) next.add(event.option);
      } else {
        next = current.contains(event.option) ? {} : {event.option};
      }
      emit(state.withAnswer(event.question, next));
    });
    on<FinderRestarted>(
      (event, emit) => emit(
        FinderState(
          answers: List.generate(finderQuestions.length, (_) => const {}),
        ),
      ),
    );
  }
}
