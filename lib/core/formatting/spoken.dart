import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/offering.dart';

/// Figures as VoiceOver and TalkBack should say them: with what they mean,
/// where the screen shows only the number. In the language of [general].
class Spoken {
  const Spoken(this.general);

  final GeneralLocale general;

  GeneralSemantics get _words => general.semantics;
  Formats get _formats => Formats(general);

  /// The figure an offering is compared by, with its meaning: "capped at
  /// 24%", "coupon 9%", "1.5 times participation".
  String headline(Offering o) {
    if (o.type == NoteType.auto) {
      return _words.coupon(value: _formats.percent(o.headline));
    }
    if (o.headlineIsRate) {
      return _words.cappedAt(value: _formats.percent(o.headline));
    }
    return _words.participation(value: _formats.figure(o.headline));
  }

  /// When an offering closes: "closes today", "closes in 3 days", "closes
  /// 12 Mar".
  String closes(DateTime date) {
    final days = Formats.daysFromToday(date);
    if (days == 0) return _words.closesToday;
    if (days == 1) return _words.closesTomorrow;
    if (days > 1 && days < 7) return _words.closesIn(days: days);
    return _words.closesOn(date: _formats.shortDate(date));
  }

  /// A return since issue: "up 4.1% since issue", "down 6% since issue".
  String change(double value) {
    final size = _formats.percent(value.abs());
    if (value == 0) return _words.unchangedSinceIssue;
    return value > 0
        ? _words.upSinceIssue(value: size)
        : _words.downSinceIssue(value: size);
  }
}
