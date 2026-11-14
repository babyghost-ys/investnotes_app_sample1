import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const red = Color(0xFFB52132);
const paper = Color(0xFFF6F5F1);

void main() {
  group('NativeThemeData', () {
    const data = NativeThemeData(primaryColor: red, background: paper);

    test('derives a Material theme for each brightness', () {
      final light = data.material(Brightness.light);
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, paper);
      final dark = data.material(Brightness.dark);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });

    test('derives a Cupertino theme', () {
      final theme = data.cupertino(Brightness.light);
      expect(theme.primaryColor, red);
      expect(theme.scaffoldBackgroundColor, paper);
    });

    test('compares by value', () {
      expect(
        const NativeThemeData(
          barStyle: NativeBarStyle.solid(red, shadow: true),
        ),
        const NativeThemeData(
          barStyle: NativeBarStyle.solid(red, shadow: true),
        ),
      );
      expect(
        const NativeBarStyle.system(),
        isNot(const NativeBarStyle.solid(red)),
      );
    });
  });

  testWidgets('NativeTheme.of falls back to the platform defaults', (
    tester,
  ) async {
    late NativeThemeData data;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          data = NativeTheme.of(context);
          return const SizedBox();
        },
      ),
    );
    expect(data.primaryColor, isNull);
    expect(data.barStyle, const NativeBarStyle.system());
  });

  group('NativeApp(theme:)', () {
    Future<(NativeThemeData, ThemeData)> themesIn(
      WidgetTester tester, {
      ThemeMode mode = ThemeMode.light,
    }) async {
      late NativeThemeData native;
      late ThemeData material;
      await tester.pumpWidget(
        NativeApp(
          themeMode: mode,
          theme: const NativeThemeData(
            primaryColor: red,
            background: paper,
            barStyle: NativeBarStyle.solid(red),
          ),
          home: Builder(
            builder: (context) {
              native = NativeTheme.of(context);
              material = Theme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      return (native, material);
    }

    testWidgets('installs the theme and its Material theme', (tester) async {
      final (native, material) = await themesIn(tester);
      expect(native.barStyle.color, red);
      expect(material.scaffoldBackgroundColor, paper);
    });

    testWidgets('derives dark mode without the light background', (
      tester,
    ) async {
      final (native, material) = await themesIn(tester, mode: ThemeMode.dark);
      expect(native.primaryColor, red);
      expect(native.background, isNull);
      expect(native.barStyle.color, red);
      expect(material.brightness, Brightness.dark);
      expect(material.scaffoldBackgroundColor, isNot(paper));
    });
  });

  testWidgets('app bars take the bar style unless they set their own', (
    tester,
  ) async {
    await tester.pumpWidget(
      const NativeApp(
        theme: NativeThemeData(
          barStyle: NativeBarStyle.solid(red, foreground: Colors.white),
        ),
        home: NativeScaffold(
          appBar: NativeAppBar(title: 'Styled'),
          body: SizedBox(),
        ),
      ),
    );
    final bar = tester.widget<AppBar>(find.byType(AppBar));
    expect(bar.backgroundColor, red);
    expect(bar.foregroundColor, Colors.white);

    await tester.pumpWidget(
      const NativeApp(
        theme: NativeThemeData(barStyle: NativeBarStyle.solid(red)),
        home: NativeScaffold(
          appBar: NativeAppBar(
            title: 'Own colour',
            navigationBarColor: Colors.teal,
          ),
          body: SizedBox(),
        ),
      ),
    );
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      Colors.teal,
    );
  });
}
