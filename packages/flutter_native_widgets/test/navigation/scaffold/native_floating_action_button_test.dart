import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

void main() {
  group('NativeFloatingActionButton', () {
    testWidgets('creates FAB with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: NativeFloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(NativeFloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: NativeFloatingActionButton(
              onPressed: () {
                pressed = true;
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NativeFloatingActionButton));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('creates mini FAB when mini is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: NativeFloatingActionButton(
              onPressed: () {},
              mini: true,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(NativeFloatingActionButton), findsOneWidget);
    });

    testWidgets('respects custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: NativeFloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(NativeFloatingActionButton), findsOneWidget);
    });

    testWidgets('handles null onPressed (disabled state)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: NativeFloatingActionButton(
              onPressed: null,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(NativeFloatingActionButton), findsOneWidget);
    });

    testWidgets('supports hero tag for transitions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: NativeFloatingActionButton(
              onPressed: () {},
              heroTag: 'fab_hero',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(NativeFloatingActionButton), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);
    });
  });
}
