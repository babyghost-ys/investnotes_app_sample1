import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter_native_widgets/src/navigation/app_bar/native_navigation_scroll_controller.dart';
import 'package:flutter_native_widgets/src/navigation/chrome/hosted_top_toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Duo preserves native large title, scroll bridge and actions', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final scroll = NativeNavigationScrollController();
    addTearDown(scroll.dispose);
    var pressed = false;
    final action = NativeAppBarAction(
      icon: NativeIcon(sfSymbol: 'person.crop.circle'),
      label: 'Profile',
      onPressed: () => pressed = true,
    );
    final entry = ToolbarEntry(
      id: Object(),
      appBar: NativeAppBar(
        title: 'Spending',
        largeTitle: true,
        actions: [action],
      ),
      route: null,
      navigator: null,
      visible: true,
      scrollController: scroll,
    );
    final duo = TopToolbarContent.of(entry, titleOnly: true);
    final phone = TopToolbarContent.of(entry);
    expect(duo.title, phone.title);
    expect(duo.largeTitle, isTrue);
    expect(duo.scrollController, same(scroll));
    expect(duo.titleOverlay, isNull);
    expect(duo.actions.single, same(action));
    duo.actions.single.onPressed();
    expect(pressed, isTrue);
  });
}
