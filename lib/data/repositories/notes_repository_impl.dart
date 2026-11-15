import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:investnotes_app_sample1/data/api/api_config.dart';
import 'package:investnotes_app_sample1/data/mappers/notes_mapper.dart';
import 'package:investnotes_app_sample1/data/models/article_model.dart';
import 'package:investnotes_app_sample1/data/models/explainer_model.dart';
import 'package:investnotes_app_sample1/data/models/film_model.dart';
import 'package:investnotes_app_sample1/data/models/holding_model.dart';
import 'package:investnotes_app_sample1/data/models/issued_note_model.dart';
import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/offering_model.dart';
import 'package:investnotes_app_sample1/data/models/product_model.dart';
import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/domain/models/explainer.dart';
import 'package:investnotes_app_sample1/domain/models/film.dart';
import 'package:investnotes_app_sample1/domain/models/holding.dart';
import 'package:investnotes_app_sample1/domain/models/issued_note.dart';
import 'package:investnotes_app_sample1/domain/models/offering.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';
import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';

/// [NotesRepository] over the Keel API. Every answer is `{"data": ...}`,
/// read into the data models and mapped to the domain; anything else, a
/// network error or a timeout is [NotesUnavailable].
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<Offering>> fetchOfferings() => _get(
    'offerings',
    (data) => [
      for (final m in JsonRead.list(data, OfferingModel.fromJson)) m.toDomain(),
    ],
  );

  @override
  Future<List<IssuedNote>> fetchIssued() => _get(
    'issued',
    (data) => [
      for (final m in JsonRead.list(data, IssuedNoteModel.fromJson))
        m.toDomain(),
    ],
  );

  @override
  Future<List<Holding>> fetchHoldings() => _get(
    'holdings',
    (data) => [
      for (final m in JsonRead.list(data, HoldingModel.fromJson)) m.toDomain(),
    ],
  );

  @override
  Future<List<Product>> fetchProducts() => _get(
    'products',
    (data) => [
      for (final m in JsonRead.list(data, ProductModel.fromJson)) m.toDomain(),
    ],
  );

  @override
  Future<Product> fetchProduct(String id) => _get(
    'products/${Uri.encodeComponent(id)}',
    (data) => ProductModel.fromJson(JsonRead.object(data)).toDomain(),
  );

  @override
  Future<List<Article>> fetchArticles() => _get(
    'articles',
    (data) => [
      for (final m in JsonRead.list(data, ArticleModel.fromJson)) m.toDomain(),
    ],
  );

  @override
  Future<List<Film>> fetchFilms() => _get(
    'films',
    (data) => [
      for (final m in JsonRead.list(data, FilmModel.fromJson)) m.toDomain(),
    ],
  );

  @override
  Future<List<Explainer>> fetchExplainers() => _get(
    'explainers',
    (data) => [
      for (final m in JsonRead.list(data, ExplainerModel.fromJson))
        m.toDomain(),
    ],
  );

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
