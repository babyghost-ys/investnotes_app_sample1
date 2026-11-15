import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/core/loading/loadable.dart';
import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/data/models/explainer.dart';
import 'package:investnotes_app_sample1/data/models/film.dart';
import 'package:investnotes_app_sample1/data/models/loading_phase.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'education_event.dart';
part 'education_state.dart';

/// Education's films, explainers and articles, and which half is showing.
class EducationBloc extends Bloc<EducationEvent, EducationState> {
  EducationBloc(this._repository) : super(const EducationState()) {
    on<EducationRequested>(transformer: droppable(), (event, emit) async {
      emit(state.copyWith(phase: LoadingPhase.loading));
      try {
        // All three at once: the tab shows when the slowest arrives.
        final (films, explainers, articles) = await (
          _repository.fetchFilms(),
          _repository.fetchExplainers(),
          _repository.fetchArticles(),
        ).wait;
        emit(
          state.copyWith(
            films: films,
            explainers: explainers,
            articles: articles,
            phase: LoadingPhase.loaded,
          ),
        );
      } on ParallelWaitError<Object?, Object?> {
        emit(state.copyWith(phase: LoadingPhase.failed));
      }
    });
    on<EducationSegmentSelected>(
      (event, emit) => emit(state.copyWith(segment: event.segment)),
    );
  }

  final NotesRepository _repository;
}

/// Asks [bloc] for Education's content, for the tab that shows it.
void requestEducation(EducationBloc bloc) =>
    bloc.add(const EducationRequested());
