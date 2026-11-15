import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/data/models/article_transfer.dart';

/// Articles kept on this device to read offline.
abstract interface class DownloadsRepository {
  /// Downloads [id]. Reports the share received as it arrives, and ends
  /// with the article itself. Fails with `NotesUnavailable`.
  Stream<ArticleTransfer> fetch(String id);

  /// The articles on this device, most recent first.
  Future<List<Article>> kept();

  Future<void> keep(List<Article> articles);
}
