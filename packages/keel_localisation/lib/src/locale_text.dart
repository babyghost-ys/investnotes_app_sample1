/// Helpers the generated classes use to read their sections and fill
/// placeholders.
abstract final class LocaleText {
  /// A section of a namespace's JSON as plain strings; an absent section is
  /// empty.
  static Map<String, String> section(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value == null) return const {};
    return {
      for (final MapEntry(:key, :value) in (value as Map).entries)
        key as String: value as String,
    };
  }

  static final _placeholder = RegExp(r'\{(\w+)\}');

  /// [template] with each `{name}` replaced by [values]`[name]`.
  static String fill(String template, Map<String, Object> values) =>
      template.replaceAllMapped(_placeholder, (match) {
        final value = values[match[1]];
        return value == null ? match[0]! : '$value';
      });
}
