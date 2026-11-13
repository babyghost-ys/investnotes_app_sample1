import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';

/// A short read in Learn, illustrated by the payoff of [type].
class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.type,
    required this.paragraphs,
  });

  final String id;
  final String title;
  final NoteType type;
  final List<String> paragraphs;

  @override
  List<Object?> get props => [id];
}
