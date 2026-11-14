package com.berkaycatak.flutter_native_widgets

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** FlutterNativeWidgetsPlugin */
class FlutterNativeWidgetsPlugin: FlutterPlugin {
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Android uses Material Design widgets directly in Dart
    // No platform views needed for Android
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
