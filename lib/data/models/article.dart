import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';

/// A short read in Education, illustrated by the payoff of [type].
class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.type,
    required this.paragraphs,
  });

  factory Article.fromJson(Json json) => Article(
    id: json['id'] as String,
    title: json['title'] as String,
    type: NoteType.values.byName(json['type'] as String),
    paragraphs: JsonRead.strings(json['paragraphs']),
  );

  /// As the API sends it, for keeping a downloaded article on the device.
  Json toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'paragraphs': paragraphs,
  };

  final String id;
  final String title;
  final NoteType type;
  final List<String> paragraphs;

  @override
  List<Object?> get props => [id];
}
