import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:material_ui/material_ui.dart';

/// Keel's app-wide look, in light and dark.
abstract final class KeelTheme {
  static const _tide = Color(0xFF0B3D91);
  static const _tideDark = Color(0xFF0A2C66);

  /// The font of every bar title, from Flutter assets.
  static const titleFontAsset = 'assets/fonts/SourceSans3-Semibold.ttf';

  /// Bar titles: a humanist sans in semibold, set larger than the
  /// system's 17 pt. The bar's foreground colours it.
  static const barTitle = TextStyle(
    fontFamily: 'Source Sans 3',
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const light = NativeThemeData(
    primaryColor: Color(0xFF1E6FE0),
    background: Color(0xFFF5F8FD),
    barStyle: NativeBarStyle.solid(
      _tide,
      foreground: Colors.white,
      shadow: true,
      plainButtons: true,
      titleStyle: barTitle,
      duoStripGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_tide, Color(0xFF2A62C4)],
      ),
    ),
  );

  static const dark = NativeThemeData(
    primaryColor: Color(0xFF4C93FF),
    background: Color(0xFF050B16),
    barStyle: NativeBarStyle.solid(
      _tideDark,
      foreground: Colors.white,
      shadow: true,
      plainButtons: true,
      titleStyle: barTitle,
      duoStripGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_tideDark, Color(0xFF0B1A33)],
      ),
    ),
  );
}
