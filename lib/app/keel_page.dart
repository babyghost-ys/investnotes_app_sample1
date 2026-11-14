import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// A pushed page: on iOS UIKit owns its bar, Back button and swipe-back;
/// elsewhere it is a Material page with an app bar.
AdaptivePage<void> keelPage(
  GoRouterState state, {
  required String title,
  required Widget child,
  List<AdaptiveAppBarAction>? actions,
}) => AdaptivePage<void>(
  key: state.pageKey,
  name: state.matchedLocation,
  child: AdaptiveScaffold(
    extendBody: true,
    appBar: AdaptiveAppBar(title: title, actions: actions),
    body: child,
  ),
);
