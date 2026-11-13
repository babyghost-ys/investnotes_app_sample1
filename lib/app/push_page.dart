import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Pushes a full-screen page whose bar, Back button and swipe-back UIKit
/// owns on iOS.
Future<T?> pushPage<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  List<AdaptiveAppBarAction>? actions,
}) => AdaptiveNavigator.push<T>(
  context,
  (context) => AdaptiveScaffold(
    extendBody: true,
    appBar: AdaptiveAppBar(title: title, actions: actions),
    body: Builder(builder: builder),
  ),
);
