part of 'issued_bloc.dart';

final class IssuedState extends Equatable {
  const IssuedState({
    required this.all,
    this.filter = const IssuedFilter(),
    this.expanded = const {},
  });

  final List<IssuedNote> all;
  final IssuedFilter filter;
  final Set<String> expanded;

  List<IssuedNote> get visible => filter.apply(all);

  IssuedState copyWith({IssuedFilter? filter, Set<String>? expanded}) =>
      IssuedState(
        all: all,
        filter: filter ?? this.filter,
        expanded: expanded ?? this.expanded,
      );

  @override
  List<Object?> get props => [all, filter, expanded];
}
