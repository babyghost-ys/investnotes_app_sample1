part of 'downloads_bloc.dart';

final class DownloadsState extends Equatable {
  const DownloadsState({
    this.kept = const [],
    this.files = const {},
    this.progress = const {},
  });

  /// The articles on this device, whole, most recent first.
  final List<Article> kept;

  /// Where each kept article's PDF is on the device.
  final Map<String, String> files;

  /// How far along each download still arriving is, from 0 to 1.
  final Map<String, double> progress;

  bool isKept(String id) => kept.any((a) => a.id == id);

  /// How full an article's download control is: 1 once it is kept, its
  /// progress while it arrives, 0 otherwise.
  double fill(String id) => isKept(id) ? 1 : progress[id] ?? 0;

  DownloadsState copyWith({
    List<Article>? kept,
    Map<String, String>? files,
    Map<String, double>? progress,
  }) => DownloadsState(
    kept: kept ?? this.kept,
    files: files ?? this.files,
    progress: progress ?? this.progress,
  );

  @override
  List<Object?> get props => [kept, files, progress];
}
