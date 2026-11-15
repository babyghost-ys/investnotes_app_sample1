import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:investnotes_app_sample1/data/api/api_config.dart';
import 'package:investnotes_app_sample1/data/mappers/notes_mapper.dart';
import 'package:investnotes_app_sample1/data/models/article_model.dart';
import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/domain/models/article_transfer.dart';
import 'package:investnotes_app_sample1/domain/repositories/downloads_repository.dart';
import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';

/// [DownloadsRepository] that streams each article's PDF from the CDN into
/// the app's support folder, and lists what it keeps in shared preferences.
class DownloadsRepositoryImpl implements DownloadsRepository {
  DownloadsRepositoryImpl({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// The articles kept, each with its PDF.
  static const _key = 'downloads.pdfs';

  /// Earlier lists: articles kept as text, with no file. Dropped.
  static const _oldKeys = ['downloads.kept', 'downloads.articles'];

  Future<Directory> _folder() async {
    final folder = Directory(
      '${(await getApplicationSupportDirectory()).path}/downloads',
    );
    await folder.create(recursive: true);
    return folder;
  }

  @override
  Future<String> fileOf(String id) async => '${(await _folder()).path}/$id.pdf';

  @override
  Stream<ArticleTransfer> fetch(Article article) async* {
    final http.StreamedResponse response;
    try {
      response = await _client
          .send(http.Request('GET', article.pdf))
          .timeout(ApiConfig.timeout);
    } catch (_) {
      throw const NotesUnavailable();
    }
    if (response.statusCode != 200) throw const NotesUnavailable();
    yield const ArticleTransfer(0);

    final path = await fileOf(article.id);
    // Arrives beside its final place, and takes it only once whole: a
    // stopped or broken download never passes for a kept one.
    final part = File('$path.part');
    final sink = part.openWrite();
    var whole = false;
    try {
      final total = response.contentLength;
      var received = 0;
      var reported = 0.0;
      await for (final chunk in response.stream.timeout(ApiConfig.timeout)) {
        sink.add(chunk);
        received += chunk.length;
        if (total != null && total > 0) {
          final share = (received / total).clamp(0.0, 0.99);
          // A step each percent: smooth enough, without a state per chunk.
          if (share - reported >= 0.01) {
            reported = share;
            yield ArticleTransfer(share);
          }
        }
      }
      await sink.flush();
      await sink.close();
      if (total != null && received != total) throw const NotesUnavailable();
      await part.rename(path);
      whole = true;
    } catch (_) {
      throw const NotesUnavailable();
    } finally {
      // Runs too when the listener cancels.
      if (!whole) {
        await sink.close().catchError((_) {});
        if (await part.exists()) await part.delete();
      }
    }
    yield ArticleTransfer(1, article);
  }

  @override
  Future<List<Article>> kept() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in _oldKeys) {
      await preferences.remove(key);
    }
    final articles = [
      for (final saved in preferences.getStringList(_key) ?? const <String>[])
        ArticleModel.fromJson(jsonDecode(saved) as Json).toDomain(),
    ];
    // Only those whose file is still there.
    return [
      for (final a in articles)
        if (await File(await fileOf(a.id)).exists()) a,
    ];
  }

  @override
  Future<void> keep(List<Article> articles) async =>
      (await SharedPreferences.getInstance()).setStringList(_key, [
        for (final a in articles) jsonEncode(a.toModel().toJson()),
      ]);

  @override
  Future<void> remove(String id) async {
    final file = File(await fileOf(id));
    if (await file.exists()) await file.delete();
  }
}
