part of 'shell_bloc.dart';

sealed class ShellEvent extends Equatable {
  const ShellEvent();

  @override
  List<Object?> get props => [];
}

/// A tab was chosen, from the tab bar, the drawer or a shortcut.
final class ShellTabSelected extends ShellEvent {
  const ShellTabSelected(this.tab);

  final ShellTab tab;

  @override
  List<Object?> get props => [tab];
}
