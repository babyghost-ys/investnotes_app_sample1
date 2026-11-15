import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/note_enums.dart';

/// What a note pays at maturity for a given move in its underlying.
///
/// All values are fractions: a [protection] of 1 keeps all principal, a
/// [buffer] of 0.15 absorbs the first 15% of losses, a [cap] of 0.4 limits
/// the gain to 40%.
class Payoff extends Equatable {
  const Payoff({
    required this.type,
    this.participation = 1,
    this.cap,
    this.buffer = 0,
    this.coupon = 0,
    this.barrier = 0,
  });

  final NoteType type;
  final double participation;
  final double? cap;
  final double buffer;

  /// Autocallable: the coupon paid over the whole term when the underlying
  /// ends above [barrier] (a negative fraction, e.g. -0.3).
  final double coupon;
  final double barrier;

  /// Return to the holder when the underlying moves by [move].
  double at(double move) {
    switch (type) {
      case NoteType.mld:
      case NoteType.ppn:
        return _capped(math.max(0, participation * move));
      case NoteType.par:
        if (move >= 0) return _capped(participation * move);
        return move > -buffer ? 0 : move + buffer;
      case NoteType.auto:
        return move >= barrier ? coupon : move;
    }
  }

  double _capped(double value) => cap == null ? value : math.min(cap!, value);

  /// The worst the holder can do inside the drawn range.
  bool get protectsPrincipal => type == NoteType.mld || type == NoteType.ppn;

  @override
  List<Object?> get props => [
    type,
    participation,
    cap,
    buffer,
    coupon,
    barrier,
  ];
}
