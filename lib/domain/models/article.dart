import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/note_enums.dart';

/// A short read in Education, illustrated by the payoff of [type].
class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.type,
    required this.paragraphs,
    required this.pdf,
  });

  final String id;
  final String title;
  final NoteType type;
  final List<String> paragraphs;

  /// The article as a PDF, the copy a download keeps.
  final Uri pdf;

  @override
  List<Object?> get props => [id];
}
