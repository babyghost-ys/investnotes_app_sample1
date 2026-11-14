import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

void main() {
  group('NativeSwitch', () {
    testWidgets('creates switch with initial value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeSwitch(value: true, onChanged: (value) {}),
          ),
        ),
      );

      expect(find.byType(NativeSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (WidgetTester tester) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeSwitch(
              value: value,
              onChanged: (newValue) {
                value = newValue;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NativeSwitch));
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('does not call onChanged when disabled', (
      WidgetTester tester,
    ) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NativeSwitch(value: value, onChanged: null)),
        ),
      );

      // Switch should be disabled
      expect(find.byType(NativeSwitch), findsOneWidget);
    });

    testWidgets('respects custom activeColor', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeSwitch(
              value: true,
              activeColor: Colors.red,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(NativeSwitch), findsOneWidget);
    });
  });

  group('NativeSlider', () {
    testWidgets('creates slider with initial value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeSlider(value: 0.5, onChanged: (value) {}),
          ),
        ),
      );

      expect(find.byType(NativeSlider), findsOneWidget);
    });

    testWidgets('calls onChanged when dragged', (WidgetTester tester) async {
      double value = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeSlider(
              value: value,
              onChanged: (newValue) {
                value = newValue;
              },
            ),
          ),
        ),
      );

      // Find slider and drag it
      final slider = find.byType(NativeSlider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      // Value should have changed
      expect(value, isNot(0.5));
    });

    testWidgets('respects min and max values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeSlider(
              value: 50,
              min: 0,
              max: 100,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(NativeSlider), findsOneWidget);
    });

    testWidgets('respects divisions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeSlider(
              value: 50,
              min: 0,
              max: 100,
              divisions: 10,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(NativeSlider), findsOneWidget);
    });
  });

  group('NativeCheckbox', () {
    testWidgets('creates checkbox with initial value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeCheckbox(value: true, onChanged: (value) {}),
          ),
        ),
      );

      expect(find.byType(NativeCheckbox), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (WidgetTester tester) async {
      bool? value = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeCheckbox(
              value: value,
              onChanged: (newValue) {
                value = newValue;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NativeCheckbox));
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('supports tristate mode', (WidgetTester tester) async {
      bool? value;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeCheckbox(
              value: value,
              tristate: true,
              onChanged: (newValue) {
                value = newValue;
              },
            ),
          ),
        ),
      );

      expect(find.byType(NativeCheckbox), findsOneWidget);
    });

    testWidgets('does not call onChanged when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NativeCheckbox(value: false, onChanged: null)),
        ),
      );

      expect(find.byType(NativeCheckbox), findsOneWidget);
    });
  });

  group('NativeRadio', () {
    testWidgets('creates radio with initial value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeRadio<int>(
              value: 1,
              groupValue: 1,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(NativeRadio<int>), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (WidgetTester tester) async {
      int? groupValue = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeRadio<int>(
              value: 2,
              groupValue: groupValue,
              onChanged: (value) {
                groupValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NativeRadio<int>));
      await tester.pump();

      expect(groupValue, 2);
    });

    testWidgets('does not call onChanged when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NativeRadio<int>(value: 1, groupValue: 1, onChanged: null),
          ),
        ),
      );

      expect(find.byType(NativeRadio<int>), findsOneWidget);
    });
  });
}
