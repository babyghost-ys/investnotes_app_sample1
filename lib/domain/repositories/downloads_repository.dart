import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/domain/models/article_transfer.dart';

/// Articles kept on this device, as PDFs, to read offline.
abstract interface class DownloadsRepository {
  /// Downloads [article]'s PDF. Reports the share received as it arrives,
  /// and ends with the article once its file is whole on the device.
  /// Fails with `NotesUnavailable`. Cancelling the stream leaves nothing
  /// behind.
  Stream<ArticleTransfer> fetch(Article article);

  /// The articles on this device, most recent first.
  Future<List<Article>> kept();

  Future<void> keep(List<Article> articles);

  /// Deletes [id]'s file from the device.
  Future<void> remove(String id);

  /// Where [id]'s PDF is on the device.
  Future<String> fileOf(String id);
}
