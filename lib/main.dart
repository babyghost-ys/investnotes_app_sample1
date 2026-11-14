import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/widgets.dart';

import 'package:investnotes_app_sample1/app/keel_app.dart';
import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/app/native_sheet_app.dart';
import 'package:investnotes_app_sample1/features/splash/view/splash_page.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // iOS's native bars draw their titles with the same font file Flutter
  // has in its assets; it is registered with iOS here, before any bar.
  await AdaptiveNativeFonts.registerAssets(const [KeelTheme.titleFontAsset]);
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
void nativeSheetMain() {
  runNativeSheetApp();
}
