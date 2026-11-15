part of 'education_bloc.dart';

sealed class EducationEvent extends Equatable {
  const EducationEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the films, explainers and articles: on first showing the tab,
/// and on trying again.
final class EducationRequested extends EducationEvent {
  const EducationRequested();
}

final class EducationSegmentSelected extends EducationEvent {
  const EducationSegmentSelected(this.segment);

  final EducationSegment segment;

  @override
  List<Object?> get props => [segment];
}
