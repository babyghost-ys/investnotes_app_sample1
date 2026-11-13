part of 'offerings_bloc.dart';

final class OfferingsState extends Equatable {
  const OfferingsState({
    required this.all,
    this.type = NoteType.mld,
    this.filter = const OfferingFilter(),
    this.saved = const {},
  });

  final List<Offering> all;
  final NoteType type;
  final OfferingFilter filter;
  final Set<String> saved;

  /// The selected type's offerings, filtered and sorted.
  List<Offering> get visible => filter.apply(all.where((o) => o.type == type));

  List<Offering> get savedOfferings =>
      all.where((o) => saved.contains(o.id)).toList()
        ..sort((a, b) => a.closes.compareTo(b.closes));

  int countOf(NoteType type) => all.where((o) => o.type == type).length;

  Offering byId(String id) => all.firstWhere((o) => o.id == id);

  OfferingsState copyWith({
    NoteType? type,
    OfferingFilter? filter,
    Set<String>? saved,
  }) => OfferingsState(
    all: all,
    type: type ?? this.type,
    filter: filter ?? this.filter,
    saved: saved ?? this.saved,
  );

  @override
  List<Object?> get props => [all, type, filter, saved];
}
