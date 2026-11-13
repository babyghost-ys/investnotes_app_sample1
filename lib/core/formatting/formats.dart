/// Number and date wording shared by every screen.
abstract final class Formats {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// 0.325 -> "32.5%", trimming a trailing ".0".
  static String percent(double value, {bool signed = false}) {
    final number = (value * 100).toStringAsFixed(1);
    final trimmed = number.endsWith('.0')
        ? number.substring(0, number.length - 2)
        : number;
    final sign = signed && value > 0 ? '+' : '';
    return '$sign$trimmed%';
  }

  /// 1.5 -> "1.5×".
  static String times(double value) {
    final text = value.toStringAsFixed(2);
    var trimmed = text;
    while (trimmed.contains('.') &&
        (trimmed.endsWith('0') || trimmed.endsWith('.'))) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return '$trimmed×';
  }

  static String years(int value) => value == 1 ? '1 yr' : '$value yrs';

  /// Dates the way people say them: "Today", "In 3 days", "12 Mar",
  /// with the year only when it is not this year.
  static String until(DateTime date, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final days = _day(date).difference(today).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days > 1 && days < 7) return 'In $days days';
    return shortDate(date, now: now);
  }

  /// "3 days ago" style for past dates, falling back to a short date.
  static String since(DateTime date, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final days = today.difference(_day(date)).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days > 1 && days < 7) return '$days days ago';
    return shortDate(date, now: now);
  }

  static String shortDate(DateTime date, {DateTime? now}) {
    final year = (now ?? DateTime.now()).year;
    final base = '${date.day} ${_months[date.month - 1]}';
    return date.year == year ? base : '$base ${date.year}';
  }

  /// Always with the year, for date ranges that may span years.
  static String fullDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
