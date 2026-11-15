import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

/// Figures as VoiceOver and TalkBack should say them: with what they mean,
/// where the screen shows only the number.
abstract final class Spoken {
  /// The figure an offering is compared by, with its meaning: "capped at
  /// 24%", "coupon 9%", "1.5 times participation".
  static String headline(Offering o) {
    if (o.type == NoteType.auto) return 'coupon ${Formats.percent(o.headline)}';
    if (o.headlineIsRate) return 'capped at ${Formats.percent(o.headline)}';
    return '${o.headline.toStringAsFixed(o.headline % 1 == 0 ? 0 : 1)} times participation';
  }

  /// When an offering closes: "closes today", "closes in 3 days", "closes
  /// 12 Mar".
  static String closes(DateTime date) {
    final when = Formats.until(date);
    return switch (when) {
      'Today' => 'closes today',
      'Tomorrow' => 'closes tomorrow',
      _ when when.startsWith('In ') => 'closes in ${when.substring(3)}',
      _ => 'closes $when',
    };
  }

  /// A return since issue: "up 4.1% since issue", "down 6% since issue".
  static String change(double value) {
    final size = Formats.percent(value.abs());
    if (value == 0) return 'unchanged since issue';
    return '${value > 0 ? 'up' : 'down'} $size since issue';
  }
}
