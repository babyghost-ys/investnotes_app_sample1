/// A JSON object as the API sends it.
typedef Json = Map<String, Object?>;

/// Readers for the API's values. Dates arrive as UTC instants and are
/// shown in the device's time zone; rates arrive as plain numbers.
abstract final class JsonRead {
  static DateTime date(Object? value) =>
      DateTime.parse(value as String).toLocal();

  static DateTime? dateOrNull(Object? value) =>
      value == null ? null : date(value);

  static double number(Object? value) => (value as num).toDouble();

  static double? numberOrNull(Object? value) =>
      value == null ? null : number(value);

  static List<double> numbers(Object? value) => [
    for (final n in value as List) (n as num).toDouble(),
  ];

  static List<String> strings(Object? value) => [
    for (final s in value as List) s as String,
  ];

  static List<T> list<T>(Object? value, T Function(Json json) decode) => [
    for (final item in value as List) decode(item as Json),
  ];
}
