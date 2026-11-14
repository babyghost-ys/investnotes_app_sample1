import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The test host renders the Material drawer; the native panel needs iOS.
  Future<(GlobalKey<NativeScaffoldState>, List<String>, List<bool>)> pump(
    WidgetTester tester,
  ) async {
    final key = GlobalKey<NativeScaffoldState>();
    final selected = <String>[];
    final changes = <bool>[];
    await tester.pumpWidget(
      NativeApp(
        home: NativeScaffold(
          key: key,
          appBar: const NativeAppBar(title: 'Home'),
          onDrawerChanged: changes.add,
          drawer: NativeDrawer(
            title: 'Accounts',
            subtitle: 'Demo',
            selectedId: 'personal',
            sections: const [
              [
                NativeDrawerItem(
                  icon: NativeIcon(
                    sfSymbol: 'square.grid.2x2',
                    icon: Icons.grid_view,
                  ),
                  id: 'all',
                  title: 'All accounts',
                ),
                NativeDrawerItem(
                  icon: NativeIcon(
                    sfSymbol: 'person',
                    icon: Icons.person_outline,
                  ),
                  id: 'personal',
                  title: 'Personal',
                ),
              ],
              [
                NativeDrawerItem(
                  icon: NativeIcon(
                    sfSymbol: 'person.crop.circle',
                    icon: Icons.account_circle_outlined,
                  ),
                  id: 'profile',
                  title: 'Profile',
                ),
              ],
            ],
            onSelected: selected.add,
          ),
          body: const SizedBox(),
        ),
      ),
    );
    return (key, selected, changes);
  }

  testWidgets('opens from NativeScaffoldState and lists its sections', (
    tester,
  ) async {
    final (key, _, changes) = await pump(tester);
    expect(key.currentState!.isDrawerOpen, isFalse);
    await key.currentState!.openDrawer();
    await tester.pumpAndSettle();

    expect(key.currentState!.isDrawerOpen, isTrue);
    expect(changes, [true]);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    final personal = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Personal'),
    );
    expect(personal.selected, isTrue);
  });

  testWidgets('choosing an item closes the drawer and reports its id', (
    tester,
  ) async {
    final (key, selected, changes) = await pump(tester);
    await key.currentState!.openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(selected, ['profile']);
    expect(key.currentState!.isDrawerOpen, isFalse);
    expect(changes, [true, false]);
  });

  testWidgets('closeDrawer closes without a selection', (tester) async {
    final (key, selected, _) = await pump(tester);
    await key.currentState!.openDrawer();
    await tester.pumpAndSettle();
    key.currentState!.closeDrawer();
    await tester.pumpAndSettle();

    expect(key.currentState!.isDrawerOpen, isFalse);
    expect(selected, isEmpty);
  });
}
