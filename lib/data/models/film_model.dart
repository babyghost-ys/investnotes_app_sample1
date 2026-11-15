import 'package:investnotes_app_sample1/data/models/json.dart';

/// A film as the API sends it. [asset] and [poster] are app asset paths.
class FilmModel {
  const FilmModel({
    required this.id,
    required this.title,
    required this.asset,
    required this.poster,
  });

  factory FilmModel.fromJson(Json json) => FilmModel(
    id: json['id'] as String,
    title: json['title'] as String,
    asset: json['asset'] as String,
    poster: json['poster'] as String,
  );

  final String id;
  final String title;
  final String asset;
  final String poster;
}
