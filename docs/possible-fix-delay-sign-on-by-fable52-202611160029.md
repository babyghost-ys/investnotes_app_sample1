# Sign-on sheet stalls on TestFlight: cause and fix

## 1. Scope and limits

- Evidence used: the two phone recordings (`video1.MP4`, `video2.MP4`), this project's code, and the Flutter engine history between 3.47.0 and 3.50.0.
- The other app's source is not on this machine. The cause below is inferred. The exact line is not confirmed.

## 2. What the recordings show

### Video 1: Home is idle

| Time | What happens |
| --- | --- |
| 1.95 s | Sign On tapped in the drawer. The drawer closes by 2.15 s. |
| 2.35 s | The bar title clears. The menu and search buttons stay. |
| 2.35 to 7.5 s | Nothing. Home is static. |
| 7.51 s | The tab bar is tapped and starts to react. |
| 7.53 s | One video frame later (17 ms) the sign-on page replaces Home. No slide-up. The tab bar stays on top of it. The bar reads "Sign on" with a close button. |
| 8.35 s | The title clears again. A second full-screen layer slides up with its own "Sign on" bar. Its content is black. |
| 8.8 to 11.0 s | Still black when the clip ends. |

### Video 2: Issued is loading

| Time | What happens |
| --- | --- |
| 2.9 s | Issued tab tapped. The skeleton pulses without stopping. |
| 4.1 s | Sign On tapped in the drawer. |
| 4.5 s | The bar title clears. |
| 5.67 s | One sheet slides up, content already drawn, covering the tab bar. |
| 5.97 s | Settled. About 1.5 s after the tap. |

### What this means

- The sheet is not slow. It is ready and parked.
- A frame drawn by the main engine releases it. The tab tap draws one. The pulsing skeleton draws them continuously.
- Video 1 has two separate faults: the 5 s wait, then a black sheet.
- The sign-on page that appears at 7.53 s is not the sheet. It has no slide-up and sits under the tab bar, so it is drawn in the page's own window.

## 3. Cause

### 3.1 Stall one: a wait for a frame that nobody requests

Most likely the other app, between the Sign On tap and the native `present` call, waits for a frame with `addPostFrameCallback` or `await endOfFrame`, and nothing asks Flutter to draw one.

- `addPostFrameCallback` only registers a callback. It never schedules a frame.
- `endOfFrame` schedules a frame only when the scheduler is idle. Called while a frame is being built, it waits for a frame that somebody else must request. From the Flutter SDK, `packages/flutter/lib/src/scheduler/binding.dart:850`:

```dart
Future<void> get endOfFrame {
  if (_nextFrameCompleter == null) {
    if (schedulerPhase == SchedulerPhase.idle) {
      scheduleFrame();
    }
    _nextFrameCompleter = Completer<void>();
    addPostFrameCallback((Duration timeStamp) {
      _nextFrameCompleter!.complete();
      _nextFrameCompleter = null;
    }, debugLabel: 'SchedulerBinding.completeFrame');
  }
  return _nextFrameCompleter!.future;
}
```

- An idle screen draws nothing, so the callback never runs. Home is idle. Issued is not.
- The title clearing first is the trace of it: the page is changed in one frame, then the code waits for a second frame that never comes.

### 3.2 Stall two: the black sheet

After the release, the sign-on page is first drawn inside the page's window, then about 0.8 s later the real full-screen layer rises with black content. Two candidates, neither verified:

- The same missing frame request, this time in the sheet's own engine.
- The sheet's Flutter view is moved between view controllers and loses its drawing surface until its next frame.

Fixing stall one alone will not fix this.

### 3.3 The fixed delay

- A timer fires without any frame. It is not the hang.
- It makes the hang certain: by the time it fires, the drawer's closing frames are over and the app is idle, so any frame wait after it never completes.
- The 0.8 s gap in video 1 and the 1.5 s lag in video 2 both fit a fixed delay.

## 4. Answers to the questions asked

