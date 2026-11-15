import 'package:equatable/equatable.dart';

/// A recorded film in Education, bundled with the app: it plays inline in
/// the Videos list and full screen on its side.
class Film extends Equatable {
  const Film({
    required this.id,
    required this.title,
    required this.asset,
    required this.poster,
  });

  final String id;
  final String title;

  /// The video, as an asset path.
  final String asset;

  /// A still from the film, shown until it plays.
  final String poster;

  @override
  List<Object?> get props => [id];
}
