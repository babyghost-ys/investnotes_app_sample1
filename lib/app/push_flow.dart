import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' show MaterialPageRoute;

/// Pushes a page inside the sign-in sheet. The sheet runs its own navigator
/// (its own engine on iOS), so the pages slide in over it with the
/// platform's transition, edge swipe and back button.
Future<T?> pushFlow<T>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push<T>(
      defaultTargetPlatform == TargetPlatform.iOS
          ? CupertinoPageRoute<T>(builder: builder)
          : MaterialPageRoute<T>(builder: builder),
    );
