part of 'shell_bloc.dart';

enum ShellTab { home, offerings, issued, learn }

final class ShellState extends Equatable {
  const ShellState({this.tab = ShellTab.home});

  final ShellTab tab;

  @override
  List<Object?> get props => [tab];
}
