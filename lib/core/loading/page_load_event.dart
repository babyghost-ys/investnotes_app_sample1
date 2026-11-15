part of 'page_load_bloc.dart';

sealed class PageLoadEvent extends Equatable {
  const PageLoadEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the page, from the start: on opening it, and on trying again.
final class PageLoadStarted extends PageLoadEvent {
  const PageLoadStarted();
}
