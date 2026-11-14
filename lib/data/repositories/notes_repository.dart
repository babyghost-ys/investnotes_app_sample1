import 'dart:math' as math;

import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/payoff.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';

/// Sample notes, held in memory. Dates are relative to today, so the
/// offerings stay open whenever the app runs.
class NotesRepository {
  NotesRepository({DateTime? now}) : _now = now ?? DateTime.now();

  final DateTime _now;

  DateTime _in(int days) => _now.add(Duration(days: days));
  DateTime _ago(int days) => _now.subtract(Duration(days: days));

  late final List<Offering> offerings = [
    // Market-linked deposits: full principal back, capped upside.
    _o(
      'mld-1',
      'Global Leaders Deposit 2029',
      'Global Leaders 30 Index',
      const Payoff(type: NoteType.mld, cap: 0.24),
      Currency.usd,
      Region.global,
      AssetClass.equity,
      3,
      4,
    ),
    _o(
      'mld-2',
      'Euro Dividend Deposit 2030',
      'Euro Dividend 50 Index',
      const Payoff(type: NoteType.mld, cap: 0.30),
      Currency.eur,
      Region.europe,
      AssetClass.equity,
      4,
      11,
    ),
    _o(
      'mld-3',
      'Balanced Growth Deposit 2031',
      'Keel Balanced Basket',
      const Payoff(type: NoteType.mld, participation: 0.8, cap: 0.36),
      Currency.gbp,
      Region.global,
      AssetClass.multiAsset,
      5,
      19,
    ),
    _o(
      'mld-4',
      'Rate Ladder Deposit 2028',
      'Five-year Swap Rate',
      const Payoff(type: NoteType.mld, cap: 0.14),
      Currency.usd,
      Region.americas,
      AssetClass.rates,
      2,
      26,
    ),
    // Principal protected notes: protected, higher participation.
    _o(
      'ppn-1',
      'Tech Innovators Protected 2031',
      'Innovators 100 Index',
      const Payoff(type: NoteType.ppn, participation: 1.2, cap: 0.45),
      Currency.usd,
      Region.americas,
      AssetClass.equity,
      5,
      2,
    ),
    _o(
      'ppn-2',
      'Asia Consumer Protected 2030',
      'Asia Consumer Basket',
      const Payoff(type: NoteType.ppn, participation: 1.4),
      Currency.usd,
      Region.asiaPacific,
      AssetClass.equity,
      4,
      9,
    ),
    _o(
      'ppn-3',
      'Gold Reserve Protected 2029',
      'Gold Spot',
      const Payoff(type: NoteType.ppn, participation: 0.9, cap: 0.28),
      Currency.gbp,
      Region.global,
      AssetClass.commodity,
      3,
      15,
    ),
    _o(
      'ppn-4',
      'Clean Power Protected 2032',
      'Clean Power 40 Index',
      const Payoff(type: NoteType.ppn, participation: 1.5, cap: 0.6),
      Currency.eur,
      Region.europe,
      AssetClass.equity,
      6,
      33,
    ),
    // Buffered notes: principal at risk past the buffer, boosted upside.
    _o(
      'par-1',
      'World Banks Buffered 2030',
      'World Banks Index',
      const Payoff(
        type: NoteType.par,
        participation: 1.5,
        cap: 0.5,
        buffer: 0.15,
      ),
      Currency.usd,
      Region.global,
      AssetClass.equity,
      4,
      3,
    ),
    _o(
      'par-2',
      'Energy Majors Buffered 2029',
      'Energy Majors Basket',
      const Payoff(type: NoteType.par, participation: 2, cap: 0.4, buffer: 0.1),
      Currency.gbp,
      Region.europe,
      AssetClass.commodity,
      3,
      8,
    ),
    _o(
      'par-3',
      'Pacific Growth Buffered 2031',
      'Pacific Growth Index',
      const Payoff(type: NoteType.par, participation: 1.25, buffer: 0.25),
      Currency.usd,
      Region.asiaPacific,
      AssetClass.equity,
      5,
      17,
    ),
    _o(
      'par-4',
      'Real Assets Buffered 2030',
      'Real Assets Basket',
      const Payoff(
        type: NoteType.par,
        participation: 1.3,
        cap: 0.42,
        buffer: 0.2,
      ),
      Currency.eur,
      Region.global,
      AssetClass.multiAsset,
      4,
      24,
    ),
    // Autocallables: a fixed coupon above the barrier.
    _o(
      'auto-1',
      'Global Brands Income 2030',
      'Global Brands 20 Index',
      const Payoff(type: NoteType.auto, coupon: 0.32, barrier: -0.3),
      Currency.usd,
      Region.global,
      AssetClass.equity,
      4,
      5,
    ),
    _o(
      'auto-2',
      'Euro Telecom Income 2029',
      'Euro Telecom Basket',
      const Payoff(type: NoteType.auto, coupon: 0.27, barrier: -0.35),
      Currency.eur,
      Region.europe,
      AssetClass.equity,
      3,
      12,
    ),
    _o(
      'auto-3',
      'US Healthcare Income 2031',
      'US Healthcare Index',
      const Payoff(type: NoteType.auto, coupon: 0.4, barrier: -0.25),
      Currency.usd,
      Region.americas,
      AssetClass.equity,
      5,
      21,
    ),
    _o(
      'auto-4',
      'Oil & Metals Income 2029',
      'Oil & Metals Basket',
      const Payoff(type: NoteType.auto, coupon: 0.36, barrier: -0.4),
      Currency.gbp,
      Region.global,
      AssetClass.commodity,
      3,
      29,
    ),
  ];

