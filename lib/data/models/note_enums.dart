/// The four families of note Keel offers. Each has its own payoff shape.
enum NoteType {
  mld('MLD', 'Market-linked deposits'),
  ppn('PPN', 'Principal protected notes'),
  par('PAR', 'Buffered notes'),
  auto('Auto', 'Autocallable notes');

  const NoteType(this.code, this.title);

  final String code;
  final String title;
}

enum Currency { usd, eur, gbp }

extension CurrencyCode on Currency {
  String get code => name.toUpperCase();
}

enum Region {
  global('Global', 'globe'),
  americas('Americas', 'globe.americas'),
  europe('Europe', 'globe.europe.africa'),
  asiaPacific('Asia-Pacific', 'globe.asia.australia');

  const Region(this.title, this.symbol);

  final String title;
  final String symbol;
}

enum AssetClass {
  equity('Equity', 'chart.line.uptrend.xyaxis'),
  commodity('Commodity', 'cube'),
  rates('Rates', 'percent'),
  multiAsset('Multi-asset', 'square.stack.3d.up');

  const AssetClass(this.title, this.symbol);

  final String title;
  final String symbol;
}

enum IssuedStatus {
  active('Active', 'waveform.path.ecg'),
  called('Called', 'bell'),
  matured('Matured', 'checkmark.seal');

  const IssuedStatus(this.title, this.symbol);

  final String title;
  final String symbol;
}

/// Who the note is sold to: through an adviser with a commission (A) or in
/// a fee-based account without one (F).
enum ShareClass {
  a('A-class'),
  f('F-class');

  const ShareClass(this.title);

  final String title;
}

/// What the holder is after: payments along the way, growth at maturity,
/// or some of both.
enum NoteGoal {
  income('Income'),
  growth('Growth'),
  both('Income & growth');

  const NoteGoal(this.title);

  final String title;
}

/// How long the money is tied up.
enum TermBand {
  short('Up to 3 yrs'),
  medium('4–5 yrs'),
  long('6+ yrs');

  const TermBand(this.title);

  final String title;

  static TermBand of(int years) => years <= 3
      ? TermBand.short
      : years <= 5
      ? TermBand.medium
      : TermBand.long;
}

/// When the note pays out.
enum Payout {
  maturity('At maturity'),
  annual('Annual'),
  quarterly('Quarterly');

  const Payout(this.title);

  final String title;
}
