import 'package:investnotes_app_sample1/data/models/article_model.dart';
import 'package:investnotes_app_sample1/data/models/explainer_model.dart';
import 'package:investnotes_app_sample1/data/models/film_model.dart';
import 'package:investnotes_app_sample1/data/models/holding_model.dart';
import 'package:investnotes_app_sample1/data/models/issued_note_model.dart';
import 'package:investnotes_app_sample1/data/models/json.dart';
import 'package:investnotes_app_sample1/data/models/offering_model.dart';
import 'package:investnotes_app_sample1/data/models/payoff_model.dart';
import 'package:investnotes_app_sample1/data/models/product_model.dart';
import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/domain/models/explainer.dart';
import 'package:investnotes_app_sample1/domain/models/film.dart';
import 'package:investnotes_app_sample1/domain/models/holding.dart';
import 'package:investnotes_app_sample1/domain/models/issued_note.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/offering.dart';
import 'package:investnotes_app_sample1/domain/models/payoff.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';

// The one place data models turn into domain models and back. Enums
// travel by their Dart name; dates are UTC instants, shown in the device's
// time zone.

DateTime _date(String value) => DateTime.parse(value).toLocal();

DateTime? _dateOrNull(String? value) => value == null ? null : _date(value);

String _iso(DateTime date) => date.toUtc().toIso8601String();

extension PayoffModelMapper on PayoffModel {
  Payoff toDomain() => Payoff(
    type: NoteType.values.byName(type),
    participation: participation,
    cap: cap,
    buffer: buffer,
    coupon: coupon,
    barrier: barrier,
  );
}

extension PayoffMapper on Payoff {
  PayoffModel toModel() => PayoffModel(
    type: type.name,
    participation: participation,
    cap: cap,
    buffer: buffer,
    coupon: coupon,
    barrier: barrier,
  );
}

extension OfferingModelMapper on OfferingModel {
  Offering toDomain() => Offering(
    id: id,
    name: name,
    underlying: underlying,
    payoff: payoff.toDomain(),
    currency: Currency.values.byName(currency),
    region: Region.values.byName(region),
    assetClass: AssetClass.values.byName(assetClass),
    termYears: termYears,
    closes: _date(closes),
    shareClass: ShareClass.values.byName(shareClass),
    goal: NoteGoal.values.byName(goal),
    payout: Payout.values.byName(payout),
  );
}

extension OfferingMapper on Offering {
  OfferingModel toModel() => OfferingModel(
    id: id,
    name: name,
    underlying: underlying,
    payoff: payoff.toModel(),
    currency: currency.name,
    region: region.name,
    assetClass: assetClass.name,
    termYears: termYears,
    closes: _iso(closes),
    shareClass: shareClass.name,
    goal: goal.name,
    payout: payout.name,
  );
}

extension IssuedNoteModelMapper on IssuedNoteModel {
  IssuedNote toDomain() => IssuedNote(
    id: id,
    name: name,
    type: NoteType.values.byName(type),
    currency: Currency.values.byName(currency),
    status: IssuedStatus.values.byName(status),
    issued: _date(issued),
    matures: _date(matures),
    history: history,
  );
}

extension IssuedNoteMapper on IssuedNote {
  IssuedNoteModel toModel() => IssuedNoteModel(
    id: id,
    name: name,
    type: type.name,
    currency: currency.name,
    status: status.name,
    issued: _iso(issued),
    matures: _iso(matures),
    history: history,
  );
}

extension HoldingModelMapper on HoldingModel {
  Holding toDomain() => Holding(note: note.toDomain(), principal: principal);
}

extension ProductModelMapper on ProductModel {
  Product toDomain() => Product(
    id: id,
    name: name,
    underlying: underlying,
    payoff: payoff.toDomain(),
    currency: Currency.values.byName(currency),
    region: Region.values.byName(region),
    assetClass: AssetClass.values.byName(assetClass),
    fundserv: fundserv,
    issueDate: _date(issueDate),
    maturity: _date(maturity),
    closes: _dateOrNull(closes),
    status: switch (status) {
      final String status => IssuedStatus.values.byName(status),
      null => null,
    },
    calledOn: _dateOrNull(calledOn),
    history: history,
  );
}

extension ArticleModelMapper on ArticleModel {
  Article toDomain() => Article(
    id: id,
    title: title,
    type: NoteType.values.byName(type),
    paragraphs: paragraphs,
    pdf: Uri.parse(pdf),
  );
}

extension ArticleMapper on Article {
  ArticleModel toModel() => ArticleModel(
    id: id,
    title: title,
    type: type.name,
    paragraphs: paragraphs,
    pdf: pdf.toString(),
  );
}

extension FilmModelMapper on FilmModel {
  Film toDomain() => Film(id: id, title: title, asset: asset, poster: poster);
}

extension ExplainerModelMapper on ExplainerModel {
  Explainer toDomain() =>
      Explainer(id: id, title: title, payoff: payoff.toDomain(), path: path);
}

/// Domain lists as plain JSON values and back, for crossing into a native
/// sheet's own engine, which cannot share the app's objects.
abstract final class NotesJson {
  static List<Json> fromOfferings(List<Offering> offerings) => [
    for (final o in offerings) o.toModel().toJson(),
  ];

  static List<Offering> toOfferings(Object? json) => [
    for (final m in JsonRead.list(json, OfferingModel.fromJson)) m.toDomain(),
  ];

  static List<Json> fromIssued(List<IssuedNote> notes) => [
    for (final n in notes) n.toModel().toJson(),
  ];

  static List<IssuedNote> toIssued(Object? json) => [
    for (final m in JsonRead.list(json, IssuedNoteModel.fromJson)) m.toDomain(),
  ];
}