  Offering _o(
    String id,
    String name,
    String underlying,
    Payoff payoff,
    Currency currency,
    Region region,
    AssetClass assetClass,
    int term,
    int closesInDays,
  ) => Offering(
    payout: switch (payoff.type) {
      NoteType.auto =>
        int.parse(id.split('-').last).isOdd ? Payout.quarterly : Payout.annual,
      NoteType.par => Payout.annual,
      _ => Payout.maturity,
    },
    shareClass: int.parse(id.split("-").last).isOdd
        ? ShareClass.a
        : ShareClass.f,
    goal: switch (payoff.type) {
      NoteType.auto => NoteGoal.income,
      NoteType.mld => closesInDays.isEven ? NoteGoal.both : NoteGoal.growth,
      _ => term >= 5 ? NoteGoal.growth : NoteGoal.both,
    },
    id: id,
    name: name,
    underlying: underlying,
    payoff: payoff,
    currency: currency,
    region: region,
    assetClass: assetClass,
    termYears: term,
    closes: _in(closesInDays),
  );

  late final List<IssuedNote> issued = [
    _i(
      'i-01',
      'Global Leaders Deposit 2028',
      NoteType.mld,
      Currency.usd,
      IssuedStatus.active,
      210,
      3,
      0.11,
    ),
    _i(
      'i-02',
      'Tech Innovators Protected 2029',
      NoteType.ppn,
      Currency.usd,
      IssuedStatus.active,
      420,
      4,
      0.19,
    ),
    _i(
      'i-03',
      'World Banks Buffered 2028',
      NoteType.par,
      Currency.usd,
      IssuedStatus.active,
      300,
      3,
      -0.06,
    ),
    _i(
      'i-04',
      'Euro Telecom Income 2027',
      NoteType.auto,
      Currency.eur,
      IssuedStatus.called,
      640,
      3,
      0.09,
    ),
    _i(
      'i-05',
      'Gold Reserve Protected 2027',
      NoteType.ppn,
      Currency.gbp,
      IssuedStatus.active,
      520,
      3,
      0.14,
    ),
    _i(
      'i-06',
      'Pacific Growth Buffered 2026',
      NoteType.par,
      Currency.usd,
      IssuedStatus.matured,
      1460,
      4,
      0.22,
    ),
    _i(
      'i-07',
      'Euro Dividend Deposit 2026',
      NoteType.mld,
      Currency.eur,
      IssuedStatus.matured,
      1825,
      5,
      0.08,
    ),
    _i(
      'i-08',
      'Global Brands Income 2027',
      NoteType.auto,
      Currency.usd,
      IssuedStatus.called,
      400,
      4,
      0.08,
    ),
    _i(
      'i-09',
      'Energy Majors Buffered 2027',
      NoteType.par,
      Currency.gbp,
      IssuedStatus.active,
      160,
      3,
      -0.11,
    ),
    _i(
      'i-10',
      'Clean Power Protected 2029',
      NoteType.ppn,
      Currency.eur,
      IssuedStatus.active,
      90,
      5,
      0.03,
    ),
    _i(
      'i-11',
      'Balanced Growth Deposit 2025',
      NoteType.mld,
      Currency.gbp,
      IssuedStatus.matured,
      2200,
      5,
      0.17,
    ),
    _i(
      'i-12',
      'US Healthcare Income 2028',
      NoteType.auto,
      Currency.usd,
      IssuedStatus.active,
      250,
      4,
      0.02,
    ),
    _i(
      'i-13',
      'Asia Consumer Protected 2025',
      NoteType.ppn,
      Currency.usd,
      IssuedStatus.matured,
      1650,
      4,
      0.26,
    ),
    _i(
      'i-14',
      'Real Assets Buffered 2029',
      NoteType.par,
      Currency.eur,
      IssuedStatus.active,
      45,
      4,
      0.01,
    ),
  ];

  IssuedNote _i(
    String id,
    String name,
    NoteType type,
    Currency currency,
    IssuedStatus status,
    int issuedDaysAgo,
    int term,
    double change,
  ) {
    final issued = _ago(issuedDaysAgo);
    return IssuedNote(
      id: id,
      name: name,
      type: type,
      currency: currency,
      status: status,
      issued: issued,
      matures: DateTime(issued.year + term, issued.month, issued.day),
      history: _walk(id.hashCode, change, type),
    );
  }

