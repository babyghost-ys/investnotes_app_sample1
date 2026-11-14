import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/note_event.dart';
import 'package:investnotes_app_sample1/data/models/payoff.dart';
import 'package:investnotes_app_sample1/data/models/product_section.dart';

/// A note as its page shows it: an offering still open for subscription,
/// or a note already issued, with its value since.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.underlying,
    required this.payoff,
    required this.currency,
    required this.region,
    required this.assetClass,
    required this.fundserv,
    required this.issueDate,
    required this.maturity,
    this.closes,
    this.status,
    this.calledOn,
    this.history = const [],
  });

  final String id;
  final String name;
  final String underlying;
  final Payoff payoff;
  final Currency currency;
  final Region region;
  final AssetClass assetClass;

  /// The order code advisers enter to buy the note.
  final String fundserv;
  final DateTime issueDate;
  final DateTime maturity;

  /// When subscription closes; only an offering has one.
  final DateTime? closes;

  /// How an issued note stands; null for an offering.
  final IssuedStatus? status;

  /// When an autocallable was called early.
  final DateTime? calledOn;

  /// Indicative value as a fraction of principal, oldest first.
  final List<double> history;

  NoteType get type => payoff.type;

  bool get isOffering => status == null;

  int get termYears => maturity.year - issueDate.year;

  /// Latest indicative value, per 100 of principal.
  double? get price => history.isEmpty ? null : history.last * 100;

  /// Return since issue, from the latest value.
  double get change => history.isEmpty ? 0 : history.last - 1;

  /// What the page offers: an offering has no value to follow yet.
  List<ProductSection> get sections => [
    ProductSection.overview,
    ProductSection.payoff,
    ProductSection.scenarios,
    if (!isOffering) ...[ProductSection.history, ProductSection.value],
    ProductSection.events,
  ];

  /// Every dated step in the note's life, in order. A called note ends on
  /// the day it was called.
  List<NoteEvent> get events {
    final end = calledOn ?? maturity;
    return [
      if (closes != null) NoteEvent(NoteEventKind.closes, closes!),
      NoteEvent(NoteEventKind.issued, issueDate),
      if (type == NoteType.auto)
        for (var year = 1; year < termYears; year++)
          if (!_anniversary(year).isAfter(end) &&
              _anniversary(year) != calledOn)
            NoteEvent(NoteEventKind.callCheck, _anniversary(year)),
      if (calledOn != null)
        NoteEvent(NoteEventKind.called, calledOn!)
      else
        NoteEvent(NoteEventKind.matures, maturity),
    ];
  }

  DateTime _anniversary(int year) =>
      DateTime(issueDate.year + year, issueDate.month, issueDate.day);

  @override
  List<Object?> get props => [id];
}
