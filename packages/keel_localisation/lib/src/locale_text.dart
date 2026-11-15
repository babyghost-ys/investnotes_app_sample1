/// Fills the placeholders of the generated classes' texts.
abstract final class LocaleText {
  static final _placeholder = RegExp(r'\{(\w+)\}');

  /// [template] with each `{name}` replaced by [values]`[name]`.
  static String fill(String template, Map<String, Object> values) =>
      template.replaceAllMapped(_placeholder, (match) {
        final value = values[match[1]];
        return value == null ? match[0]! : '$value';
      });
}
