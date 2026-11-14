part of 'shell_bloc.dart';

/// The tabs, in bar order. [myNotes] shows only while someone is signed in.
enum ShellTab { home, offerings, issued, learn, myNotes }

final class ShellState extends Equatable {
  const ShellState({this.tab = ShellTab.home});

  final ShellTab tab;

  @override
  List<Object?> get props => [tab];
}
