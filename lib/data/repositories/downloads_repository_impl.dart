import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:investnotes_app_sample1/data/api/api_config.dart';
import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/data/models/article_transfer.dart';
import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/repositories/downloads_repository.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

/// [DownloadsRepository] over the Keel API, keeping each article whole in
/// shared preferences so it reads with no connection.
class DownloadsRepositoryImpl implements DownloadsRepository {
  DownloadsRepositoryImpl({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _key = 'downloads.kept';

  /// Ids only, from before articles came from the API: unreadable offline.
  static const _oldKey = 'downloads.articles';

  @override
  Stream<ArticleTransfer> fetch(String id) async* {
    final http.StreamedResponse response;
    try {
      response = await _client
          .send(
            http.Request(
              'GET',
              ApiConfig.endpoint('articles/${Uri.encodeComponent(id)}'),
            ),
          )
          .timeout(ApiConfig.timeout);
    } catch (_) {
      throw const NotesUnavailable();
    }
    if (response.statusCode != 200) throw const NotesUnavailable();
    yield const ArticleTransfer(0);
    final total = response.contentLength;
    final bytes = <int>[];
    try {
      await for (final chunk in response.stream.timeout(ApiConfig.timeout)) {
        bytes.addAll(chunk);
        if (total != null && total > 0) {
          yield ArticleTransfer((bytes.length / total).clamp(0, 0.99));
        }
      }
      final body = jsonDecode(utf8.decode(bytes)) as Json;
      yield ArticleTransfer(1, Article.fromJson(body['data'] as Json));
    } catch (_) {
      throw const NotesUnavailable();
    }
  }

  @override
  Future<List<Article>> kept() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_oldKey);
    return [
      for (final saved in preferences.getStringList(_key) ?? const <String>[])
        Article.fromJson(jsonDecode(saved) as Json),
    ];
  }

  @override
  Future<void> keep(List<Article> articles) async =>
      (await SharedPreferences.getInstance()).setStringList(_key, [
        for (final a in articles) jsonEncode(a.toJson()),
      ]);
}
