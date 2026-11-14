import Flutter
import UIKit

/// Main plugin class for Flutter Native Widgets
/// Registers platform views and handles plugin lifecycle
public class FlutterNativeWidgetsPlugin: NSObject, FlutterPlugin {
    /// This engine's size API, kept to unregister it when the engine goes.
    private let sizes: NativeSizes

    private init(sizes: NativeSizes) {
        self.sizes = sizes
        super.init()
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        NativeSizesApiSetup.unregister(api: sizes, registrar: registrar)
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        register(with: registrar, ownsNavigation: true)
    }

    /// Registers the app's own plugins on each native sheet's engine, which
    /// otherwise has this plugin alone. Set it before a sheet first opens,
    /// and register only what sheets use: never this plugin again.
    public static var registerSheetPlugins: ((FlutterPluginRegistry) -> Void)?

    /// Sheet engines own their controls but must not replace the page's
    /// process-wide native navigation and drawer channels.
    static func registerSheetContent(with registrar: FlutterPluginRegistrar) {
        register(with: registrar, ownsNavigation: false)
    }

    private static func register(with registrar: FlutterPluginRegistrar, ownsNavigation: Bool) {
        if ownsNavigation {
            NativeNavigationHost.registerNavigation(messenger: registrar.messenger())
        }
        NativeFonts.register(messenger: registrar.messenger())
        // The search tab view covers the whole screen, and Flutter only routes
        // touches on the tab bar and search field to it. With the default
        // (eager) policy, every other touch left the view's gesture-blocking
        // recognizer waiting on Flutter's gesture arena, which never answers
        // for touches it did not route. UIKit's own outside-tap recognizers
        // then never fire: anchored action sheets and toolbar menus could not
        // be dismissed by tapping elsewhere. Hit testing already decides which
        // touches reach this view, so no arena-based blocking is needed.
        // Requires Flutter 3.47 or later.
        if ownsNavigation {
            registrar.register(SearchTabFactory(messenger: registrar.messenger()),
                               withId: "flutter_native_widgets/search_tabs",
                               gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicyDoNotBlockGesture)
            registrar.register(NavigationSearchFactory(messenger: registrar.messenger()),
                               withId: "flutter_native_widgets/navigation_search")
        }
        registrar.register(NativeTextFieldViewFactory(messenger: registrar.messenger()),
                           withId: "flutter_native_widgets/text_field")
        let actionSheets = AnchoredActionSheet(hostProvider: { registrar.viewController })
        let actionSheetChannel = FlutterMethodChannel(
            name: "flutter_native_widgets/action_sheet", binaryMessenger: registrar.messenger())
        actionSheetChannel.setMethodCallHandler { call, result in
            actionSheets.handle(call, result: result)
        }

        let filterSheetChannel = FlutterMethodChannel(
            name: "flutter_native_widgets/filter_sheet", binaryMessenger: registrar.messenger())
        let filterSheets = NativeFilterSheet(
            channel: filterSheetChannel, hostProvider: { registrar.viewController })
        filterSheetChannel.setMethodCallHandler { call, result in
            filterSheets.handle(call, result: result)
        }

        let widgetSheets: NativeWidgetSheet?
        if ownsNavigation {
            let widgetSheetChannel = FlutterMethodChannel(
                name: "flutter_native_widgets/widget_sheet", binaryMessenger: registrar.messenger())
            let manager = NativeWidgetSheet(
                channel: widgetSheetChannel, hostProvider: { registrar.viewController })
            widgetSheetChannel.setMethodCallHandler { call, result in
                manager.handle(call, result: result)
            }
            widgetSheets = manager
        } else {
            // The owning sheet manager installs this engine's channel, so
            // nested presentation returns to the correct parent isolate.
            widgetSheets = nil
        }

        // Sizes Dart reads synchronously, before a widget's first frame.
        // Measured against the page's view controller: while a native sheet
        // is up, the engine's own is the sheet.
        let sizes = NativeSizes(
            hostProvider: { widgetSheets?.pageController ?? registrar.viewController })
        NativeSizesApiSetup.register(api: sizes, registrar: registrar)
        // iOS calls detachFromEngine only on a published instance.
        registrar.publish(FlutterNativeWidgetsPlugin(sizes: sizes))

        // Register iOS 26 Button platform view factory
        let ios26ButtonFactory = iOS26ButtonViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26ButtonFactory,
            withId: "flutter_native_widgets/ios26_button"
        )

        // Register iOS 26 Switch platform view factory
        let ios26SwitchFactory = iOS26SwitchViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26SwitchFactory,
            withId: "flutter_native_widgets/ios26_switch"
        )

        registrar.register(
            iOS26DatePickerViewFactory(messenger: registrar.messenger()),
            withId: "flutter_native_widgets/ios26_date_picker"
        )

        // Register iOS 26 Slider platform view factory
        let ios26SliderFactory = iOS26SliderViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26SliderFactory,
            withId: "flutter_native_widgets/ios26_slider"
        )

        // Register iOS 26 SegmentedControl platform view factory
        let ios26SegmentedControlFactory = iOS26SegmentedControlViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26SegmentedControlFactory,
            withId: "flutter_native_widgets/ios26_segmented_control"
        )

        // Register iOS 26 AlertDialog platform view factory
        let ios26AlertDialogFactory = iOS26AlertDialogViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26AlertDialogFactory,
            withId: "flutter_native_widgets/ios26_alert_dialog"
        )

        // Register iOS 26 PopupMenuButton platform view factory
        let ios26PopupMenuButtonFactory = iOS26PopupMenuButtonViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26PopupMenuButtonFactory,
            withId: "flutter_native_widgets/ios26_popup_menu_button"
        )

        // Register iOS 26 ContextMenu platform view factory
        let ios26ContextMenuFactory = iOS26ContextMenuViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26ContextMenuFactory,
            withId: "flutter_native_widgets/ios26_context_menu"
        )

        // Register iOS 26 TabBar platform view factory
        if ownsNavigation {
            let ios26TabBarFactory = iOS26TabBarViewFactory(messenger: registrar.messenger())
            registrar.register(
                ios26TabBarFactory,
                withId: "flutter_native_widgets/ios26_tab_bar"
            )

            // Register iOS 26 Toolbar platform view factory
            let ios26ToolbarFactory = iOS26ToolbarFactory(messenger: registrar.messenger())
            registrar.register(
                ios26ToolbarFactory,
                withId: "flutter_native_widgets/ios26_toolbar"
            )
        }

        // Register iOS 26 Blur View platform view factory
        let ios26BlurViewFactory = iOS26BlurViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26BlurViewFactory,
            withId: "flutter_native_widgets/ios26_blur_view"
        )

        // iPhone Duo: where the system puts its vertical bar (iOS 27.1)
        let verticalBarEdgeChannel = FlutterEventChannel(
            name: "flutter_native_widgets/vertical_bar_edge",
            binaryMessenger: registrar.messenger()
        )
        verticalBarEdgeChannel.setStreamHandler(VerticalBarEdgeStreamHandler(registrar: registrar))

        // iPhone Duo: where UIKit lays out a navigation title in this window
        // Measured in the page's view controller: while a native sheet is up,
        // the engine's own is the sheet.
        let titleBand = DuoTitleBand(
            hostProvider: { widgetSheets?.pageController ?? registrar.viewController })
        let titleBandChannel = FlutterMethodChannel(
            name: "flutter_native_widgets/duo_title_band",
            binaryMessenger: registrar.messenger()
        )
        titleBandChannel.setMethodCallHandler { call, result in
            titleBand.handle(call, result: result)
        }
    }
}
