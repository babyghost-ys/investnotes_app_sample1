part of 'issued_bloc.dart';

final class IssuedState extends Equatable implements Loadable {
  const IssuedState({
    this.all = const [],
    this.phase = LoadingPhase.loading,
    this.filter = const IssuedFilter(),
    this.expanded = const {},
  });

  final List<IssuedNote> all;
  @override
  final LoadingPhase phase;
  final IssuedFilter filter;
  final Set<String> expanded;

  List<IssuedNote> get visible => filter.apply(all);

  IssuedState copyWith({
    List<IssuedNote>? all,
    LoadingPhase? phase,
    IssuedFilter? filter,
    Set<String>? expanded,
  }) => IssuedState(
    all: all ?? this.all,
    phase: phase ?? this.phase,
    filter: filter ?? this.filter,
    expanded: expanded ?? this.expanded,
  );

  @override
  List<Object?> get props => [all, phase, filter, expanded];
}
