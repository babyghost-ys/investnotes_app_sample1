part of 'downloads_bloc.dart';

sealed class DownloadsEvent extends Equatable {
  const DownloadsEvent();

  @override
  List<Object?> get props => [];
}

/// Reads what is already on the device.
final class DownloadsStarted extends DownloadsEvent {
  const DownloadsStarted();
}

final class DownloadRequested extends DownloadsEvent {
  const DownloadRequested(this.article);

  final Article article;

  @override
  List<Object?> get props => [article];
}

/// Stops a download still arriving.
final class DownloadCancelled extends DownloadsEvent {
  const DownloadCancelled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Deletes a finished download from the device.
final class DownloadRemoved extends DownloadsEvent {
  const DownloadRemoved(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
