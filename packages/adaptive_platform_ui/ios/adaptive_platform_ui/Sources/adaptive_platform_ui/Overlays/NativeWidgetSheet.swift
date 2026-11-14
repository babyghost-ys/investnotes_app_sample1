import Flutter
import UIKit

/// Every visible sheet owns a continuously attached Flutter engine. The page
/// keeps its engine; no surfaces, viewport metrics, native controls or snapshots
/// move between controllers. Arguments and results cross engines as codec data.
final class NativeWidgetSheet: NSObject, UIAdaptivePresentationControllerDelegate {
    private final class Level {
        let engine: FlutterEngine
        let controller: SheetViewController
        /// A full-screen sheet's own navigation bar, when it asked for one.
        /// UIKit lays the bar out for the device: across the top, or on an
        /// iPhone Duo in the system's vertical bar.
        let navigation: SheetNavigationController?
        /// What UIKit presents: the navigation controller, or the content.
        var presentedController: UIViewController { navigation ?? controller }
        let channel: FlutterMethodChannel
        let arguments: [String: Any]
        let completion: FlutterResult
        let depth: Int
        let detents: String
        let dismissible: Bool
        var window: UIWindow?
        var fitHeight: CGFloat
        var pendingFitHeight: CGFloat?
        var revision = 0
        var presented = false
        var presenting = false
        var ready = false
        var bootstrapped = false
        var dismissing = false
        var closed = false
        /// Fails the sheet when its isolate has not launched by the deadline.
        var launchCheck: DispatchWorkItem?
        /// Watches for the isolate's launch, after which bootstrap is due at once.
        var launchObservation: NSKeyValueObservation?
        /// Asks the page to resume a launched isolate that stays silent.
        var revive: DispatchWorkItem?
        var reviveAttempts = 0
        /// The isolate's state as the page last reported it from the VM
        /// service: `resumed`, a pause event kind, or why it could not tell.
        var isolateState: String?
        /// Fails the sheet when a launched isolate stays silent for too long.
        var startupTimeout: DispatchWorkItem?
        /// Holds the sheet still for the first half of a turn (see
        /// [NativeWidgetSheet.freezeForTurn]).
        let turnHold: TurnHold

        init(engine: FlutterEngine, arguments: [String: Any], depth: Int,
             completion: @escaping FlutterResult) {
            self.engine = engine
            self.arguments = arguments
            self.depth = depth
            self.completion = completion
            detents = arguments["detents"] as? String ?? "fit"
            dismissible = arguments["dismissible"] as? Bool ?? true
            fitHeight = CGFloat((arguments["height"] as? NSNumber)?.doubleValue ?? 320)
            let controller = SheetViewController(engine: engine, nibName: nil, bundle: nil)
            self.controller = controller
            navigation = detents == "fullScreen" && arguments["navigationBar"] as? Bool == true
                ? SheetNavigationController(content: controller)
                : nil
            channel = FlutterMethodChannel(name: "adaptive_platform_ui/widget_sheet",
                                           binaryMessenger: engine.binaryMessenger)
            // Hold the presentation container rather than just the presented
            // view, so animations applied above the sheet also pause. This
            // container includes UIKit's dimming view as well as the sheet.
            turnHold = TurnHold { [weak controller] in
                controller?.presentationController?.containerView?.layer
            }
        }

        func cancelStartupWork() {
            launchCheck?.cancel()
            launchCheck = nil
            cancelRevival()
            startupTimeout?.cancel()
            startupTimeout = nil
        }

        func cancelRevival() {
            launchObservation?.invalidate()
            launchObservation = nil
            revive?.cancel()
            revive = nil
        }
    }

    /// How long a new engine may take to launch its isolate. The engine records
    /// the isolate's identifier (`FlutterEngine.isolateId`) as soon as the
    /// isolate exists, before any Dart runs, so no identifier by then means the
    /// entrypoint was never found.
    private static let launchGrace: TimeInterval = 10
    /// A launched isolate calls `bootstrap` at once. After this much silence
    /// the page isolate is first asked to resume it: a debugger pauses every
    /// new isolate at start, and one that fails to resume the sheet's would
    /// otherwise hold it for good. A debugger that does resume does so within
    /// tens of milliseconds of the pause, so this grace lets it go first and
    /// still keeps the sheet quick when no resume comes. Each request also
    /// reports the isolate's state, which the failure that ends the wait names.
    private static let reviveGrace: TimeInterval = 0.3
    /// Silence between the later requests while the isolate stays quiet.
    private static let reviveSilence: TimeInterval = 1.5
    /// After this many requests the asking slows to [reviveSlowSilence]
    /// until [readyTimeout] ends the wait.
    private static let reviveFastAttempts = 8
    private static let reviveSlowSilence: TimeInterval = 6
    /// How long a launched isolate may stay silent. The isolate reports its own
    /// startup failures at once; only an attached debugger holding it paused at
    /// start, or app code that never builds, keeps it silent this long. The
    /// failure says which: a paused isolate never calls `bootstrap`.
    private static let readyTimeout: TimeInterval = 60

