part of 'issued_bloc.dart';

final class IssuedState extends Equatable implements Loadable {
  const IssuedState({
    this.all = const [],
    this.phase = LoadingPhase.loading,
    this.filter = const IssuedFilter(),
    this.expanded = const {},
    this.selectedId,
  });

  final List<IssuedNote> all;
  @override
  final LoadingPhase phase;
  final IssuedFilter filter;
  final Set<String> expanded;

  /// The note last opened from the list, while it is open.
  final String? selectedId;

  List<IssuedNote> get visible => filter.apply(all);

  /// The note beside the list in a split window: the one opened, while it
  /// is still in the list, or else the first.
  IssuedNote? get detail {
    final list = visible;
    for (final n in list) {
      if (n.id == selectedId) return n;
    }
    return list.isEmpty ? null : list.first;
  }

  IssuedState copyWith({
    List<IssuedNote>? all,
    LoadingPhase? phase,
    IssuedFilter? filter,
    Set<String>? expanded,
    String? Function()? selectedId,
  }) => IssuedState(
    all: all ?? this.all,
    phase: phase ?? this.phase,
    filter: filter ?? this.filter,
    expanded: expanded ?? this.expanded,
    selectedId: selectedId != null ? selectedId() : this.selectedId,
  );

  @override
  List<Object?> get props => [all, phase, filter, expanded, selectedId];
}
