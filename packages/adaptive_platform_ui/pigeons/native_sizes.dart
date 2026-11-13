import 'package:pigeon/pigeon.dart';

// Regenerate with:
//   dart run pigeon --input pigeons/native_sizes.dart
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/native/native_sizes.g.dart',
    dartPackageName: 'adaptive_platform_ui',
    swiftOut:
        'ios/adaptive_platform_ui/Sources/adaptive_platform_ui/NativeSizes.g.swift',
    swiftOptions: SwiftOptions(
      useFfi: true,
      ffiModuleName: 'adaptive_platform_ui',
    ),
  ),
)
/// Where UIKit laid out a navigation search header.
class SearchHeaderLayout {
  SearchHeaderLayout({required this.height, required this.bottom});

  /// From the top safe area to the bottom of the search field.
  double height;

  /// The same edge, measured from the top of the window.
  double bottom;
}

/// Sizes UIKit gives native controls, read synchronously so a widget lays out
/// at its final size in its first frame instead of at a placeholder.
///
/// Every method only measures: none touches a view on screen.
@HostApi()
abstract class NativeSizesApi {
  /// The height UIKit gives a tab bar [width] points wide holding one item
  /// per entry of [labels]. Null when UIKit has no answer.
  double? tabBarHeight(double width, List<String> labels);

  /// The width of a popup menu button showing [title] and the SF Symbol
  /// [iconName] in [style]. Null when UIKit has no answer.
  double? popupMenuButtonWidth(
    String? title,
    String? iconName,
    double? iconSize,
    String style,
  );

  /// The navigation search header's last measured layout in a window the
  /// size of the current one. Null before the first search page of a run.
  SearchHeaderLayout? searchHeaderLayout();
}
