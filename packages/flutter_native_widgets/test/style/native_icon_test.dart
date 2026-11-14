import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeIcon.iconData', () {
    test('prefers the Material icon', () {
      const icon = NativeIcon(sfSymbol: 'house', icon: Icons.home_outlined);
      expect(icon.iconData, Icons.home_outlined);
    });

    test('maps a known SF Symbol to its Cupertino glyph', () {
      expect(
        const NativeIcon(sfSymbol: 'house.fill').iconData,
        CupertinoIcons.house_fill,
      );
    });

    test('draws a neutral circle for an unknown symbol', () {
      expect(const NativeIcon(sfSymbol: 'chart.pie').iconData, Icons.circle);
    });
  });

  group('NativeIcon.build', () {
    test('uses the widget first', () {
      const child = Text('A');
      expect(
        const NativeIcon(icon: Icons.home, widget: child).build(),
        same(child),
      );
    });

    test('draws an image as an ImageIcon', () {
      const image = AssetImage('assets/avatar.png');
      final built = const NativeIcon(image: image).build(color: Colors.red);
      expect(built, isA<ImageIcon>());
      expect((built as ImageIcon).color, Colors.red);
    });

    test('draws an icon with the given colour and size', () {
      final built = const NativeIcon(
        icon: Icons.star,
      ).build(color: Colors.red, size: 18);
      expect(built, isA<Icon>());
      expect((built as Icon).icon, Icons.star);
      expect(built.color, Colors.red);
      expect(built.size, 18);
    });
  });

  test('equal icons compare equal', () {
    expect(
      const NativeIcon(sfSymbol: 'star', icon: Icons.star),
      const NativeIcon(sfSymbol: 'star', icon: Icons.star),
    );
    expect(
      const NativeIcon(sfSymbol: 'star'),
      isNot(const NativeIcon(sfSymbol: 'star.fill')),
    );
  });

  test('needs at least one source', () {
    expect(NativeIcon.new, throwsAssertionError);
  });
}
