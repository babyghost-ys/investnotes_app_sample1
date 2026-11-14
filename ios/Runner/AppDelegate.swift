import Flutter
import UIKit
import flutter_native_widgets
import local_auth_darwin

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Sign-in runs in a native sheet's own engine and checks Face ID there.
    FlutterNativeWidgetsPlugin.registerSheetPlugins = { registry in
      if let registrar = registry.registrar(forPlugin: "LocalAuthPlugin") {
        LocalAuthPlugin.register(with: registrar)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