    private let hostProvider: () -> UIViewController?
    /// The page engine's channel: the page isolate is asked over it to
    /// resume a sheet isolate that a debugger left paused at start.
    private let pageChannel: FlutterMethodChannel
    private weak var originalHost: FlutterViewController?
    /// Sheet engines spawn from this group's first engine, not from the page
    /// engine: iOS exposes no public spawn on FlutterEngine, and the page's
    /// implicit engine belongs to no group. In Debug the group's first engine
    /// loads the bundle's kernel as built, so hot reloads and restarts never
    /// reach sheet engines made later: a change to `nativeSheetMain`, or any
    /// sheet code, needs a relaunch to show.
    private let engineGroup = FlutterEngineGroup(name: "adaptive.native.sheets", project: nil)
    private var levels: [Level] = []
    private var measuredHeights: [String: CGFloat] = [:]
    private var heightTransitions: Set<ObjectIdentifier> = []
    private var unqueuedHeightTransitions: Set<ObjectIdentifier> = []

    var pageController: FlutterViewController? {
        originalHost ?? hostProvider() as? FlutterViewController
    }

    init(channel: FlutterMethodChannel, hostProvider: @escaping () -> UIViewController?) {
        pageChannel = channel
        self.hostProvider = hostProvider
        super.init()
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        handle(call, from: nil, result: result)
    }

