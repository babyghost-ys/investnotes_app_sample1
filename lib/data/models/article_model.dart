import 'package:investnotes_app_sample1/data/models/json.dart';

/// An article as the API sends it, and as a download keeps it.
class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.type,
    required this.paragraphs,
    required this.pdf,
  });

  factory ArticleModel.fromJson(Json json) => ArticleModel(
    id: json['id'] as String,
    title: json['title'] as String,
    type: json['type'] as String,
    paragraphs: JsonRead.strings(json['paragraphs']),
    pdf: json['pdf'] as String,
  );

  final String id;
  final String title;
  final String type;
  final List<String> paragraphs;
  final String pdf;

  Json toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'paragraphs': paragraphs,
    'pdf': pdf,
  };
}
