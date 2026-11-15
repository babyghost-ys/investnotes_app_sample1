import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';

/// Number and date wording shared by every screen, in the language of
/// [general]: its separators, its month names, its relative days.
class Formats {
  const Formats(this.general);

  final GeneralLocale general;

  GeneralLabels get _words => general.labels;

  /// 0.325 -> "32.5%" ("32,5 %" in French), trimming a trailing ".0".
  String percent(double value, {bool signed = false}) {
    final number = (value * 100).toStringAsFixed(1);
    final trimmed = number.endsWith('.0')
        ? number.substring(0, number.length - 2)
        : number;
    final sign = signed && value > 0 ? '+' : '';
    return _words.percent(value: '$sign${_decimal(trimmed)}');
  }

  /// 1.5 -> "1.5×" ("1,5×" in French).
  String times(double value) {
    var trimmed = value.toStringAsFixed(2);
    while (trimmed.contains('.') &&
        (trimmed.endsWith('0') || trimmed.endsWith('.'))) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return _words.times(value: _decimal(trimmed));
  }

  /// A plain figure, such as a participation said aloud: 1.5 -> "1.5".
  String figure(double value) =>
      _decimal(value.toStringAsFixed(value % 1 == 0 ? 0 : 1));

  /// A price to two places: 101.4 -> "101.40" ("101,40" in French).
  String fixed(double value, [int places = 2]) =>
      _decimal(value.toStringAsFixed(places));

  /// 184250.4 -> "$184,250" ("184 250 $" in French), whole dollars with
  /// thousands grouped.
  String dollars(double value) {
    final digits = value.round().abs().toString();
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        grouped.write(_words.groupSeparator);
      }
      grouped.write(digits[i]);
    }
    return '${value < 0 ? '-' : ''}${_words.dollars(value: grouped)}';
  }

  String years(int value) =>
      value == 1 ? _words.yearOne : _words.years(count: value);

  /// The days from today to [date]: 0 today, 1 tomorrow, -1 yesterday.
  static int daysFromToday(DateTime date, {DateTime? now}) =>
      _day(date).difference(_day(now ?? DateTime.now())).inDays;

  /// Dates the way people say them: "Today", "In 3 days", "12 Mar",
  /// with the year only when it is not this year.
  String until(DateTime date, {DateTime? now}) {
    final days = daysFromToday(date, now: now);
    if (days == 0) return _words.today;
    if (days == 1) return _words.tomorrow;
    if (days > 1 && days < 7) return _words.inDays(days: days);
    return shortDate(date, now: now);
  }

  /// "3 days ago" style for past dates, falling back to a short date.
  String since(DateTime date, {DateTime? now}) {
    final days = -daysFromToday(date, now: now);
    if (days == 0) return _words.today;
    if (days == 1) return _words.yesterday;
    if (days > 1 && days < 7) return _words.daysAgo(days: days);
    return shortDate(date, now: now);
  }

  String shortDate(DateTime date, {DateTime? now}) {
    final year = (now ?? DateTime.now()).year;
    return date.year == year
        ? _words.dayMonth(day: _dayOf(date), month: _month(date))
        : fullDate(date);
  }

  /// Always with the year, for date ranges that may span years.
  String fullDate(DateTime date) => _words.dayMonthYear(
    day: _dayOf(date),
    month: _month(date),
    year: date.year,
  );

  String _dayOf(DateTime date) =>
      date.day == 1 ? _words.firstOfMonth(day: 1) : '${date.day}';

  String _month(DateTime date) => switch (date.month) {
    1 => _words.monthJan,
    2 => _words.monthFeb,
    3 => _words.monthMar,
    4 => _words.monthApr,
    5 => _words.monthMay,
    6 => _words.monthJun,
    7 => _words.monthJul,
    8 => _words.monthAug,
    9 => _words.monthSep,
    10 => _words.monthOct,
    11 => _words.monthNov,
    _ => _words.monthDec,
  };

  String _decimal(String number) =>
      number.replaceFirst('.', _words.decimalSeparator);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
