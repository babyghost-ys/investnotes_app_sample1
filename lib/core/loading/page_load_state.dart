part of 'page_load_bloc.dart';

final class PageLoadState extends Equatable {
  const PageLoadState({this.phase = LoadingPhase.loading});

  final LoadingPhase phase;

  @override
  List<Object?> get props => [phase];
}