  /// An offering as its page shows it. It issues a week after subscription
  /// closes and matures on the anniversary of its term.
  Product productOf(Offering o) {
    final issue = o.closes.add(const Duration(days: 7));
    return Product(
      id: o.id,
      name: o.name,
      underlying: o.underlying,
      payoff: o.payoff,
      currency: o.currency,
      region: o.region,
      assetClass: o.assetClass,
      fundserv: 'KEL${2104 + offerings.indexOf(o) * 7}',
      issueDate: issue,
      maturity: DateTime(issue.year + o.termYears, issue.month, issue.day),
      closes: o.closes,
    );
  }

  /// An issued note as its page shows it, with the terms of the series it
  /// belongs to: the open offering of the same name.
  Product productOfIssued(IssuedNote n) {
    final series = _series(n.name);
    final called = n.status == IssuedStatus.called
        ? _lastAnniversary(n.issued)
        : null;
    return Product(
      id: n.id,
      name: n.name,
      underlying: series.underlying,
      payoff: series.payoff,
      currency: n.currency,
      region: series.region,
      assetClass: series.assetClass,
      fundserv: 'KEL${1403 + issued.indexOf(n) * 11}',
      issueDate: n.issued,
      maturity: n.matures,
      status: n.status,
      calledOn: called,
      history: n.history,
    );
  }

  Product? productById(String id) {
    for (final o in offerings) {
      if (o.id == id) return productOf(o);
    }
    for (final n in issued) {
      if (n.id == id) return productOfIssued(n);
    }
    return null;
  }

  Offering _series(String name) {
    String stem(String s) => s.replaceAll(RegExp(r'\s+\d{4}$'), '');
    return offerings.firstWhere((o) => stem(o.name) == stem(name));
  }

  DateTime _lastAnniversary(DateTime issued) {
    var date = DateTime(issued.year + 1, issued.month, issued.day);
    while (DateTime(date.year + 1, date.month, date.day).isBefore(_now)) {
      date = DateTime(date.year + 1, date.month, date.day);
    }
    return date;
  }

  /// A plausible, repeatable value path from 1.0 to 1 + [change]. Protected
  /// notes never print below par.
  List<double> _walk(int seed, double change, NoteType type) {
    final random = math.Random(seed);
    const points = 40;
    final floor = type == NoteType.mld || type == NoteType.ppn ? 1.0 : 0.0;
    var noise = 0.0;
    return [
      for (var i = 0; i < points; i++)
        () {
          final t = i / (points - 1);
          noise = noise * 0.85 + (random.nextDouble() - 0.5) * 0.008;
          final edge = i == 0 || i == points - 1 ? 0.0 : noise;
          return math.max(floor, 1 + change * t + edge);
        }(),
    ];
  }

  late final List<Article> articles = const [
    Article(
      id: 'a-floor',
      title: 'What a principal floor really costs',
      type: NoteType.ppn,
      paragraphs: [
        'A protected note returns your principal at maturity whatever the '
            'market does. That promise is paid for with part of the upside.',
        'The issuer sets aside most of your money in a bond that grows back '
            'to the full amount by maturity. The rest buys options on the '
            'underlying, and those options decide how much of any rise you '
            'keep.',
        'Lower interest rates leave less for options, so participation '
            'falls or caps tighten. Compare the cap and participation of two '
            'notes on the same underlying before you choose.',
        'The floor holds only at maturity. Sell early and you receive the '
            'market price on the day, which can be below what you paid.',
      ],
    ),
    Article(
      id: 'a-buffer',
      title: 'Buffers, not floors',
      type: NoteType.par,
      paragraphs: [
        'A buffered note absorbs the first part of a fall. With a 15% '
            'buffer, a 10% drop costs you nothing; a 30% drop costs you 15%.',
        'In exchange you usually get boosted upside: one and a half or two '
            'times the rise, up to a cap.',
        'Buffers suit a view that markets will be flat to moderately higher, '
            'with a deep fall unlikely over the term.',
      ],
    ),
    Article(
      id: 'a-autocall',
      title: 'How an autocall can end early',
      type: NoteType.auto,
      paragraphs: [
        'An autocallable note checks the underlying on set dates. If it is '
            'at or above its starting level, the note ends and pays its '
            'coupon for the time elapsed.',
        'If it never calls, the barrier decides the outcome at maturity: '
            'above it you receive the full coupon, below it you share the '
            'loss one for one.',
        'Early calls return cash sooner than planned, so think about where '
            'you would reinvest it.',
      ],
    ),
    Article(
      id: 'a-deposit',
      title: 'Market-linked deposits in plain terms',
      type: NoteType.mld,
      paragraphs: [
        'A market-linked deposit is a term deposit whose interest follows '
            'an index instead of a fixed rate.',
        'If the index rises you earn a share of the rise up to a cap; if it '
            'falls you earn nothing, but your deposit is returned in full.',
        'Interest is usually paid only at maturity, and early withdrawal is '
            'limited, so match the term to when you need the money.',
      ],
    ),
  ];
}
