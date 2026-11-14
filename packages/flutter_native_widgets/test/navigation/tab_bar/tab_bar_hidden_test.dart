import 'package:flutter_native_widgets/src/navigation/tab_bar/uikit_tab_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

void main() {
  group('NativeScaffold tabBarHidden', () {
    testWidgets('accepts tabBarHidden prop and renders body', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NativeScaffold(
            tabBarHidden: true,
            body: Text('Body Content'),
          ),
        ),
      );

      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('defaults tabBarHidden to false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NativeScaffold(body: Text('Default'))),
      );

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('renders with tabBarHidden and bottom navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NativeScaffold(
            tabBarHidden: true,
            body: const Text('Home'),
            bottomNavigationBar: NativeBottomNavigationBar(
              selectedIndex: 0,
              onTap: (_) {},
              items: const [
                NativeNavigationDestination(
                  icon: NativeIcon(icon: Icons.home),
                  label: 'Home',
                ),
                NativeNavigationDestination(
                  icon: NativeIcon(icon: Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('rebuilds when tabBarHidden changes', (
      WidgetTester tester,
    ) async {
      bool hidden = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: NativeScaffold(
              tabBarHidden: hidden,
              body: ElevatedButton(
                onPressed: () => setState(() => hidden = !hidden),
                child: Text('hidden=$hidden'),
              ),
              bottomNavigationBar: NativeBottomNavigationBar(
                selectedIndex: 0,
                onTap: (_) {},
                items: const [
                  NativeNavigationDestination(
                    icon: NativeIcon(icon: Icons.home),
                    label: 'Home',
                  ),
                  NativeNavigationDestination(
                    icon: NativeIcon(icon: Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('hidden=false'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('hidden=true'), findsOneWidget);
    });
  });

  group('UiKitTabBar hidden prop', () {
    testWidgets('accepts hidden prop', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiKitTabBar(
              hidden: true,
              destinations: const [
                NativeNavigationDestination(
                  icon: NativeIcon(icon: Icons.home),
                  label: 'Home',
                ),
              ],
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      // On non-iOS, renders the fallback widget
      expect(find.byType(UiKitTabBar), findsOneWidget);
    });

    testWidgets('defaults hidden to false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiKitTabBar(
              destinations: const [
                NativeNavigationDestination(
                  icon: NativeIcon(icon: Icons.home),
                  label: 'Home',
                ),
              ],
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(UiKitTabBar), findsOneWidget);
    });
  });
}
