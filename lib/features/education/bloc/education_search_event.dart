part of 'education_search_bloc.dart';

sealed class EducationSearchEvent extends Equatable {
  const EducationSearchEvent();

  @override
  List<Object?> get props => [];
}

final class EducationSearchTypeSelected extends EducationSearchEvent {
  const EducationSearchTypeSelected(this.type);

  final NoteType type;

  @override
  List<Object?> get props => [type];
}

final class EducationSearchFilterChanged extends EducationSearchEvent {
  const EducationSearchFilterChanged(this.filter);

  final OfferingFilter filter;

  @override
  List<Object?> get props => [filter];
}
