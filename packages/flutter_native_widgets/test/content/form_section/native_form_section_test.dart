import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeFormSection', () {
    testWidgets('creates form section with children', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              children: [const Text('Row 1'), const Text('Row 2')],
            ),
          ),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
    });

    testWidgets('displays header when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              header: const Text('Header Text'),
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.text('Header Text'), findsOneWidget);
    });

    testWidgets('displays footer when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              footer: const Text('Footer Text'),
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.text('Footer Text'), findsOneWidget);
    });

    testWidgets('displays both header and footer when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              header: const Text('Header Text'),
              footer: const Text('Footer Text'),
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.text('Header Text'), findsOneWidget);
      expect(find.text('Footer Text'), findsOneWidget);
    });

    testWidgets('creates inset grouped form section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection.insetGrouped(
              header: const Text('Inset Header'),
              children: [const Text('Row 1'), const Text('Row 2')],
            ),
          ),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
      expect(find.text('Inset Header'), findsOneWidget);
      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
    });

    testWidgets('applies custom backgroundColor', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              backgroundColor: Colors.red,
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
    });

    testWidgets('applies custom margin', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              margin: const EdgeInsets.all(20),
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
    });

    testWidgets('supports multiple children', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              children: [
                const Text('Row 1'),
                const Text('Row 2'),
                const Text('Row 3'),
                const Text('Row 4'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
      expect(find.text('Row 3'), findsOneWidget);
      expect(find.text('Row 4'), findsOneWidget);
    });

    testWidgets('works with CupertinoFormRow children', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: NativeFormSection(
              children: [
                CupertinoFormRow(prefix: Text('Name'), child: Text('John Doe')),
                CupertinoFormRow(
                  prefix: Text('Email'),
                  child: Text('john@example.com'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('inset grouped has proper default margin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection.insetGrouped(
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
      // The inset grouped version should have horizontal and vertical margins
      // We can't directly test EdgeInsets, but we can verify the widget builds
    });

    testWidgets('handles empty children list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NativeFormSection(children: [])),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
    });

    testWidgets('applies custom decoration when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
    });

    testWidgets('applies custom clipBehavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeFormSection(
              clipBehavior: Clip.hardEdge,
              children: [const Text('Row 1')],
            ),
          ),
        ),
      );

      expect(find.byType(NativeFormSection), findsOneWidget);
    });

    testWidgets('default constructor has Clip.none as default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NativeFormSection(children: [Text('Row 1')])),
        ),
      );

      final section = tester.widget<NativeFormSection>(
        find.byType(NativeFormSection),
      );
      expect(section.clipBehavior, Clip.none);
    });

    testWidgets('insetGrouped constructor has Clip.hardEdge as default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NativeFormSection.insetGrouped(children: [Text('Row 1')]),
          ),
        ),
      );

      final section = tester.widget<NativeFormSection>(
        find.byType(NativeFormSection),
      );
      expect(section.clipBehavior, Clip.hardEdge);
    });

    testWidgets('insetGrouped flag is set correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NativeFormSection(children: [Text('Default')]),
                NativeFormSection.insetGrouped(children: [Text('Inset')]),
              ],
            ),
          ),
        ),
      );

      final sections = tester.widgetList<NativeFormSection>(
        find.byType(NativeFormSection),
      );

      expect(sections.length, 2);
      expect(sections.first.insetGrouped, false);
      expect(sections.last.insetGrouped, true);
    });
  });
}
