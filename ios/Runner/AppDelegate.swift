import Flutter
import UIKit
import flutter_native_widgets
import local_auth_darwin
import video_player_avfoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Sheets run in engines of their own: sign-in checks Face ID there.
    FlutterNativeWidgetsPlugin.registerSheetPlugins = { registry in
      if let registrar = registry.registrar(forPlugin: "LocalAuthPlugin") {
        LocalAuthPlugin.register(with: registrar)
      }
      // Education's film plays full screen in a sheet's engine too.
      if let registrar = registry.registrar(forPlugin: "VideoPlayerPlugin") {
        VideoPlayerPlugin.register(with: registrar)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