    private func handle(_ call: FlutterMethodCall, from source: Level?,
                        result: @escaping FlutterResult) {
        if let source, source.closed {
            result(FlutterError(code: "closed", message: "The sheet has closed", details: nil))
            return
        }
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "present":
            present(args, from: source, result: result)
        case "bootstrap":
            guard let source else { result(FlutterMethodNotImplemented); return }
            // The isolate is running: from here only its own reports count.
            source.bootstrapped = true
            source.launchCheck?.cancel()
            source.launchCheck = nil
            source.cancelRevival()
            result(source.arguments)
            // The surface needs its real UIKit appearance and sheet metrics.
            // Waiting for a raster frame before presenting would deadlock.
            DispatchQueue.main.async { [weak self, weak source] in
                guard let self, let source, !source.closed, !source.presented else { return }
                self.presentLevel(source)
            }
        case "ready":
            guard let source else { result(FlutterMethodNotImplemented); return }
            source.ready = true
            source.cancelStartupWork()
            result(nil)
        case "failed":
            guard let source else { result(FlutterMethodNotImplemented); return }
            result(nil)
            guard !source.ready, !source.dismissing else { return }
            failStartup(source, code: "startup_failed",
                        message: args["message"] as? String ?? "The sheet's Dart isolate failed to start")
        case "setHeight":
            if let source { setHeight(args, for: source) }
            result(nil)
        case "setBar":
            source?.navigation?.setBar(args)
            result(nil)
        case "preparePush":
            source?.navigation?.preparePush()
            result(nil)
        case "pushPage":
            source?.navigation?.pushPage(args)
            result(nil)
        case "popPage":
            guard let navigation = source?.navigation else { result(nil); return }
            navigation.popPage { result(nil) }
        case "revealPage":
            source?.navigation?.revealPage()
            result(nil)
        case "dismiss":
            dismiss(source, value: args["value"], result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func present(_ args: [String: Any], from source: Level?,
                         result: @escaping FlutterResult) {
        guard let route = args["route"] as? String, !route.isEmpty else {
            result(FlutterError(code: "missing_route", message: "A registered sheet route is required", details: nil))
            return
        }
        // Covered engines still receive asynchronous events. Only the active
        // caller may place another workflow above the current one.
        guard source === levels.last,
              source.map({ $0.presented && $0.ready && !$0.dismissing }) ?? levels.isEmpty else {
            result(FlutterError(code: "busy", message: "Only the active sheet can present another sheet", details: nil))
            return
        }
        guard let host = pageController,
              let below = source?.window ?? host.view.window,
              let scene = below.windowScene else {
            result(FlutterError(code: "unavailable", message: "No visible Flutter page to present from", details: nil))
            return
        }
        originalHost = host
        let options = FlutterEngineGroupOptions()
        options.entrypoint = "nativeSheetMain"
        let engine = engineGroup.makeEngine(with: options)
        let level = Level(engine: engine, arguments: args, depth: levels.count, completion: result)
        if let height = measuredHeights[route] { level.fitHeight = height }
        levels.append(level)
        if let registrar = engine.registrar(forPlugin: "AdaptivePlatformUiPlugin") {
            AdaptivePlatformUiPlugin.registerSheetContent(with: registrar)
        }
        AdaptivePlatformUiPlugin.registerSheetPlugins?(engine)
        level.channel.setMethodCallHandler { [weak self, weak level] call, result in
            guard let self, let level else {
                result(FlutterError(code: "closed", message: "The sheet has closed", details: nil))
                return
            }
            self.handle(call, from: level, result: result)
        }

        // A separate transparent presenter keeps the page's view visible and
        // its real appearance lifecycle unchanged, even in compact landscape.
        // UIKit still owns the sheet, grabber, dimming and all drag gestures.
        let window = SheetWindow(windowScene: scene)
        window.onWidthChange = { [weak self, weak level] in
            guard let self, let level else { return }
            self.freezeForTurn(level, coordinator: nil)
        }
        window.windowLevel = UIWindow.Level(below.windowLevel.rawValue + 1)
        window.backgroundColor = .clear
        let root = SheetWindowRootController()
        root.statusBarStyle = scene.statusBarManager?.statusBarStyle ?? .default
        root.view.backgroundColor = .clear
        window.rootViewController = root
        level.window = window
        let controller = level.controller
        controller.loadViewIfNeeded()
        controller.view.backgroundColor = (args["backgroundColor"] as? NSNumber)
            .map { UIColor(argb: $0.intValue) } ?? .systemBackground
        // Flutter draws the sheet's new size half way through a turn; until
        // then its last frame stays unscaled at the top left of the view
        // rather than stretching to the view's new bounds.
        controller.view.contentMode = .topLeft
        switch args["brightness"] as? String {
        case "dark": controller.overrideUserInterfaceStyle = .dark
        case "light": controller.overrideUserInterfaceStyle = .light
        default: controller.overrideUserInterfaceStyle = .unspecified
        }
        if let navigation = level.navigation {
            navigation.configure(
                color: (args["barColor"] as? NSNumber)?.intValue,
                foreground: (args["barForeground"] as? NSNumber).map { UIColor(argb: $0.intValue) },
                plainButtons: args["plainButtons"] as? Bool ?? false,
                titleStyle: args["barTitleStyle"] as? [String: Any])
            navigation.send = { [weak level] method, arguments in
                level?.channel.invokeMethod(method, arguments: arguments)
            }
            navigation.overrideUserInterfaceStyle = controller.overrideUserInterfaceStyle
            navigation.view.backgroundColor = controller.view.backgroundColor
        }
        controller.onTransition = { [weak self] coordinator in
            self?.observeHeightTransition(coordinator)
        }
        controller.onLayout = { [weak self] in
            self?.flushPendingHeights()
        }
        controller.onTurn = { [weak self, weak level] coordinator in
            guard let self, let level else { return }
            self.freezeForTurn(level, coordinator: coordinator)
        }
        root.onTurn = { [weak self, weak level] coordinator in
            guard let self, let level else { return }
            self.freezeForTurn(level, coordinator: coordinator)
        }
        // The isolate announces itself to its engine as soon as it launches,
        // before any Dart runs, even when a debugger then holds it paused.
        // Without that by the deadline the entrypoint was never found, which
        // no later event would reveal.
        let launchCheck = DispatchWorkItem { [weak self, weak level] in
            guard let self, let level, !level.closed, !level.dismissing, !level.bootstrapped else { return }
            if level.engine.isolateId == nil {
                self.failStartup(level, code: "startup_failed", message:
                    "The sheet's Dart isolate did not launch within \(Int(Self.launchGrace)) seconds. "
                    + "The app's main.dart must define `@pragma('vm:entry-point') void nativeSheetMain()`, "
                    + "and a Debug build runs the program as built: relaunch after adding it.")
            } else if level.revive == nil {
                // Launched, yet the launch observation never reported it.
                self.scheduleRevival(level)
            }
        }
        level.launchCheck = launchCheck
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.launchGrace, execute: launchCheck)
        // A launched isolate reports its own startup failures ("failed"), so a
        // wall clock has no say until a long silence. An attached debugger can
        // hold a new isolate paused at start for as long as it likes.
        let timeout = DispatchWorkItem { [weak self, weak level] in
            guard let self, let level, !level.ready, !level.closed, !level.dismissing else { return }
            let seconds = Int(Self.readyTimeout)
            self.failStartup(level, code: "startup_timeout", message: level.bootstrapped
                ? "The sheet's Dart isolate bootstrapped but did not report ready within \(seconds) seconds."
                : "The sheet's Dart isolate launched but did not call bootstrap within \(seconds) seconds. "
                    + Self.describe(isolateState: level.isolateState))
        }
        level.startupTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.readyTimeout, execute: timeout)
        watchLaunch(level)
        // The originating present call completes after dismissal, with the
        // encoded result. Its isolate retains its own page or parent draft.
    }

