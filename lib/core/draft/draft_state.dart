part of 'draft_bloc.dart';

final class DraftState<T> extends Equatable {
  const DraftState(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}
