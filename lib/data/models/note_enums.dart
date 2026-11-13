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
