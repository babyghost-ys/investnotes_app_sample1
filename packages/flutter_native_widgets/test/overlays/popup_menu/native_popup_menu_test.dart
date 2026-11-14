import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// Public barrel only — these are the symbols consumers actually import.
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

void main() {
  group('NativePopupMenuItem.isDestructive', () {
    test('defaults to false', () {
      const item = NativePopupMenuItem<String>(label: 'Edit');
      expect(item.isDestructive, isFalse);
    });

    test('stores true when set', () {
      const item = NativePopupMenuItem<String>(
        label: 'Delete',
        isDestructive: true,
      );
      expect(item.isDestructive, isTrue);
    });
  });

  group('NativePopupMenuItem subtitle/imageBytes', () {
    test('default to null', () {
      const item = NativePopupMenuItem<String>(label: 'Edit');
      expect(item.subtitle, isNull);
      expect(item.imageBytes, isNull);
    });

    test('store subtitle and imageBytes when set', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final item = NativePopupMenuItem<String>(
        label: 'Jamie Doe',
        subtitle: 'Online',
        imageBytes: bytes,
      );
      expect(item.subtitle, 'Online');
      expect(item.imageBytes, same(bytes));
    });
  });

  group('NativePopupMenuButton.widget onTap/triggerOnLongPress guard', () {
    // The assert lives at the public dispatch point (NativePopupMenuButton.widget),
    // so the contract is enforced uniformly on every platform path — not just the
    // iOS-26 native path. This is the load-bearing case consumers actually touch.
    const items = <NativePopupMenuEntry>[
      NativePopupMenuItem<String>(label: 'One'),
    ];
    void onSelected(int index, NativePopupMenuItem<String> entry) {}

    test('throws when onTap is set without triggerOnLongPress', () {
      expect(
        () => NativePopupMenuButton.widget<String>(
          items: items,
          onSelected: onSelected,
          onTap: () {},
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    test('does not throw when onTap pairs with triggerOnLongPress: true', () {
      expect(
        () => NativePopupMenuButton.widget<String>(
          items: items,
          onSelected: onSelected,
          triggerOnLongPress: true,
          onTap: () {},
          child: const SizedBox(),
        ),
        returnsNormally,
      );
    });

    test('does not throw when onTap is null', () {
      expect(
        () => NativePopupMenuButton.widget<String>(
          items: items,
          onSelected: onSelected,
          child: const SizedBox(),
        ),
        returnsNormally,
      );
    });
  });

  // NOTE: the Material destructive-color fix (colorScheme.error) is intentionally
  // NOT covered here. That path lives in the private _MaterialPopupMenuButton and is
  // only selected when PlatformInfo.isAndroid — which reads the real host OS via
  // dart:io (ignores debugDefaultTargetPlatformOverride), so it's unreachable in a
  // host widget test. The color change is covered by code review.
}
