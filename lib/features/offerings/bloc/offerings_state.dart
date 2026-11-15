part of 'offerings_bloc.dart';

final class OfferingsState extends Equatable {
  const OfferingsState({
    this.all = const [],
    this.phase = LoadingPhase.loading,
    this.type = NoteType.mld,
    this.filter = const OfferingFilter(),
    this.saved = const {},
    this.selectedId,
  });

  final List<Offering> all;
  final LoadingPhase phase;
  final NoteType type;
  final OfferingFilter filter;
  final Set<String> saved;

  /// The offering last opened from the list, while it is open.
  final String? selectedId;

  /// The selected type's offerings, filtered and sorted.
  List<Offering> get visible => filter.apply(all.where((o) => o.type == type));

  List<Offering> get savedOfferings =>
      all.where((o) => saved.contains(o.id)).toList()
        ..sort((a, b) => a.closes.compareTo(b.closes));

  /// The offering beside the list in a split window: the one opened, while
  /// it is still in the list, or else the first.
  Offering? get detail {
    final list = visible;
    for (final o in list) {
      if (o.id == selectedId) return o;
    }
    return list.isEmpty ? null : list.first;
  }

  int countOf(NoteType type) => all.where((o) => o.type == type).length;

  Offering byId(String id) => all.firstWhere((o) => o.id == id);

  OfferingsState copyWith({
    List<Offering>? all,
    LoadingPhase? phase,
    NoteType? type,
    OfferingFilter? filter,
    Set<String>? saved,
    String? Function()? selectedId,
  }) => OfferingsState(
    all: all ?? this.all,
    phase: phase ?? this.phase,
    type: type ?? this.type,
    filter: filter ?? this.filter,
    saved: saved ?? this.saved,
    selectedId: selectedId != null ? selectedId() : this.selectedId,
  );

  @override
  List<Object?> get props => [all, phase, type, filter, saved, selectedId];
}
