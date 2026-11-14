/// The parts of a note's page, each reached from the strip under its name.
enum ProductSection {
  overview('Overview'),
  payoff('Payoff'),
  scenarios('Scenarios'),
  history('History'),
  value('Value'),
  events('Events');

  const ProductSection(this.title);

  final String title;
}
