part of 'downloads_bloc.dart';

final class DownloadsState extends Equatable {
  const DownloadsState({this.kept = const [], this.progress = const {}});

  /// The ids of the articles on this device, most recent first.
  final List<String> kept;

  /// How far along each download still arriving is, from 0 to 1.
  final Map<String, double> progress;

  bool isKept(String id) => kept.contains(id);

  /// How full an article's download control is: 1 once it is kept, its
  /// progress while it arrives, 0 otherwise.
  double fill(String id) => isKept(id) ? 1 : progress[id] ?? 0;

  /// [all]'s articles that are on this device, most recent first.
  List<Article> keptOf(List<Article> all) => [
    for (final id in kept) ...all.where((a) => a.id == id),
  ];

  DownloadsState copyWith({
    List<String>? kept,
    Map<String, double>? progress,
  }) => DownloadsState(
    kept: kept ?? this.kept,
    progress: progress ?? this.progress,
  );

  @override
  List<Object?> get props => [kept, progress];
}
