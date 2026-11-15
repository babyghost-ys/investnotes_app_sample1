part of 'education_bloc.dart';

/// The halves of Education, in the order the segmented control shows them.
enum EducationSegment { videos, articles }

final class EducationState extends Equatable {
  const EducationState({this.segment = EducationSegment.videos});

  final EducationSegment segment;

  @override
  List<Object?> get props => [segment];
}
