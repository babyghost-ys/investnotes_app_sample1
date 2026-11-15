import 'package:cupertino_ui/cupertino_ui.dart';

/// Keel's palette. Every colour adapts to the system's light and dark mode;
/// resolve one with `KeelColors.ink.of(context)`.
abstract final class KeelColors {
  /// The bar and hero band: deep tide blue.
  static const tide = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0B3D91),
    darkColor: Color(0xFF0A2C66),
  );

  /// The band's lower edge, for gradients that start at [tide].
  static const tideDeep = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF082C6B),
    darkColor: Color(0xFF071F4A),
  );

  /// Accent for selection, links and payoff lines.
  static const azure = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF1E6FE0),
    darkColor: Color(0xFF4C93FF),
  );

  /// Soft accent behind glyphs and selected chips.
  static const mist = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE6EFFC),
    darkColor: Color(0xFF13233F),
  );

  /// Light lines drawn on the tide band.
  static const foam = Color(0xFFBFD6FA);

  static const page = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF5F8FD),
    darkColor: Color(0xFF050B16),
  );

  static const raised = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF0D1626),
  );

  static const ink = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0E1A2E),
    darkColor: Color(0xFFE9EFF9),
  );

  static const muted = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF64738A),
    darkColor: Color(0xFF8C9BB3),
  );

  static const hairline = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFDCE4F0),
    darkColor: Color(0xFF1C2A40),
  );

  /// System states the app reports (no connection, a failed load): reads
  /// apart from Keel's blues in light and dark mode.
  static const charcoal = Color(0xFF34383E);

  /// Losses only: a muted slate red, kept apart from the blues.
  static const loss = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFB4485A),
    darkColor: Color(0xFFE07A8A),
  );
}

extension ResolveKeel on CupertinoDynamicColor {
  Color of(BuildContext context) => resolveFrom(context);
}