    /// The engine records its isolate's identifier (`FlutterEngine.isolateId`)
    /// as soon as the isolate exists, before any Dart runs, even when a
    /// debugger then holds it paused at start. From then on `bootstrap` is due
    /// at once. While it stays away, the page isolate is asked to resume the
    /// sheet's isolate through the VM service, which only a debug or profile
    /// build has; it resumes an isolate paused at start and nothing else.
    private func watchLaunch(_ level: Level) {
        level.launchObservation = level.engine.observe(\.isolateId, options: [.initial, .new]) {
            [weak self, weak level] engine, _ in
            guard engine.isolateId != nil else { return }
            DispatchQueue.main.async {
                guard let self, let level, !level.bootstrapped, !level.closed, !level.dismissing,
                      level.revive == nil else { return }
                level.launchObservation?.invalidate()
                level.launchObservation = nil
                self.scheduleRevival(level)
            }
        }
    }

    private func scheduleRevival(_ level: Level) {
        let revive = DispatchWorkItem { [weak self, weak level] in
            guard let self, let level, !level.bootstrapped, !level.closed, !level.dismissing,
                  let isolateId = level.engine.isolateId else { return }
            level.reviveAttempts += 1
            self.pageChannel.invokeMethod("resumeIsolate", arguments: [
                "isolateId": isolateId,
                "route": level.arguments["route"] as? String ?? "",
            ]) { [weak level] reply in
                if let state = reply as? String { level?.isolateState = state }
            }
            self.scheduleRevival(level)
        }
        level.revive = revive
        let silence: TimeInterval
        switch level.reviveAttempts {
        case 0: silence = Self.reviveGrace
        case ..<Self.reviveFastAttempts: silence = Self.reviveSilence
        default: silence = Self.reviveSlowSilence
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + silence, execute: revive)
    }

    /// Words for the state the page last saw the sheet's isolate in, as the
    /// VM service reports it, for the failure that ends the wait.
    private static func describe(isolateState: String?) -> String {
        guard let state = isolateState else {
            return "An attached debugger may be holding it paused at start."
        }
        switch state {
        case "PauseStart":
            return "It is paused at start and the resume requests were not honoured; "
                + "another debugger client may be holding resumes."
        case "PauseBreakpoint", "PauseException", "PauseInterrupted", "PausePostRequest":
            return "The debugger has it paused (\(state)); resume it there."
        case "resumed", "Resume", "None":
            return "It is running and never called bootstrap: code in nativeSheetMain ahead of "
                + "bootstrap() may have thrown or hung."
        case "PauseExit", "gone":
            return "It has already exited."
        case "unreachable":
            return "The VM service address was not reachable from the app, "
                + "as on a physical device under an IDE debug session."
        case "no-service", "release":
            return "No VM service is available to inspect it."
        case "error":
            return "The VM service did not answer about it."
        default:
            return "Its last reported state is \(state)."
        }
    }

