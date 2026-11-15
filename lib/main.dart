import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter/widgets.dart';

import 'package:investnotes_app_sample1/app/common_overlay.dart';
import 'package:investnotes_app_sample1/app/keel_app.dart';
import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/app/common_sheet_app.dart';
import 'package:investnotes_app_sample1/features/splash/view/splash_page.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // The strip below the status bar, where it is drawn in this isolate.
  NativeOverlayContainer.builder = CommonOverlay.build;
  // iOS's native bars draw their titles with the same font file Flutter
  // has in its assets; it is registered with iOS here, before any bar.
  await NativeFonts.registerAssets(const [KeelTheme.titleFontAsset]);
  // The first frame waits for the opening picture, so it lands on the
  // launch screen's identical one without a blank frame between.
  binding.deferFirstFrame();
  final view = binding.platformDispatcher.views.first;
  SplashPage.backgroundFor(view.physicalSize / view.devicePixelRatio)
      .resolve(ImageConfiguration.empty)
      .addListener(
        ImageStreamListener(
          (_, _) => binding.allowFirstFrame(),
          onError: (_, _) => binding.allowFirstFrame(),
        ),
      );
  runApp(const KeelApp());
}

/// Each native sheet runs in an engine of its own, started here.
@pragma('vm:entry-point')
void commonSheetMain() {
  runCommonSheetApp();
}

/// The strip below the status bar runs in an engine of its own on iOS,
/// started here (see [NativeOverlayContainer]).
@pragma('vm:entry-point')
void commonOverlayMain() {
  NativeOverlayContainer.run(CommonOverlay.build);
}
