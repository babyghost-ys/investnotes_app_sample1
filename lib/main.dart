import 'package:flutter/widgets.dart';

import 'package:investnotes_app_sample1/app/keel_app.dart';
import 'package:investnotes_app_sample1/app/native_sheet_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KeelApp());
}

/// Each native sheet runs in an engine of its own, started here.
@pragma('vm:entry-point')
void nativeSheetMain() {
  runNativeSheetApp();
}
