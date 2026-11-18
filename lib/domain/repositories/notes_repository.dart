import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/domain/models/explainer.dart';
import 'package:investnotes_app_sample1/domain/models/film.dart';
import 'package:investnotes_app_sample1/domain/models/holding.dart';
import 'package:investnotes_app_sample1/domain/models/issued_note.dart';
import 'package:investnotes_app_sample1/domain/models/offering.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';

/// The notes, the investor's holdings and Education's content. Every call
/// fails with [NotesUnavailable] when the service cannot hand them over.
abstract interface class NotesRepository {
  /// The notes open for subscription.
  Future<List<Offering>> fetchOfferings();

  /// The notes already issued.
  Future<List<IssuedNote>> fetchIssued();

  /// The signed-in investor's notes.
  Future<List<Holding>> fetchHoldings();

  /// Every note's page, open and issued.
  Future<List<Product>> fetchProducts();

  /// One note's page, open or issued.
  Future<Product> fetchProduct(String id);

  /// The note's page as last fetched in this session, if it has been: a
  /// note that moves from one place on screen to another (a Duo unfolding)
  /// shows at once instead of loading again.
  Product? fetchedProduct(String id);

  Future<List<Article>> fetchArticles();

  Future<List<Film>> fetchFilms();

  Future<List<Explainer>> fetchExplainers();
}

/// The service could not be reached, or did not answer as expected.
class NotesUnavailable implements Exception {
  const NotesUnavailable();
}
