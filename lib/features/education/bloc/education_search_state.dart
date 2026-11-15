part of 'education_search_bloc.dart';

final class EducationSearchState extends Equatable {
  const EducationSearchState({
    this.type = NoteType.mld,
    this.filter = const OfferingFilter(),
  });

  final NoteType type;
  final OfferingFilter filter;

  /// [all]'s offerings of the chosen type, filtered and sorted.
  List<Offering> visible(List<Offering> all) =>
      filter.apply(all.where((o) => o.type == type));

  EducationSearchState copyWith({NoteType? type, OfferingFilter? filter}) =>
      EducationSearchState(
        type: type ?? this.type,
        // A filter is made for one type's offerings; a new type starts clear.
        filter:
            filter ??
            (type != null && type != this.type
                ? const OfferingFilter()
                : this.filter),
      );

  @override
  List<Object?> get props => [type, filter];
}
