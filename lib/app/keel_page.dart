import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';
import 'package:material_ui/material_ui.dart';

/// Words a page's bar reads from the [namespaces] it names, in their order.
typedef BarWords<T> = T Function(List<LocaleBundle> locale);

/// A pushed page: on iOS UIKit owns its bar, Back button and swipe-back;
/// elsewhere it is a Material page with an app bar.
///
/// The bar reads its [title], [semanticTitle] and [actions] from the
/// [namespaces] it names, so a page already open turns to a new language
/// with the rest of the app.
NativePage<void> keelPage(
  GoRouterState state, {
  required List<String> namespaces,
  required BarWords<String> title,
  BarWords<String>? semanticTitle,
  required Widget child,
  BarWords<List<NativeAppBarAction>>? actions,
}) => NativePage<void>(
  key: state.pageKey,
  name: state.matchedLocation,
  child: LocalisedBuilder.namespaces(
    namespaces: namespaces,
    builder: (context, locale) => NativeScaffold(
      extendBody: true,
      appBar: NativeAppBar(
        title: title(locale),
        semanticTitle: semanticTitle?.call(locale),
        actions: actions?.call(locale),
      ),
      body: child,
    ),
  ),
);
