part of 'education_bloc.dart';

/// The halves of Education, in the order the segmented control shows them.
enum EducationSegment { videos, articles }

final class EducationState extends Equatable implements Loadable {
  const EducationState({
    this.segment = EducationSegment.videos,
    this.films = const [],
    this.explainers = const [],
    this.articles = const [],
    this.phase = LoadingPhase.loading,
  });

  final EducationSegment segment;
  final List<Film> films;
  final List<Explainer> explainers;
  final List<Article> articles;
  @override
  final LoadingPhase phase;

  EducationState copyWith({
    EducationSegment? segment,
    List<Film>? films,
    List<Explainer>? explainers,
    List<Article>? articles,
    LoadingPhase? phase,
  }) => EducationState(
    segment: segment ?? this.segment,
    films: films ?? this.films,
    explainers: explainers ?? this.explainers,
    articles: articles ?? this.articles,
    phase: phase ?? this.phase,
  );

  @override
  List<Object?> get props => [segment, films, explainers, articles, phase];
}
