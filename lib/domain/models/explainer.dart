import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/payoff.dart';

/// A short animated film in Education: one market path played out over a
/// note's term, showing what [payoff] pays as the market moves.
class Explainer extends Equatable {
  const Explainer({
    required this.id,
    required this.title,
    required this.payoff,
    required this.path,
  });

  final String id;
  final String title;
  final Payoff payoff;

  /// The underlying's move from its start, as fractions, sampled evenly
  /// from issue to maturity. Starts at 0.
  final List<double> path;

  /// The move at [t], from 0 (issue) to 1 (maturity), between samples.
  double moveAt(double t) {
    final x = t.clamp(0.0, 1.0) * (path.length - 1);
    final i = x.floor();
    if (i >= path.length - 1) return path.last;
    return path[i] + (path[i + 1] - path[i]) * (x - i);
  }

  @override
  List<Object?> get props => [id];
}
