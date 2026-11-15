/// The four families of note Keel offers. Each has its own payoff shape.
///
/// [code] is the family's short name, the same in every language; its full
/// name is in the JSON (see `NoteTypeTerms`).
enum NoteType {
  mld('MLD'),
  ppn('PPN'),
  par('PAR'),
  auto('Auto');

  const NoteType(this.code);

  final String code;
}

enum Currency { usd, eur, gbp }

extension CurrencyCode on Currency {
  String get code => name.toUpperCase();
}

enum Region {
  global('globe'),
  americas('globe.americas'),
  europe('globe.europe.africa'),
  asiaPacific('globe.asia.australia');

  const Region(this.symbol);

  final String symbol;
}

enum AssetClass {
  equity('chart.line.uptrend.xyaxis'),
  commodity('cube'),
  rates('percent'),
  multiAsset('square.stack.3d.up');

  const AssetClass(this.symbol);

  final String symbol;
}

enum IssuedStatus {
  active('waveform.path.ecg'),
  called('bell'),
  matured('checkmark.seal');

  const IssuedStatus(this.symbol);

  final String symbol;
}

/// Who the note is sold to: through an adviser with a commission (A) or in
/// a fee-based account without one (F).
enum ShareClass { a, f }

/// What the holder is after: payments along the way, growth at maturity,
/// or some of both.
enum NoteGoal { income, growth, both }

/// How long the money is tied up.
enum TermBand {
  short,
  medium,
  long;

  static TermBand of(int years) => years <= 3
      ? TermBand.short
      : years <= 5
      ? TermBand.medium
      : TermBand.long;
}

/// When the note pays out.
enum Payout { maturity, annual, quarterly }
