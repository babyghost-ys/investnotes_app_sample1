part of 'education_bloc.dart';

sealed class EducationEvent extends Equatable {
  const EducationEvent();

  @override
  List<Object?> get props => [];
}

final class EducationSegmentSelected extends EducationEvent {
  const EducationSegmentSelected(this.segment);

  final EducationSegment segment;

  @override
  List<Object?> get props => [segment];
}