| Question | Answer |
| --- | --- |
| Is the title hiding a clue? | Yes, the strongest one. The other app changes the page in the main engine before the sheet opens. This app never touches the page. |
| Is the artificial delay a problem? | Yes. It does not hang by itself, but it guarantees the idle state that the frame wait then hangs on. Remove it. |
| Is passing parameters to the sheet engine a problem? | No. The engine group only forwards the entry point, its arguments and the initial route. The code is the same in 3.47 and 3.50. |
| Is starting two engines a problem? | No. This app does the same. |
| Would upgrading to 3.50.0 fix it? | No. 3.50 reworked iOS vsync and touch handling (flutter/flutter#191444), so timing changes and may hide the fault. That change targets touch latency. A missing frame request stays missing. |
| Why are simulators fine? | Not explained without the source. The consistent reading is a timing race: Debug on a 60 Hz simulator against Release on a 120 Hz phone. This is inference. |

## 5. Why this app does not stall

- `NativeSheet.show` calls `present` straight away. No frame wait, no delay.
- The native side shows the sheet the moment the sheet's engine calls `bootstrap`, not on a drawn frame (`NativeWidgetSheet.swift:161`).
- The sheet rises from its own window above the page. The page's bar and routes are left alone (`NativeWidgetSheet.swift:261`).
- One engine draws the sign-in page, in one view controller, and it is never moved.

The full path is in the appendix.

## 6. Fix list for the other app

1. Trace the path from the Sign On tap to `invokeMethod('present')`. Remove every `addPostFrameCallback` and `endOfFrame` on it and call `present` directly.
2. If a frame wait has to stay, request the frame right after registering it:

```dart
SchedulerBinding.instance.addPostFrameCallback((_) => present());
SchedulerBinding.instance.ensureVisualUpdate();
```

3. Do not change the page to open the sheet: no route push, no title change.
4. On the native side, show the sheet when its engine first calls in. Never wait for its first drawn frame.
5. Let one engine draw the sign-on page, in one view controller. Do not draw it in the page first and do not move its Flutter view.
6. Remove the artificial delay.
7. Check each build through TestFlight on idle Home, straight after launch, without touching the screen after Sign On. That is the only case that shows the fault.

## 7. Verified and not verified

Verified:

- Frame timings in both recordings, including the 60 fps check around the tab tap.
- The `endOfFrame` behaviour, from the SDK source.
- This app's sheet path, from its code.
- The engine changes between 3.47.0 and 3.50.0, and what flutter/flutter#191444 targets.

Not verified:

- The exact line in the other app.
- The cause of the black sheet.
- Why simulators pass.
- Whether the tab tap releases the stall on touch-down or on selection. The recording cannot separate them.

---

## Appendix: how this app opens the sign-in sheet

From the tap on the sign-in button to the sheet on screen. All code is from this project.

### Overview

1. The button closes the drawer, then calls `openSignIn`.
2. `openSignIn` calls `NativeSheet.show` with the route name `signIn`.
3. `NativeSheet.show` sends `present` to the native side.
4. The plugin hands the call to `NativeWidgetSheet`.
5. `NativeWidgetSheet` starts a second engine at `commonSheetMain` and builds a hidden window for it.
6. The second engine starts and calls `bootstrap`.
7. The native side answers `bootstrap`, then shows the sheet.
8. The sheet's engine builds the sign-in page.
9. The first frame reports `ready`.

Nothing in steps 1 to 7 waits for a frame or a timer. The only wait is the drawer closing, capped at 350 ms.

### One-time setup

The sheet's engine has only the package's plugin, so the app registers what its sheets need. `ios/Runner/AppDelegate.swift`:

```swift
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
```

The second engine's entry point, `lib/main.dart:55`:

```dart
/// Each native sheet runs in an engine of its own, started here.
@pragma('vm:entry-point')
void commonSheetMain() {
  _sharePdfium();
  runCommonSheetApp();
}
```

### Step 1: the tap

`lib/features/shell/widgets/keel_drawer.dart`. The drawer closes first, then sign-in opens from the scaffold's context, which outlives the drawer.

```dart
final scaffold = NativeScaffold.of(context);

// The drawer's own context goes when it closes; pages are pushed from
// the scaffold's, which stays.
final host = scaffold.context;

// The Material drawer can finish closing without completing the
// scaffold's future, so the wait is capped at the close animation.
Future<void> close() => scaffold.closeDrawer().timeout(
  const Duration(milliseconds: 350),
  onTimeout: () {},
);
```

```dart
RoundIconButton(
  icon: CupertinoIcons.person_crop_circle_badge_plus,
  label: words.semantics.signIn,
  foreground: KeelColors.tide.of(context),
  background: _white,
  iconSize: 22,
  onPressed: () async {
    await close();
    if (host.mounted) {
      await openSignIn(
        host,
        title: sessionWords.labels.signIn,
        homeTitle: sessionWords.labels.home,
      );
    }
  },
),
```

### Step 2: `openSignIn`

`lib/features/session/view/open_sign_in.dart`. On iOS it asks for a full-screen native sheet and passes the bar's first title and close control, so the bar is complete before the sheet shows.

```dart
Future<void> openSignIn(
  BuildContext context, {
  required String title,
  required String homeTitle,
}) async {
  final biometric = context.read<BiometricBloc>().state;
  if (NativeStyle.of(context) != NativeStyle.native) {
    await context.push<void>(
      biometric.enabled ? KeelRoutes.biometricSignIn : KeelRoutes.signIn,
    );
    return;
  }
  final session = context.read<SessionBloc>();
  final name = await NativeSheet.show<String>(
    context: context,
    route: 'signIn',
    arguments: SheetArguments.wrap(
      context,
      biometric.enabled
          ? {
              'biometricName': biometric.name,
              'biometricKind': biometric.kind!.name,
            }
          : null,
    ),
    fullScreen: true,
    backgroundColor: KeelColors.raised.of(context),
    // UIKit's own bar: across the top, or in the Duo's vertical bar.
    navigationBar: true,
    barColor: KeelColors.tide.of(context),
    barForeground: CupertinoColors.white,
    // The same faint shadow under the bar as on the app's own pages.
    barShadow: NativeTheme.of(context).barStyle.shadow,
    plainBarButtons: true,
    barTitleStyle: NativeTheme.of(context).barStyle.titleStyle,
    barTitle: biometric.enabled ? null : title,
    barClose: true,
    barCloseTitle: biometric.enabled ? homeTitle : null,
    // The sheet runs its own engine and router; see the native sheet app.
    builder: (_) => const SizedBox.shrink(),
  );
  if (name != null) session.add(SessionSignedIn(name));
}
```

Blocs cannot cross engines, so the words of the current language travel with the call. `lib/app/sheet_arguments.dart`:

```dart
static Map<String, Object?> wrap(BuildContext context, Object? value) {
  final localisation = context.read<LocalisationBloc>();
  return {
    'words': localisation.library.export(localisation.state.language),
    'value': value,
  };
}
```

### Step 3: `NativeSheet.show` sends `present`

`packages/flutter_native_widgets/lib/src/overlays/native_sheet/native_sheet.dart:351`. One channel call, made at once. Its future completes only when the sheet closes.

```dart
static const _channel = MethodChannel('flutter_native_widgets/widget_sheet');
```

```dart
if (native) {
  if (route == null || route.isEmpty) {
    throw ArgumentError(
      'Native sheets require a route for commonSheetMain.',
    );
  }
  _servePage();
  final value = await _channel.invokeMethod<Object?>('present', {
    'route': route,
    'arguments': arguments,
    'detents': fullScreen ? 'fullScreen' : detents.name,
    'dismissible': isDismissible && !fullScreen,
    ..._colour(
      'backgroundColor',
      backgroundColor ??
          CupertinoColors.systemBackground.resolveFrom(context),
    ),
    'brightness': NativeTheme.modeOf(context) == ThemeMode.system
        ? 'system'
        : CupertinoTheme.brightnessOf(context).name,
    if (fullScreen && navigationBar) ...{
      'navigationBar': true,
      if (barColor != null) ..._colour('barColor', barColor),
      'barForeground': ?barForeground?.toARGB32(),
      'barShadow': barShadow,
      'plainButtons': plainBarButtons,
      if (barTitleStyle != null)
        'barTitleStyle': {
          'fontFamily': barTitleStyle.fontFamily,
          'fontSize': barTitleStyle.fontSize,
          'fontWeight': barTitleStyle.fontWeight?.value,
        },
      'bar': {
        'title': barTitle,
        'close': barClose,
        'closeTitle': ?barCloseTitle,
      },
    },
  });
  if (value == null) return null;
  return decodeResult == null ? value as T : decodeResult(value);
}
```

### Step 4: the plugin routes the call

`FlutterNativeWidgetsPlugin.swift:74`, in `packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Plugin/`:

```swift
let widgetSheetChannel = FlutterMethodChannel(
    name: "flutter_native_widgets/widget_sheet", binaryMessenger: registrar.messenger())
let manager = NativeWidgetSheet(
    channel: widgetSheetChannel, hostProvider: { registrar.viewController })
widgetSheetChannel.setMethodCallHandler { call, result in
    manager.handle(call, result: result)
}
```

### Step 5: a second engine and a hidden window

`NativeWidgetSheet.swift:221`, in `.../Sources/flutter_native_widgets/Overlays/`. Excerpt of `present`; `// ...` marks lines left out.

```swift
private func present(_ args: [String: Any], from source: Level?,
                     result: @escaping FlutterResult) {
    // ...
    guard let host = pageController,
          let below = source?.window ?? host.view.window,
          let scene = below.windowScene else {
        result(FlutterError(code: "unavailable", message: "No visible Flutter page to present from", details: nil))
        return
    }
    originalHost = host
    let covered = [host] + levels.map { $0.controller as FlutterViewController }
    let options = FlutterEngineGroupOptions()
    options.entrypoint = "commonSheetMain"
    let engine = engineGroup.makeEngine(with: options)
    let level = Level(engine: engine, arguments: args, depth: levels.count, completion: result)
    level.coveredStyles = covered.map(CoveredStatusBarStyle.init)
    if let height = measuredHeights[route] { level.fitHeight = height }
    levels.append(level)
    if let registrar = engine.registrar(forPlugin: "FlutterNativeWidgetsPlugin") {
        FlutterNativeWidgetsPlugin.registerSheetContent(with: registrar)
    }
    FlutterNativeWidgetsPlugin.registerSheetPlugins?(engine)
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
    // ...
    window.windowLevel = UIWindow.Level(below.windowLevel.rawValue + 1)
    window.backgroundColor = .clear
    let root = SheetWindowRootController()
    root.statusBarStyle = scene.statusBarManager?.statusBarStyle ?? .default
    root.view.backgroundColor = .clear
    window.rootViewController = root
    level.window = window
    let controller = level.controller
    controller.loadViewIfNeeded()
    controller.view.backgroundColor = UIColor.adaptive(
        args["backgroundColor"], dark: args["backgroundColorDark"]) ?? .systemBackground
    // ...
    if let navigation = level.navigation {
        navigation.configure(
            color: (args["barColor"] as? NSNumber)?.intValue,
            darkColor: (args["barColorDark"] as? NSNumber)?.intValue,
            foreground: (args["barForeground"] as? NSNumber).map { UIColor(argb: $0.intValue) },
            shadow: args["barShadow"] as? Bool ?? false,
            plainButtons: args["plainButtons"] as? Bool ?? false,
            titleStyle: args["barTitleStyle"] as? [String: Any])
        // ...
        // The first page's bar before the sheet shows: on an iPhone Duo an
        // empty bar has no title band, which would appear a moment later.
        if let bar = args["bar"] as? [String: Any] {
            navigation.setBar(bar)
        }
    }
    // ...
    // The originating present call completes after dismissal, with the
    // encoded result. Its isolate retains its own page or parent draft.
}
```

The engine comes from one shared group, `NativeOverlayContainer.swift:7`:

```swift
enum NativeEngines {
    static let group = FlutterEngineGroup(name: "flutter_native_widgets.engines", project: nil)
}
```

At this point the engine is starting, the window exists and the bar is filled in. Nothing is on screen yet.

### Step 6: the second engine starts and calls `bootstrap`

`lib/app/common_sheet_app.dart:24`:

```dart
Future<void> runCommonSheetApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configuration = await NativeSheet.bootstrap(
    encodeResult: (value) => switch (value) {
      OfferingFilter filter => filter.encode(),
      IssuedFilter filter => filter.encode(),
      DateTime date => date.toIso8601String(),
      _ => value,
    },
  );
  runApp(CommonSheetApp(configuration: configuration));
}
```

`native_sheet.dart:106`:

```dart
static Future<Map<String, dynamic>> bootstrap({
  required Object? Function(Object?) encodeResult,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  _hosted = true;
  _encodeResult = encodeResult;
  _channel.setMethodCallHandler(_handleCall);
  _watchStartup();
  try {
    final configuration = await _channel.invokeMapMethod<String, dynamic>(
      'bootstrap',
    );
    if (configuration == null) {
      throw StateError('The native sheet has no configuration.');
    }
    return configuration;
  } catch (error) {
    _failStartup('$error');
    rethrow;
  }
}
```

### Step 7: the native side answers, then shows the sheet

`NativeWidgetSheet.swift:161`. The sheet is shown here, as soon as the engine is alive, on the next turn of the main queue. It does not wait for a drawn frame.

```swift
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
```

`NativeWidgetSheet.swift:431`, the full-screen branch of `presentLevel`:

```swift
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
        // ... page sheet detents
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
```

The sheet is now sliding up, with its bar and background colour. The content follows in the next step.

### Step 8: the sheet's engine builds the sign-in page

`lib/app/common_sheet_app.dart:109`. The `signIn` route gets an app of its own:

```dart
if (configuration['route'] == 'signIn') {
  return NativeStyleScope(
    style: NativeStyle.native,
    child: _SignInSheetApp(
      biometric: switch (_argument) {
        {
          'biometricName': final String name,
          'biometricKind': final String kind,
        } =>
          (name: name, kind: BiometricKind.values.byName(kind)),
        _ => null,
      },
      theme: theme.cupertino(brightness),
      themed: themed,
      background: background == null ? null : Color(background),
    ),
  );
}
```

`lib/app/common_sheet_app.dart:171`. It has its own router, so Register and the forgotten-password pages push inside the sheet:

```dart
class _SignInSheetAppState extends State<_SignInSheetApp> {
  late final _router = GoRouter(
    initialLocation: widget.biometric == null ? '/' : '/biometric',
    routes: [
      signInRoute(path: '/', sheet: true),
      biometricSignInRoute(path: '/biometric', sheet: true),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoApp.router(
    debugShowCheckedModeBanner: false,
    theme: widget.theme,
    localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
    routerConfig: _router,
    builder: (context, child) => widget.themed(
      context,
      NativeSheetContent(
        fits: false,
        backgroundColor: widget.background,
        child: SignInScope(
          base: '/',
          sheet: true,
          biometric: widget.biometric,
          onSignedIn: (name) => NativeSheet.pop(context, name),
          onClose: () => NativeSheet.pop(context),
          child: child!,
        ),
      ),
    ),
  );
}
```

`lib/features/session/view/sign_in_route.dart:158`. The route builds `SignInPage`, wrapped so the native bar follows it:

```dart
GoRoute signInRoute({required String path, required bool sheet}) => GoRoute(
  path: path,
  pageBuilder: (context, state) => _page(
    state,
    sheet: sheet,
    title: (session, _) => session.labels.signIn,
    first: state.extra != SignInScope.fromBiometric,
    child: const SignInPage(),
  ),
  // ... register, reset-password, find-username
);
```

```dart
if (sheet) {
  // UIKit moves the whole page; Flutter switches without a transition.
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: FlowBarHost(
      builder: (context, action) => worded(
        (title, closeTitle) => NativeScaffold(
          body: SheetBarBinder(
            first: first,
            title: title,
            onClose: first ? SignInScope.of(context).onClose : null,
            closeTitle: closeTitle,
            action: action,
            child: child,
          ),
        ),
      ),
    ),
  );
}
```

### Step 9: the first frame reports `ready`

`native_sheet.dart:692`, inside `NativeSheetContent`:

```dart
void _scheduleMeasurement() {
  if (_measureScheduled) return;
  _measureScheduled = true;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    _measureScheduled = false;
    if (!mounted) return;
    // ... height measurement for fit sheets
    if (!_ready) {
      _ready = true;
      NativeSheet._reportReady();
    }
  });
}
```

```dart
/// The content built its first frame: the native side stops waiting.
static void _reportReady() {
  if (!_hosted || _startupReported) return;
  _startupReported = true;
  _restoreErrorHandlers();
  unawaited(_send('ready'));
}
```

`NativeWidgetSheet.swift:175`:

```swift
case "ready":
    guard let source else { result(FlutterMethodNotImplemented); return }
    source.ready = true
    source.cancelStartupWork()
    result(nil)
```

This post-frame callback is safe for two reasons:

- It is registered while the first frame is being built, and `runApp` requests that frame itself.
- Nothing visible waits on it. The sheet is already on screen from step 7. `ready` only cancels the start-up timeouts.

The first page then confirms its bar. `lib/features/session/widgets/sheet_bar_binder.dart:77`:

```dart
void _arrive() {
  if (!mounted) return;
  NativeSheet.onPagePopped = () {
    if (mounted) Navigator.of(context).pop();
  };
  if (_shown) {
    _setBar();
    NativeSheet.revealPage();
    return;
  }
  _shown = true;
  if (widget.first) {
    _setBar();
  } else {
    NativeSheet.pushPage(
      title: widget.title,
      onClose: widget.onClose,
      closeTitle: widget.closeTitle,
      action: widget.action?.value,
    );
  }
}
```

The words match what step 5 already set, so the bar does not change. The sheet is shown.

### After it is shown

Signing in calls `NativeSheet.pop(context, name)`. The sheet closes, the `present` call from step 3 completes with the name, and `openSignIn` adds `SessionSignedIn(name)`.
