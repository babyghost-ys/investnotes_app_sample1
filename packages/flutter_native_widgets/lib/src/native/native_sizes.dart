import 'dart:io';

import 'package:flutter/foundation.dart';

import 'native_sizes.g.dart';

export 'native_sizes.g.dart' show SearchHeaderLayout;

/// Sizes UIKit gives native controls, read synchronously through `dart:ffi`.
///
/// A platform view reports its size over a channel only after it exists,
/// which is after the first frame that made room for it. These calls return
/// during build instead, so a widget lays out at UIKit's size from its first
/// frame and its neighbours never see a placeholder size.
///
/// Every method only measures and returns null where there is nothing to ask
/// (another platform, a test, no measurement yet). The widget then starts
/// from its placeholder and waits for its platform view's report, which stays
/// the final word on iOS as well.
abstract final class NativeSizes {
  static NativeSizesApiForNativeInterop? _api;

  static T? _read<T>(T? Function(NativeSizesApiForNativeInterop api) read) {
    if (kIsWeb || !Platform.isIOS) return null;
    try {
      final api = _api ??= NativeSizesApiForNativeInterop.getInstance();
      return api == null ? null : read(api);
    } on Object {
      // No native side registered for this engine: fall back to the report.
      return null;
    }
  }

  /// The height of a native tab bar [width] points wide with one item per
  /// entry of [labels].
  static double? tabBarHeight(double width, List<String> labels) =>
      _read((api) => api.tabBarHeight(width, labels));

  /// The width of a native popup menu button showing [title] and the SF
  /// Symbol [iconName] in the button style named [style].
  static double? popupMenuButtonWidth({
    required String? title,
    required String? iconName,
    required double? iconSize,
    required String style,
  }) => _read(
    (api) => api.popupMenuButtonWidth(title, iconName, iconSize, style),
  );

  /// The navigation search header's last measured layout in a window shaped
  /// like the current one: null before the first search page of a run.
  static SearchHeaderLayout? searchHeaderLayout() =>
      _read((api) => api.searchHeaderLayout());
}
