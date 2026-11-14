import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// A pushed page: on iOS UIKit owns its bar, Back button and swipe-back;
/// elsewhere it is a Material page with an app bar.
NativePage<void> keelPage(
  GoRouterState state, {
  required String title,
  required Widget child,
  List<NativeAppBarAction>? actions,
}) => NativePage<void>(
  key: state.pageKey,
  name: state.matchedLocation,
  child: NativeScaffold(
    extendBody: true,
    appBar: NativeAppBar(title: title, actions: actions),
    body: child,
  ),
);
