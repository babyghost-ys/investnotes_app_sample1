import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter_native_widgets/src/navigation/app_bar/uikit_toolbar.dart';
import 'package:flutter_native_widgets/src/navigation/scaffold/uikit_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('page-owned toolbar uses a circular automatic back button', (
    tester,
  ) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: const UiKitScaffold(
          title: 'Home',
          useHeroBackButton: false,
          children: [SafeArea(child: Text('body:Home'))],
        ),
      ),
    );
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const UiKitScaffold(
          title: 'Detail',
          useHeroBackButton: false,
          children: [SafeArea(child: Text('body:Detail'))],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toolbar = tester.widget<UiKitToolbar>(find.byType(UiKitToolbar));
    expect(toolbar.leading, isNotNull);
    final back = find.byType(NativeButton);
    expect(back, findsOneWidget);
    expect(
      tester.widget<NativeButton>(back).useSmoothRectangleBorder,
      isFalse,
    );

    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('body:Detail'), findsNothing);
    expect(find.text('body:Home'), findsOneWidget);
  });
}
