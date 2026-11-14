import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The test host is not iOS, so the native family is never available here.
  group('NativeStyle', () {
    test('defaults to Material off iOS', () {
      expect(NativeStyle.platformDefault, NativeStyle.material);
    });

    Future<NativeStyle> styleUnder(
      WidgetTester tester,
      NativeStyle? requested,
    ) async {
      late NativeStyle style;
      final probe = Builder(
        builder: (context) {
          style = NativeStyle.of(context);
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        requested == null
            ? probe
            : NativeStyleScope(style: requested, child: probe),
      );
      return style;
    }

    testWidgets('without a scope uses the platform default', (tester) async {
      expect(await styleUnder(tester, null), NativeStyle.material);
    });

    testWidgets('a scope asking for native falls back to Material off iOS', (
      tester,
    ) async {
      expect(
        await styleUnder(tester, NativeStyle.native),
        NativeStyle.material,
      );
    });

    testWidgets('NativeApp installs the style for everything below', (
      tester,
    ) async {
      late NativeStyle style;
      await tester.pumpWidget(
        NativeApp(
          style: NativeStyle.material,
          home: Builder(
            builder: (context) {
              style = NativeStyle.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style, NativeStyle.material);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('NativeCapabilities', () {
    test('report nothing iOS-only off iOS', () {
      expect(NativeCapabilities.liquidGlass, isFalse);
      expect(NativeCapabilities.systemVerticalBarEdge, isFalse);
    });
  });
}
