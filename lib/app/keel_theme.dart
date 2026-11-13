import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Keel's app-wide look, in light and dark.
abstract final class KeelTheme {
  static const _tide = Color(0xFF0B3D91);
  static const _tideDark = Color(0xFF0A2C66);

  static const light = AdaptiveThemeData(
    primaryColor: Color(0xFF1E6FE0),
    background: Color(0xFFF5F8FD),
    barStyle: AdaptiveBarStyle.solid(
      _tide,
      foreground: Colors.white,
      plainButtons: true,
      duoStripGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_tide, Color(0xFF2A62C4)],
      ),
    ),
  );

  static const dark = AdaptiveThemeData(
    primaryColor: Color(0xFF4C93FF),
    background: Color(0xFF050B16),
    barStyle: AdaptiveBarStyle.solid(
      _tideDark,
      foreground: Colors.white,
      plainButtons: true,
      duoStripGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_tideDark, Color(0xFF0B1A33)],
      ),
    ),
  );
}