    private func presentLevel(_ level: Level) {
        guard let window = level.window, let presenter = window.rootViewController,
              !level.closed, !level.presented else { return }
        let controller = level.controller
        let presented = level.presentedController
        if level.detents == "fullScreen" {
            presented.modalPresentationStyle = .overFullScreen
            presented.modalPresentationCapturesStatusBarAppearance = true
            presented.isModalInPresentation = true
        } else {
            controller.modalPresentationStyle = .pageSheet
            controller.modalPresentationCapturesStatusBarAppearance = false
            // A sheet that only closes through its own controls is refused in
            // [presentationControllerShouldDismiss] rather than marked modal
            // in presentation, so UIKit presents and turns every sheet alike.
            controller.isModalInPresentation = false
            if let sheet = controller.sheetPresentationController {
                switch level.detents {
                case "full": sheet.detents = [.large()]
                case "fit":
                    if #available(iOS 16.0, *) {
                        setFitDetent(level, sheet: sheet)
                    } else {
                        sheet.detents = [.medium(), .large()]
                    }
                case "short":
                    if #available(iOS 16.0, *) {
                        sheet.detents = [.custom(identifier: .init("short\(level.depth)")) { context in
                            min(context.maximumDetentValue, max(context.maximumDetentValue * 0.34, 300))
                        }]
                    } else {
                        sheet.detents = [.medium()]
                    }
                default: sheet.detents = [.medium(), .large()]
                }
                sheet.prefersGrabberVisible = level.dismissible
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.prefersEdgeAttachedInCompactHeight = true
            }
        }
        presented.presentationController?.delegate = self
        level.presented = true
        level.presenting = true
        window.makeKeyAndVisible()
        presenter.present(presented, animated: true) { [weak self, weak level] in
            guard let self, let level else { return }
            level.presenting = false
            if !level.dismissible && level.detents != "fullScreen" {
                Self.disableSheetPans(above: controller.view)
            }
            self.flushPendingHeights()
        }
    }

    /// A sheet that only closes through its own controls cannot be dragged,
    /// so UIKit's pan recognisers around it are switched off. Left on, they
    /// claim vertical drags meant for the Flutter content, and a long sheet
    /// barely scrolls. Recognisers inside [view] are Flutter's own and stay.
    private static func disableSheetPans(above view: UIView) {
        var current = view.superview
        while let ancestor = current, !(ancestor is UIWindow) {
            for recognizer in ancestor.gestureRecognizers ?? []
            where recognizer is UIPanGestureRecognizer {
                recognizer.isEnabled = false
            }
            current = ancestor.superview
        }
    }

    @available(iOS 16.0, *)
    private func setFitDetent(_ level: Level, sheet: UISheetPresentationController) {
        let identifier = UISheetPresentationController.Detent.Identifier("fit\(level.depth)_\(level.revision)")
        let height = level.fitHeight
        sheet.detents = [.custom(identifier: identifier) { context in
            min(context.maximumDetentValue, height)
        }]
        sheet.selectedDetentIdentifier = identifier
    }

    private func setHeight(_ args: [String: Any], for level: Level) {
        guard let value = (args["height"] as? NSNumber)?.doubleValue,
              value.isFinite, value > 0, !level.closed, !level.dismissing else { return }
        let height = CGFloat(value)
        // A later measurement may return to the committed height during a
        // transition; discard any older pending measurement in that case.
        level.pendingFitHeight = abs(height - level.fitHeight) > 0.5 ? height : nil
        flushPendingHeights()
    }

    private func observeHeightTransition(_ coordinator: UIViewControllerTransitionCoordinator) {
        let identifier = ObjectIdentifier(coordinator as AnyObject)
        guard heightTransitions.insert(identifier).inserted else { return }
        let queued = coordinator.animate(alongsideTransition: { _ in }) { [weak self] _ in
            // Leave UIKit's transition transaction before changing detents.
            DispatchQueue.main.async {
                guard let self else { return }
                self.heightTransitions.remove(identifier)
                self.unqueuedHeightTransitions.remove(identifier)
                self.flushPendingHeights()
            }
        }
        // Apple notes the completion can still run when this returns false.
        // Keep the transition blocked until it is no longer active instead of
        // treating the return value as proof that it has finished.
        if !queued { unqueuedHeightTransitions.insert(identifier) }
    }

    private func flushPendingHeights() {
        guard levels.contains(where: { $0.pendingFitHeight != nil }) else { return }
        var coordinators: [UIViewControllerTransitionCoordinator] = []
        if let coordinator = pageController?.transitionCoordinator { coordinators.append(coordinator) }
        for level in levels {
            if let coordinator = level.controller.transitionCoordinator { coordinators.append(coordinator) }
            if let coordinator = level.window?.rootViewController?.transitionCoordinator {
                coordinators.append(coordinator)
            }
        }
        let active = Set(coordinators.map { ObjectIdentifier($0 as AnyObject) })
        // A completion may not be queued if we discover a coordinator late.
        // A later layout can release only those already absent from UIKit.
        let inactive = unqueuedHeightTransitions.subtracting(active)
        heightTransitions.subtract(inactive)
        unqueuedHeightTransitions.subtract(inactive)
        coordinators.forEach { observeHeightTransition($0) }
        guard heightTransitions.isEmpty, !levels.contains(where: { $0.presenting }) else { return }

        for level in levels where !level.closed && !level.dismissing {
            guard let height = level.pendingFitHeight else { continue }
            level.pendingFitHeight = nil
            level.fitHeight = height
            if let route = level.arguments["route"] as? String { measuredHeights[route] = height }
            guard #available(iOS 16.0, *), level.detents == "fit", level.presented,
                  let sheet = level.controller.sheetPresentationController else { continue }
            level.revision += 1
            // Keep the established per-level replacement: invalidating detents
            // previously resized the covered sheet as well.
            sheet.animateChanges { self.setFitDetent(level, sheet: sheet) }
        }
    }

    // MARK: Turning with the screen

    /// On iOS 26+ a rotation lays a picture of the old screen over the new
    /// layout and fades it out. The page keeps its old frame for the first
    /// half of the turn (see [TurnHold]); UIKit, though, would move the sheet
    /// to its new frame from the first frame, so the picture's edge cut
    /// across it. The sheet is held still too, and jumps to its new frame at
    /// the half-way point, as its engine draws the new size.
    ///
    /// The hold must be in place before UIKit adds the turn's animations. A
    /// turn reaches the sheet window's frame before any layout pass, so the
    /// window's frame setter holds (no coordinator yet); the controllers'
    /// `viewWillTransition` supplies the coordinator for the snap's timing.
    private func freezeForTurn(_ level: Level, coordinator: UIViewControllerTransitionCoordinator?) {
        guard level.presented, !level.closed, !level.dismissing, !level.presenting else { return }
        level.turnHold.hold(coordinator: coordinator)
    }

    private func dismiss(_ source: Level?, value: Any?, result: @escaping FlutterResult) {
        guard let level = source, level === levels.last else {
            result(FlutterError(code: "inactive", message: "Only the active sheet can dismiss itself", details: nil))
            return
        }
        guard !level.dismissing else { result(nil); return }
        level.dismissing = true
        level.cancelStartupWork()
        // A held layer would never finish the dismissal animation.
        level.turnHold.snap(duration: 0)
        let complete = { [weak self] in
            // Reply to the closing engine before destroying it.
            result(nil)
            self?.finish(level, value: value is NSNull ? nil : value)
        }
        if level.presented {
            level.presentedController.dismiss(animated: true, completion: complete)
        } else {
            complete()
        }
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        guard let level = levels.last,
              level.presentedController === presentationController.presentedViewController else { return true }
        return level.dismissible
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard let level = levels.last,
              level.presentedController === presentationController.presentedViewController else { return }
        finish(level, value: nil)
    }

    private func failStartup(_ level: Level, code: String, message: String) {
        level.dismissing = true
        level.cancelStartupWork()
        level.turnHold.snap(duration: 0)
        let failure = FlutterError(code: code, message: message, details: level.arguments["route"])
        if level.presented {
            level.presentedController.dismiss(animated: false) { [weak self] in self?.finish(level, value: failure) }
        } else {
            finish(level, value: failure)
        }
    }

    private func finish(_ level: Level, value: Any?) {
        guard !level.closed, levels.last === level else { return }
        level.closed = true
        level.cancelStartupWork()
        levels.removeLast()
        flushPendingHeights()
        level.window?.isHidden = true
        (levels.last?.window ?? originalHost?.view.window)?.makeKey()
        level.completion(value)
        // Wait until both channel replies leave their callbacks. Each engine
        // tears down only its own platform views and rendering surface.
        DispatchQueue.main.async {
            level.channel.setMethodCallHandler(nil)
            level.controller.onTransition = nil
            level.controller.onLayout = nil
            level.window?.rootViewController = nil
            level.window = nil
            level.engine.viewController = nil
            level.engine.destroyContext()
        }
    }
}

