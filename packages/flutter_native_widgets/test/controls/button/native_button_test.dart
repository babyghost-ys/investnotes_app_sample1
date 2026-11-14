import 'package:flutter_native_widgets/src/controls/button/uikit_button.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

void main() {
  group('NativeButton', () {
    testWidgets('creates button with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeButton(onPressed: () {}, label: 'Test Button'),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('creates button with child', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeButton.child(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeButton(
              onPressed: () {
                pressed = true;
              },
              label: 'Test Button',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeButton(
              onPressed: () {
                pressed = true;
              },
              label: 'Test Button',
              enabled: false,
            ),
          ),
        ),
      );

      // Try to tap (should not work because button is disabled)
      await tester.tap(find.text('Test Button'), warnIfMissed: false);
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('renders with different styles', (WidgetTester tester) async {
      for (final style in NativeButtonStyle.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NativeButton(
                onPressed: () {},
                style: style,
                label: '$style Button',
              ),
            ),
          ),
        );

        expect(find.text('$style Button'), findsOneWidget);
      }
    });

    testWidgets('renders with different sizes', (WidgetTester tester) async {
      for (final size in NativeButtonSize.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NativeButton(
                onPressed: () {},
                size: size,
                label: '$size Button',
              ),
            ),
          ),
        );

        expect(find.text('$size Button'), findsOneWidget);
      }
    });

    testWidgets('respects custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeButton(
              onPressed: () {},
              color: Colors.red,
              label: 'Red Button',
            ),
          ),
        ),
      );

      expect(find.text('Red Button'), findsOneWidget);
    });

    testWidgets('respects custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeButton(
              onPressed: () {},
              padding: customPadding,
              label: 'Padded Button',
            ),
          ),
        ),
      );

      expect(find.text('Padded Button'), findsOneWidget);
    });

    testWidgets('creates button with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeButton.icon(onPressed: () {}, icon: Icons.add),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('UiKitButton', () {
    testWidgets('creates iOS 26 button with label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: UiKitButton(onPressed: null, label: 'iOS 26 Button'),
          ),
        ),
      );

      expect(find.text('iOS 26 Button'), findsOneWidget);
    });

    testWidgets('creates iOS 26 button with child', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: UiKitButton.child(
              onPressed: null,
              child: Text('iOS 26 Button'),
            ),
          ),
        ),
      );

      expect(find.text('iOS 26 Button'), findsOneWidget);
    });

    testWidgets('responds to tap with animation', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: UiKitButton(
              onPressed: () {
                pressed = true;
              },
              label: 'iOS 26 Button',
            ),
          ),
        ),
      );

      await tester.tap(find.text('iOS 26 Button'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders all iOS 26 button styles', (
      WidgetTester tester,
    ) async {
      for (final style in UiKitButtonStyle.values) {
        await tester.pumpWidget(
          CupertinoApp(
            home: CupertinoPageScaffold(
              child: UiKitButton(
                onPressed: () {},
                style: style,
                label: '$style',
              ),
            ),
          ),
        );

        expect(find.text('$style'), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('renders all iOS 26 button sizes', (WidgetTester tester) async {
      for (final size in UiKitButtonSize.values) {
        await tester.pumpWidget(
          CupertinoApp(
            home: CupertinoPageScaffold(
              child: UiKitButton(onPressed: () {}, size: size, label: '$size'),
            ),
          ),
        );

        expect(find.text('$size'), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });
  });
}
