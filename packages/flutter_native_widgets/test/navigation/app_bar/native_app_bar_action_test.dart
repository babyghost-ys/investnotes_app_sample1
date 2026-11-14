import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

void main() {
  group('NativeAppBarAction', () {
    test('creates action with iOS symbol', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle'),
        onPressed: () {},
      );

      expect(action.icon?.sfSymbol, 'info.circle');
      expect(action.icon?.icon, isNull);
      expect(action.title, isNull);
    });

    test('creates action with icon', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(icon: Icons.info),
        onPressed: () {},
      );

      expect(action.icon?.icon, Icons.info);
      expect(action.icon?.sfSymbol, isNull);
      expect(action.title, isNull);
    });

    test('creates action with title', () {
      final action = NativeAppBarAction(title: 'Info', onPressed: () {});

      expect(action.title, 'Info');
      expect(action.icon?.sfSymbol, isNull);
      expect(action.icon, isNull);
    });

    test('creates action with all parameters', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle', icon: Icons.info),
        title: 'Info',
        onPressed: () {},
      );

      expect(action.icon?.sfSymbol, 'info.circle');
      expect(action.icon?.icon, Icons.info);
      expect(action.title, 'Info');
    });

    test('throws assertion error when all parameters are null', () {
      expect(
        () => NativeAppBarAction(onPressed: () {}),
        throwsAssertionError,
      );
    });

    test('calls onPressed when action is pressed', () {
      bool pressed = false;
      final action = NativeAppBarAction(
        title: 'Test',
        onPressed: () {
          pressed = true;
        },
      );

      action.onPressed();
      expect(pressed, isTrue);
    });

    test('equality works correctly', () {
      final action1 = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle', icon: Icons.info),
        title: 'Info',
        onPressed: () {},
      );

      final action2 = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle', icon: Icons.info),
        title: 'Info',
        onPressed: () {},
      );

      final action3 = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'settings', icon: Icons.settings),
        title: 'Settings',
        onPressed: () {},
      );

      expect(action1, equals(action2));
      expect(action1, isNot(equals(action3)));
    });

    test('identical instances are equal', () {
      final action = NativeAppBarAction(title: 'Test', onPressed: () {});

      expect(action, equals(action));
    });

    test('hashCode is consistent with equality', () {
      final action1 = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle', icon: Icons.info),
        title: 'Info',
        onPressed: () {},
      );

      final action2 = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle', icon: Icons.info),
        title: 'Info',
        onPressed: () {},
      );

      expect(action1.hashCode, equals(action2.hashCode));
    });

    test('different actions have different hash codes', () {
      final action1 = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle'),
        onPressed: () {},
      );

      final action2 = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'settings'),
        onPressed: () {},
      );

      // Note: Different objects *can* have same hash code, but it's unlikely
      // This test may occasionally fail by chance, but that's acceptable
      expect(action1.hashCode, isNot(equals(action2.hashCode)));
    });

    test('toNativeMap includes iosSymbol when present', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle'),
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map['icon'], 'info.circle');
      expect(map.containsKey('title'), isFalse);
    });

    test('toNativeMap includes title when present', () {
      final action = NativeAppBarAction(title: 'Info', onPressed: () {});

      final map = action.toNativeMap();

      expect(map['title'], 'Info');
      expect(map.containsKey('icon'), isFalse);
    });

    test('toNativeMap includes both iosSymbol and title', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle'),
        title: 'Info',
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map['icon'], 'info.circle');
      expect(map['title'], 'Info');
    });

    test('toNativeMap excludes icon parameter', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(icon: Icons.info, sfSymbol: 'info.circle'),
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map.containsKey('androidIcon'), isFalse);
      expect(map['icon'], 'info.circle');
    });

    test('toNativeMap returns only spacerAfter when only icon is provided', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(icon: Icons.info),
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map.containsKey('icon'), isFalse);
      expect(map.containsKey('title'), isFalse);
      expect(map.containsKey('spacerAfter'), isTrue);
      expect(map['spacerAfter'], 0); // Default is ToolbarSpacerType.none
    });

    test('equality ignores onPressed callback', () {
      final action1 = NativeAppBarAction(title: 'Test', onPressed: () {});

      final action2 = NativeAppBarAction(
        title: 'Test',
        onPressed: () {}, // Different callback instance
      );

      // Equality should only check iosSymbol, icon, and title
      expect(action1, equals(action2));
    });

    test('toNativeMap includes spacerAfter as none by default', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle'),
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map['spacerAfter'], 0); // ToolbarSpacerType.none.index
    });

    test('toNativeMap includes spacerAfter as fixed', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle'),
        onPressed: () {},
        spacerAfter: ToolbarSpacerType.fixed,
      );

      final map = action.toNativeMap();

      expect(map['spacerAfter'], 1); // ToolbarSpacerType.fixed.index
    });

    test('toNativeMap includes spacerAfter as flexible', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'info.circle'),
        onPressed: () {},
        spacerAfter: ToolbarSpacerType.flexible,
      );

      final map = action.toNativeMap();

      expect(map['spacerAfter'], 2); // ToolbarSpacerType.flexible.index
    });

    group('menuItems', () {
      NativeAppBarAction menuAction({
        String hideLabel = 'Hide',
        void Function(int, NativePopupMenuItem<dynamic>)? onSelected,
      }) => NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'ellipsis'),
        menuItems: [
          NativePopupMenuItem(
            label: hideLabel,
            icon: NativeIcon(sfSymbol: 'eye.slash'),
          ),
          const NativePopupMenuDivider(),
          const NativePopupMenuItem(label: 'Delete', isDestructive: true),
          const NativePopupMenuItem(label: 'Later', enabled: false),
        ],
        onMenuItemSelected: onSelected ?? (_, _) {},
      );

      test('needs either onPressed or menuItems', () {
        expect(
          () => NativeAppBarAction(icon: NativeIcon(sfSymbol: 'ellipsis')),
          throwsAssertionError,
        );
      });

      test('needs onMenuItemSelected with menuItems', () {
        expect(
          () => NativeAppBarAction(
            icon: NativeIcon(sfSymbol: 'ellipsis'),
            menuItems: const [NativePopupMenuItem(label: 'Hide')],
          ),
          throwsAssertionError,
        );
      });

      test('toNativeMap sends the entries, dividers included', () {
        final map = menuAction().toNativeMap();

        expect(map['menu'], [
          {'title': 'Hide', 'icon': 'eye.slash'},
          {'divider': true},
          {'title': 'Delete', 'destructive': true},
          {'title': 'Later', 'enabled': false},
        ]);
      });

      test('toNativeMap has no menu for a plain action', () {
        final map = NativeAppBarAction(
          icon: NativeIcon(sfSymbol: 'info.circle'),
          onPressed: () {},
        ).toNativeMap();

        expect(map.containsKey('menu'), isFalse);
      });

      test('a changed entry makes the action unequal', () {
        expect(menuAction(), menuAction());
        expect(menuAction().hashCode, menuAction().hashCode);
        expect(menuAction(), isNot(menuAction(hideLabel: 'Show')));
      });

      test('selectMenuItem reports the entry and its index', () {
        final selected = <(int, String)>[];
        final action = menuAction(
          onSelected: (index, item) => selected.add((index, item.label)),
        );

        action.selectMenuItem(2);
        action.selectMenuItem(1); // divider
        action.selectMenuItem(9); // out of range

        expect(selected, [(2, 'Delete')]);
      });
    });
  });

  group('NativeAppBarAction.badgeCount', () {
    test('defaults to null', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'bell'),
        onPressed: () {},
      );

      expect(action.badgeCount, isNull);
    });

    test('stores the given count', () {
      final action = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'bell'),
        badgeCount: 5,
        onPressed: () {},
      );

      expect(action.badgeCount, 5);
    });

    test('is part of equality and hashCode', () {
      NativeAppBarAction bell(int? count) => NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'bell'),
        badgeCount: count,
        onPressed: () {},
      );

      expect(bell(3), equals(bell(3)));
      expect(bell(3).hashCode, equals(bell(3).hashCode));
      expect(bell(3), isNot(equals(bell(4))));
      expect(bell(3), isNot(equals(bell(null))));
    });

    test('is not sent through toNativeMap', () {
      // The native toolbar does not draw action badges; only the glass
      // capsule does, through GlassCapsuleItem.
      final map = NativeAppBarAction(
        icon: NativeIcon(sfSymbol: 'bell'),
        badgeCount: 5,
        onPressed: () {},
      ).toNativeMap();

      expect(map.containsKey('badge'), isFalse);
      expect(map.containsKey('badgeCount'), isFalse);
    });
  });

  group('NativeAppBarAction.wrapWithBadge', () {
    testWidgets('draws an NativeBadge on Flutter toolbars', (tester) async {
      final badged = NativeAppBarAction(
        icon: NativeIcon(icon: Icons.notifications),
        badgeCount: 7,
        onPressed: () {},
      );
      final plain = NativeAppBarAction(
        icon: NativeIcon(icon: Icons.settings),
        badgeCount: 0,
        onPressed: () {},
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              badged.wrapWithBadge(const Icon(Icons.notifications)),
              plain.wrapWithBadge(const Icon(Icons.settings)),
            ],
          ),
        ),
      );
      expect(find.byType(NativeBadge), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });
  });
}