private final class SheetViewController: FlutterViewController {
    var onTransition: ((UIViewControllerTransitionCoordinator) -> Void)?
    var onLayout: (() -> Void)?

    var onTurn: ((UIViewControllerTransitionCoordinator) -> Void)?

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        onTransition?(coordinator)
        onTurn?(coordinator)
        FlutterTurnPinning.pinOverlays(in: view)
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onLayout?()
    }
}

/// The sheet's window. A turn reaches the window's frame before any layout
/// pass or controller callback, so this is the earliest point in the process
/// at which the sheet can be held still. Only the width changes with a turn;
/// a detent change leaves the window alone.
private final class SheetWindow: UIWindow {
    var onWidthChange: (() -> Void)?

    override var frame: CGRect {
        didSet { if frame.width != oldValue.width { onWidthChange?() } }
    }

    override var bounds: CGRect {
        didSet { if bounds.width != oldValue.width { onWidthChange?() } }
    }
}

private final class SheetWindowRootController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    var onTurn: ((UIViewControllerTransitionCoordinator) -> Void)?
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        onTurn?(coordinator)
        super.viewWillTransition(to: size, with: coordinator)
    }
}

/// One page of a full-screen sheet's navigation. The page in front holds
/// the sheet's Flutter view; a page further back keeps a picture of how it
/// looked, so UIKit's push and pop move whole pages, bar and all.
final class SheetPageController: UIViewController {
    private var cover: UIView?
    /// Called as the page first comes on screen.
    var willAppear: (() -> Void)?

