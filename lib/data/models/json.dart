/// A JSON object as the API sends it.
typedef Json = Map<String, Object?>;

/// Readers for JSON values, shared by the data models.
abstract final class JsonRead {
  static double number(Object? value) => (value as num).toDouble();

  static double? numberOrNull(Object? value) =>
      value == null ? null : number(value);

  static List<double> numbers(Object? value) => [
    for (final n in value as List) (n as num).toDouble(),
  ];

  static List<String> strings(Object? value) => [
    for (final s in value as List) s as String,
  ];

  /// A list of objects. Maps from a platform channel arrive untyped, so
  /// each is read through [object] first.
  static List<T> list<T>(Object? value, T Function(Json json) decode) => [
    for (final item in value as List) decode(object(item)),
  ];

  /// [value] as [Json], nested maps included. JSON from `jsonDecode` passes
  /// through as it is; a map from a platform channel is copied.
  static Json object(Object? value) => value is Json
      ? value
      : {
          for (final MapEntry(:key, :value) in (value as Map).entries)
            key as String: switch (value) {
              Map() => object(value),
              List() => [for (final v in value) v is Map ? object(v) : v],
              _ => value,
            },
        };
}
