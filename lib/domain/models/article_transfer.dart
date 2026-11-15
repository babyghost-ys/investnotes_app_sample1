import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/article.dart';

/// How far an article's download has come. The last one carries the
/// [article] as it arrived, ready to keep.
class ArticleTransfer extends Equatable {
  const ArticleTransfer(this.received, [this.article]);

  /// From 0 to 1.
  final double received;
  final Article? article;

  @override
  List<Object?> get props => [received, article];
}