    /// The Flutter view moves between pages, in and out of the window. Were
    /// UIKit to tell Flutter's controller it disappeared each time, Flutter
    /// would drop its surface and the native controls inside it; it is told
    /// once, as the sheet first shows, that it appeared.
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear?()
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }

    /// Lays [picture] over the page, above the Flutter view while it changes
    /// underneath.
    func cover(with picture: UIView) {
        cover?.removeFromSuperview()
        picture.frame = view.bounds
        picture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Touches on the picture never reach the page changing beneath it.
        picture.isUserInteractionEnabled = true
        picture.accessibilityElementsHidden = true
        view.addSubview(picture)
        cover = picture
    }

    func uncover() {
        cover?.removeFromSuperview()
        cover = nil
    }
}

/// The navigation of a full-screen sheet. The sheet's Flutter pages share
/// one engine and one Flutter view, which moves into whichever page is in
/// front. Before a push, a picture of the page in front covers it while
/// Flutter switches to the new page beneath; UIKit then pushes a new page
/// holding the Flutter view. A pop slides the page away over the picture
/// left behind, after which Flutter switches back and the picture lifts.
final class SheetNavigationController: UINavigationController,
    UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    private let content: FlutterViewController
    private var plainButtons = false
    private var foreground: UIColor?
    private var popCompletion: (() -> Void)?
    /// Sends a call to the sheet's isolate.
    var send: ((String, Any?) -> Void)?
    /// The bar colour above the bar. On an iPhone Duo the title sits lower,
    /// in the system's title band, and UIKit leaves the space over it bare;
    /// the app's own navigation fills it the same way.
    private let topBackdrop: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.accessibilityElementsHidden = true
        return view
    }()

    init(content: FlutterViewController) {
        self.content = content
        let root = SheetPageController()
        super.init(rootViewController: root)
        delegate = self
        embed(in: root)
        root.willAppear = { [weak self, weak root] in
            guard let self, !self.contentAppeared else { return }
            self.contentAppeared = true
            root?.willAppear = nil
            self.content.beginAppearanceTransition(true, animated: false)
            self.content.endAppearanceTransition()
        }
    }

    /// Whether Flutter's controller has been told it appeared.
    private var contentAppeared = false

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    func configure(color: Int?, foreground: UIColor?, plainButtons: Bool,
                   titleStyle: [String: Any]? = nil) {
        self.plainButtons = plainButtons
        self.foreground = foreground
        if let style = NativeBarAppearance.make(color: color, shadow: false, foreground: foreground,
                                                titleStyle: titleStyle) {
            navigationBar.standardAppearance = style
            navigationBar.scrollEdgeAppearance = style
            navigationBar.compactAppearance = style
            navigationBar.compactScrollEdgeAppearance = style
        }
        navigationBar.tintColor = foreground
        topBackdrop.backgroundColor = color.map { UIColor(argb: $0) }
    }

    /// Moves the Flutter view into [page], beneath anything covering it.
    private func embed(in page: SheetPageController) {
        guard content.parent !== page else { return }
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
        page.addChild(content)
        content.view.frame = page.view.bounds
        content.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        page.view.insertSubview(content.view, at: 0)
        content.didMove(toParent: page)
    }

    private var front: SheetPageController? { topViewController as? SheetPageController }

    /// The page in front's title and close control. Back appears on its own
    /// whenever there is a page to go back to.
    func setBar(_ args: [String: Any]) {
        guard let page = front else { return }
        configureItems(of: page, args, back: viewControllers.count > 1)
    }

    private func configureItems(of page: SheetPageController, _ args: [String: Any],
                                back: Bool) {
        let item = page.navigationItem
        item.title = args["title"] as? String
        item.hidesBackButton = true
        item.leftBarButtonItem = back
            ? button("chevron.backward", "Back") { [weak self] in self?.goBack() }
            : nil
        let close: () -> Void = { [weak self] in self?.send?("barAction", ["id": "close"]) }
        if args["close"] as? Bool != true {
            item.rightBarButtonItem = nil
        } else if let title = args["closeTitle"] as? String {
            // Leaving named in words, such as going home without signing in.
            item.rightBarButtonItem = UIBarButtonItem(
                title: title, image: nil, primaryAction: UIAction { _ in close() }, menu: nil)
        } else {
            item.rightBarButtonItem = button("xmark", "Close", close)
        }
        styleButtons()
    }

    private func button(_ symbol: String, _ label: String,
                        _ action: @escaping () -> Void) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: nil, image: UIImage(systemName: symbol),
                                   primaryAction: UIAction { _ in action() }, menu: nil)
        item.accessibilityLabel = label
        return item
    }

    /// Covers the page in front with a picture of itself, so Flutter can
    /// switch to the next page beneath it unseen.
    func preparePush() {
        guard let page = front,
              let picture = content.view.snapshotView(afterScreenUpdates: false) else { return }
        page.cover(with: picture)
    }

    /// Pushes a new page holding the Flutter view, now drawing the next page.
    func pushPage(_ args: [String: Any]) {
        guard transitionCoordinator == nil else { return }
        let page = SheetPageController()
        page.loadViewIfNeeded()
        configureItems(of: page, args, back: true)
        embed(in: page)
        pushViewController(page, animated: true)
        styleButtons()
    }

    /// The back control: UIKit pops, then Flutter follows.
    private func goBack() {
        guard viewControllers.count > 1, transitionCoordinator == nil else { return }
        popViewController(animated: true)
    }

    /// A pop asked for by Flutter, such as a page that finished: completes
    /// once UIKit has popped, so Flutter can follow.
    func popPage(completion: @escaping () -> Void) {
        guard viewControllers.count > 1, transitionCoordinator == nil else { completion(); return }
        popCompletion = completion
        popViewController(animated: true)
    }

    /// Flutter now draws the page in front: lift its picture.
    func revealPage() {
        front?.uncover()
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        guard let page = viewController as? SheetPageController, content.parent !== page else { return }
        // A pop finished (by back, swipe or Flutter): the page now in front
        // takes the Flutter view, still under its picture until Flutter has
        // drawn it again.
        embed(in: page)
        if let completion = popCompletion {
            popCompletion = nil
            completion()
        } else {
            send?("pagePopped", nil)
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1 && transitionCoordinator == nil
    }

    /// Whether the system shows the bar's controls in a vertical bar (an
    /// iPhone Duo) rather than across the top.
    private var verticalNavigation: Bool {
        switch VerticalBarEdgeStreamHandler.edge(of: view) {
        case "left", "right": true
        default: false
        }
    }

    /// Plain buttons across the top; in the vertical bar, the system's glass
    /// with label contrast, as the app's own native bars do.
    func styleButtons() {
        let vertical = verticalNavigation
        for page in viewControllers {
            let items = (page.navigationItem.leftBarButtonItems ?? [])
                + (page.navigationItem.rightBarButtonItems ?? [])
            for item in items {
                if #available(iOS 26.0, *) {
                    item.hidesSharedBackground = plainButtons && !vertical
                }
                item.tintColor = plainButtons && vertical ? .label : foreground
            }
        }
    }

    /// Light status bar text over a bar whose controls are light.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        var white: CGFloat = 0
        guard let foreground, foreground.getWhite(&white, alpha: nil) else { return .default }
        return white > 0.5 ? .lightContent : .darkContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if topBackdrop.superview !== view {
            view.insertSubview(topBackdrop, belowSubview: navigationBar)
        }
        topBackdrop.frame = CGRect(x: 0, y: 0, width: view.bounds.width,
                                   height: max(0, navigationBar.frame.minY))
        // Folding or unfolding moves the controls between the top and the
        // vertical bar.
        styleButtons()
    }
}
