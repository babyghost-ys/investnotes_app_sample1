import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:investnotes_app_sample1/data/api/api_config.dart';
import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/data/models/explainer.dart';
import 'package:investnotes_app_sample1/data/models/film.dart';
import 'package:investnotes_app_sample1/data/models/holding.dart';
import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

/// [NotesRepository] over the Keel API. Every answer is `{"data": ...}`;
/// anything else, a network error or a timeout is [NotesUnavailable].
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<Offering>> fetchOfferings() =>
      _get('offerings', (data) => JsonRead.list(data, Offering.fromJson));

  @override
  Future<List<IssuedNote>> fetchIssued() =>
      _get('issued', (data) => JsonRead.list(data, IssuedNote.fromJson));

  @override
  Future<List<Holding>> fetchHoldings() =>
      _get('holdings', (data) => JsonRead.list(data, Holding.fromJson));

  @override
  Future<List<Product>> fetchProducts() =>
      _get('products', (data) => JsonRead.list(data, Product.fromJson));

  @override
  Future<Product> fetchProduct(String id) => _get(
    'products/${Uri.encodeComponent(id)}',
    (data) => Product.fromJson(data as Json),
  );

  @override
  Future<List<Article>> fetchArticles() =>
      _get('articles', (data) => JsonRead.list(data, Article.fromJson));

  @override
  Future<List<Film>> fetchFilms() =>
      _get('films', (data) => JsonRead.list(data, Film.fromJson));

  @override
  Future<List<Explainer>> fetchExplainers() =>
      _get('explainers', (data) => JsonRead.list(data, Explainer.fromJson));

  Future<T> _get<T>(String path, T Function(Object? data) decode) async {
    try {
      final response = await _client
          .get(
            ApiConfig.endpoint(path),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode != 200) throw const NotesUnavailable();
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Json;
      return decode(body['data']);
    } on NotesUnavailable {
      rethrow;
    } catch (_) {
      // Offline, timed out, or an answer in a shape the app cannot read.
      throw const NotesUnavailable();
    }
  }
}
