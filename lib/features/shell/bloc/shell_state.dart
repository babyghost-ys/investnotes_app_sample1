part of 'shell_bloc.dart';

/// The tabs, in bar order. [myNotes] shows only while someone is signed in,
/// right after [home].
enum ShellTab {
  home,
  myNotes,
  offerings,
  issued,
  education;

  /// The tabs in the bar, in order, for whether someone is signed in.
  static List<ShellTab> shown({required bool signedIn}) => [
    for (final tab in values)
      if (tab != myNotes || signedIn) tab,
  ];
}

final class ShellState extends Equatable {
  const ShellState({this.tab = ShellTab.home});

  final ShellTab tab;

  @override
  List<Object?> get props => [tab];
}
