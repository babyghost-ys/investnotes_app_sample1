import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// How navigation bars look across the app.
@immutable
class NativeBarStyle {
  /// The platform's own bar: Liquid Glass on iOS 26+, the classic bar on
  /// earlier iOS, the theme's app bar on Android.
  const NativeBarStyle.system({this.titleStyle})
    : color = null,
      foreground = null,
      shadow = false,
      plainButtons = false,
      fillsDuoStrip = false,
      duoStripGradient = null;

  /// A solid [color] bar with [foreground] title, back button and actions.
  /// [shadow] draws a subtle shadow below it; [plainButtons] removes the
  /// glass background behind its buttons on iOS 26+.
  ///
  /// On iPhone Duo the system reserves a strip at one edge of the window for
  /// the vertical bar. [fillsDuoStrip] paints that strip with [color], so the
  /// bar reads as one band from the top of the window down the strip. Pass
  /// false to leave the strip in the page background. [duoStripGradient]
  /// paints the strip below the title band with a gradient instead of
  /// [color]; start a vertical one at [color] so it joins the bar without a
  /// step.
  const NativeBarStyle.solid(
    Color this.color, {
    this.foreground,
    this.shadow = false,
    this.plainButtons = false,
    this.fillsDuoStrip = true,
    this.duoStripGradient,
    this.titleStyle,
  });

  final Color? color;
  final Color? foreground;
  final bool shadow;
  final bool plainButtons;

  /// Whether the iPhone Duo vertical bar strip is painted with [color].
  final bool fillsDuoStrip;

  /// Paints the iPhone Duo strip in place of [color] when [fillsDuoStrip].
  final Gradient? duoStripGradient;

  /// The family, size and weight of every bar title, unless a bar sets its
  /// own: the native UIKit bars on iOS (a font from Flutter assets needs
  /// `NativeFonts.registerAssets` first) and the app bars Flutter
  /// draws elsewhere. Colour stays [foreground]'s.
  final TextStyle? titleStyle;

  @override
  bool operator ==(Object other) =>
      other is NativeBarStyle &&
      color == other.color &&
      foreground == other.foreground &&
      shadow == other.shadow &&
      plainButtons == other.plainButtons &&
      fillsDuoStrip == other.fillsDuoStrip &&
      duoStripGradient == other.duoStripGradient &&
      titleStyle == other.titleStyle;

  @override
  int get hashCode => Object.hash(
    color,
    foreground,
    shadow,
    plainButtons,
    fillsDuoStrip,
    duoStripGradient,
    titleStyle,
  );
}

/// The app's look, set once on `NativeApp` and shared by every platform.
///
/// `NativeApp` derives its Material and Cupertino themes from this, so an
/// app states its colours once. Explicit Material or Cupertino themes passed
/// to `NativeApp` still win.
@immutable
class NativeThemeData {
  const NativeThemeData({
    this.primaryColor,
    this.background,
    this.barStyle = const NativeBarStyle.system(),
  });

  /// Accent for controls, selected tabs and links. Null keeps the platform
  /// default (system blue on iOS, the Material baseline on Android).
  final Color? primaryColor;

  /// Page background. Null keeps the platform default.
  final Color? background;

  final NativeBarStyle barStyle;

  /// Cupertino theme for [brightness].
  CupertinoThemeData cupertino(Brightness brightness) => CupertinoThemeData(
    brightness: brightness,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: background,
  );

  /// Material theme for [brightness].
  ThemeData material(Brightness brightness) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: primaryColor == null
        ? null
        : ColorScheme.fromSeed(
            seedColor: primaryColor!,
            brightness: brightness,
          ),
    scaffoldBackgroundColor: background,
  );

  @override
  bool operator ==(Object other) =>
      other is NativeThemeData &&
      primaryColor == other.primaryColor &&
      background == other.background &&
      barStyle == other.barStyle;

  @override
  int get hashCode => Object.hash(primaryColor, background, barStyle);
}

/// Provides the current [NativeThemeData]. `NativeApp` installs it.
class NativeTheme extends InheritedWidget {
  const NativeTheme({
    super.key,
    required this.data,
    this.mode = ThemeMode.system,
    required super.child,
  });

  final NativeThemeData data;

  /// Whether the app follows the system's light and dark mode or forces
  /// one. Native views outside Flutter (a sheet's own window) follow the
  /// system live unless the app forces a mode.
  final ThemeMode mode;

  /// The nearest app's theme mode; [ThemeMode.system] when none is set.
  static ThemeMode modeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NativeTheme>()?.mode ??
      ThemeMode.system;

  static const _fallback = NativeThemeData();

  /// The nearest theme, or the platform defaults when none is installed.
  static NativeThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NativeTheme>()?.data ??
      _fallback;

  @override
  bool updateShouldNotify(NativeTheme oldWidget) =>
      data != oldWidget.data || mode != oldWidget.mode;
}
