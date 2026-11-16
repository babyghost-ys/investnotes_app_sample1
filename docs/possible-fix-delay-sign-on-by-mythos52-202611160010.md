# Sign-on stalls in the other app but not in this one: findings and fix

This note replaces the first, narrower version of this file. It combines every pass of the analysis: the first reading of the recordings, the corrections after a closer look at them, the check of this repository's history, and a full read of the sign-in path in this project and of the Flutter sources.

## 1. Scope and limits

- Evidence: the two phone recordings (`video1.MP4`, `video2.MP4`), read frame by frame at 60 frames per second with pixel measurements; this project's code and git history; the Flutter SDK source at the tags 3.47.0 and 3.50.0.
- The other app's source is not on this machine. Everything said about it is read from the recordings and is marked as such. Its faulty line is not known.
- Everything said about this app is verified in its code. Links are relative to this file.

## 2. Short answer

- This app opens sign-in in one step. Nothing in the page changes, and the sheet rises the moment its own engine reports in. Nothing waits for a drawn frame or for a timer.
- The other app first does a step in the page: the title goes, the page stops updating and a sign-on page is built in the main engine. About a second after that step the sheet rises. The five-second hang sits inside the page step.
- The black sheet in video 1 is a second, separate fault: the sheet rose before its own code had built anything to draw.
- Upgrading to Flutter 3.50.0 does not fix either fault. Passing parameters to the sheet engine and running two engines are not the cause.
- The fix is to open sign-on the way this app does. The code to copy is in section 8 and in the last part of this note.

## 3. What the recordings show

Times are measured from the recordings, to one video frame (17 ms).

### Video 1: Home, nothing moving

| Time | Event |
| --- | --- |
| 2.20 s | The drawer has finished closing after the Sign On tap. |
| 2.33 s | The bar title is removed in a single frame. The menu and search buttons stay and are not dimmed. |
| 2.33 to 7.48 s | Nothing changes for 5.1 s. |
| 7.48 s | The tab bar starts to react to a tap on Issued. |
| 7.53 s | In one frame the page shows the sign-on form. There is no slide. The form is in the page's own window, under the tab bar, and the page's bar reads "Sign on" with a close cross. |
| 8.38 s | In one frame that title is removed and a full-screen layer with its own "Sign on" bar starts to slide up. This is 0.85 s after the form appeared. |
| 8.42 to 11.0 s | The content area of that layer is black until the recording ends, 2.6 s later. |

### Video 2: Issued, skeleton showing

| Time | Event |
| --- | --- |
| 2.95 to 3.70 s | The skeleton pulses: the brightness of one bar moves between 215 and 230. |
| 4.55 s | The drawer has finished closing after the Sign On tap. From this frame on the same bar reads a constant 215.0 until it is covered. The page picture is frozen. |
| 4.62 s | The bar title is removed in a single frame. The buttons stay. |
| 5.65 s | The sheet starts to slide up with its content already drawn. This is 1.03 s after the title went. |

### What this establishes

- The page stops updating at the moment sign-on starts. Video 2 shows it directly. Home in video 1 is static, so the same cannot be measured there.
- The bar changes in two steps each time: the title first, the buttons later.
- The sign-on form at 7.53 s is not the sheet. It has no slide and sits under the tab bar, so it is drawn in the page's window by the main engine.
- A tap on the tab bar releases the hang.
- The page step and the sheet are about one second apart in both recordings: 1.03 s and 0.85 s.
- Video 1 contains two faults: the 5.1 s wait, and the black sheet.

## 4. Why this app is instant

Verified in the code. The complete path, with the code, is in the last part of this note.

1. **One step, nothing in the page.** The sign-in button closes the drawer and calls `openSignIn` ([keel_drawer.dart](../lib/features/shell/widgets/keel_drawer.dart#L114)). On iOS `openSignIn` goes straight to `NativeSheet.show` ([open_sign_in.dart](../lib/features/session/view/open_sign_in.dart#L34)), which sends one `present` call at once ([native_sheet.dart](../packages/flutter_native_widgets/lib/src/overlays/native_sheet/native_sheet.dart#L362)). No route is pushed in the page, so the page's route stays in front and its bar and title are never touched.
2. **The sheet is shown on a signal from its own engine.** The native side presents the sheet when the sheet's isolate makes its first call, `bootstrap` ([NativeWidgetSheet.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Overlays/NativeWidgetSheet.swift#L161)). No timer and no drawn frame is involved. The timers in that file are deadlines for failure, 10 s and 60 s ([NativeWidgetSheet.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Overlays/NativeWidgetSheet.swift#L99)).
3. **The same call carries the sheet's data.** The reply to `bootstrap` holds the route and its arguments, and `runApp` follows directly ([common_sheet_app.dart](../lib/app/common_sheet_app.dart#L24)). The sheet cannot rise before its code is running, and its code never waits for data after rising.
4. **The sheet is put on screen first and drawn second.** A Flutter view gets its drawing surface only once it appears (section 9). Waiting for a drawn frame before presenting can never finish, and the code says so ([NativeWidgetSheet.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Overlays/NativeWidgetSheet.swift#L169)).
5. **The sheet has a window of its own.** It is presented over the full screen from a separate window above the page ([NativeWidgetSheet.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Overlays/NativeWidgetSheet.swift#L261)). The page's view controllers get no "disappear" calls, the page's engine keeps drawing, and no Flutter view is moved.
6. **The sheet starts light.** The words of the current language travel in the arguments, so the sheet does not unpack the language archive ([sheet_arguments.dart](../lib/app/sheet_arguments.dart#L14)). The bar's title and close control are given with `present`, so the bar is complete before the sheet shows ([open_sign_in.dart](../lib/features/session/view/open_sign_in.dart#L56)).
7. **Where the package does wait for a frame, it asks for one.** The toolbar registry is the example ([toolbar_registry.dart](../packages/flutter_native_widgets/lib/src/navigation/chrome/toolbar_registry.dart#L227)).

## 5. What the other app does differently

Read from the recordings and matched against how this package behaves. A match of behaviour is not proof.

### 5.1 It changes the page before the sheet

- In this package the page's title can leave the bar in two ways only: the page's own bar entry changes, or another route takes the bar over.
- Behind a sheet or dialog the package keeps the title and dims the buttons ([NativeNavigationHost.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationHost.swift#L352)). The recordings show the opposite: the title is removed and the buttons are not dimmed. So the page's own navigation changed.
- At 7.53 s the main engine shows a complete sign-on page with its own bar. So that page was built in the main app.
- This app has the same page: the route `sign-in` in the page's router ([keel_router.dart](../lib/app/keel_router.dart#L187), [sign_in_route.dart](../lib/features/session/view/sign_in_route.dart#L79)). On iOS it is never used. `openSignIn` takes it only when the style is not native ([open_sign_in.dart](../lib/features/session/view/open_sign_in.dart#L27)).
- History of this repository: at commit `1afb993` (13 November) this app opened sign-in as such a page, with `open(KeelRoutes.signIn)`. Commit `bb70bee` moved it into the native sheet. The other app appears to run the page path and the sheet path together.

### 5.2 The page is held still

- In this package a still picture laid over the page is what a prepared native page push leaves. `prepareNativePush` keeps a snapshot of the page on screen ([NativeNavigationHost+Routes.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationHost+Routes.swift#L30), [NativeNavigationContent.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationContent.swift#L282)), and the bar's buttons are held until UIKit has finished ([NativeNavigationHost.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationHost.swift#L426)).
- Video 2 shows exactly that pair: a frozen page and unchanged buttons.
- A page pushed over another also pauses the animations of the page beneath ([native_scaffold.dart](../packages/flutter_native_widgets/lib/src/navigation/scaffold/native_scaffold.dart#L320)). So once the sign-on page is on top, the Issued skeleton is not what keeps frames coming in video 2. Something else was, most likely the Issued request finishing.

### 5.3 What holds the five seconds: two candidates

Both sit in the page step. Both fit both recordings.

**A. A wait for a frame that nobody requests.**

- `addPostFrameCallback` only registers a callback. It never asks for a frame. `endOfFrame` asks for one only when the scheduler is idle (Flutter SDK 3.50.0, `packages/flutter/lib/src/scheduler/binding.dart`, lines 821 and 850 to 853).
- On an idle page no frame comes, so the callback never runs. A tab tap rebuilds the shell and draws a frame ([shell_page.dart](../lib/features/shell/view/shell_page.dart#L132), [iOS26TabBarPlatformView.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/TabBar/iOS26TabBarPlatformView.swift#L777)).

**B. The page's frames are switched off.**

- When a Flutter view controller is told that it has disappeared, the engine drops its surface and reports `paused` (`FlutterViewController.mm` at 3.47.0, lines 858 to 868). In that state `scheduleFrame()` returns without doing anything (`binding.dart`, lines 425 to 428 and 949 to 951). Every frame request in the page is then ignored, including those of running animations.
- This package forwards "appear" and "disappear" to the page's Flutter view by hand ([NativeNavigationContent.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationContent.swift#L121)). Commit `dadd787` in this repository fixed a freeze of this family on the drawer path: the view's appearance is now handed over when it moves between containers ([NativeNavigationContent.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationContent.swift#L264)). A copy of the package without that change can leave the view marked as not shown.
- Selecting a tab re-attaches the Flutter view and restores its appearance ([NativeNavigationHost+Tabs.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationHost+Tabs.swift#L91)), which turns frames back on. That also fits "any tab tap releases it".

With candidate B, adding `ensureVisualUpdate()` changes nothing, because that call is ignored too.

### 5.4 Why the form appears under the tab bar at 7.53 s

- The tab tap moved the page's Flutter view into the container of the newly selected tab. That container has no held picture, so whatever the main engine was drawing became visible: the sign-on page, with its bar.
- This app refuses to switch tab content while a push is pending and defers it ([NativeNavigationHost+Tabs.swift](../packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Navigation/NativeNavigationHost+Tabs.swift#L93)).
- This is an inference from the picture, not a verified cause.

### 5.5 The one-second gap and the black sheet

- 1.03 s and 0.85 s are close but not equal. They fit a fixed delay plus the start of the second engine. They do not prove a fixed delay.
- In both Flutter versions, giving a view its surface also schedules a frame for it (`Shell::OnPlatformViewCreated` in `shell.cc`, line 1005 at 3.47.0 and line 1019 at 3.50.0). A sheet that is on screen and still black after 2.6 s therefore had nothing built to draw.
- So in video 1 the sheet was presented before its Dart code had built its page, and in video 2 after. In the other app the moment of presenting is not tied to the sheet's engine being ready.
- A second possibility is that one Flutter view is moved between view controllers and loses its surface. It is not verified.

## 6. Answers to the questions asked

| Question | Answer |
| --- | --- |
| Why does this app run smoothly? | It never touches the page, it shows the sheet on the sheet engine's own first call, and it hands the data over in that same call. See section 4. |
| Is the title hiding a clue? | Yes, the strongest one. It shows that sign-on there goes through the page's own navigation first. Here the title cannot change, because nothing happens in the page. |
| Is the artificial delay a problem? | It is not the five-second hang; a timer fires without frames. It does cost about a second on every open, and a timer in place of a signal is what lets the sheet rise while it is still empty. Remove it. |
| Is passing parameters to the sheet engine a problem? | Not in itself. `FlutterEngineGroup.mm` is identical in 3.47.0 and 3.50.0. What matters is how they are passed. Here the sheet's engine asks for them (`bootstrap`), and that request is the signal the sheet is shown on. If they are pushed in when the engine is created, there is no such signal, and a timer or a frame wait has to stand in for it. |
| Is starting two engines a problem? | No. This app does the same. |
| Would Flutter 3.50.0 fix it? | No. The scheduler rules behind both candidates are unchanged between 3.47.0 and 3.50.0. 3.50.0 reworks iOS vsync and touch timing (flutter/flutter#191444), so the symptom may move or hide. The fault stays. |
| Why are simulators fine? | Not explained from here. Both candidates depend on timing and on state, and a simulator runs a Debug build at 60 Hz while the phone runs a Release build at up to 120 Hz. That is a plausible reason, not a shown one. |

## 7. What is still unknown, and two checks on the phone

Unknown: which of the two candidates in 5.3 holds the page, why the sheet was presented empty, and why simulators pass.

Each of these two checks, run through TestFlight, separates the candidates:

1. Open Issued and wait until the list has fully loaded and nothing moves. Then tap Sign On.
2. From Home, switch to another tab and back to Home. Wait until nothing moves. Then tap Sign On.

For both checks the reading is the same:

- It hangs: candidate A. The page was idle, and in video 2 the loading had been supplying the frames.
- It works: candidate B. The hang is tied to the first tab's container, which has never been through a tab switch.

If the two checks disagree, neither candidate is the whole story.

After any fix, test on idle Home straight after launch, without touching the screen after Sign On. That is the only case that shows the hang.

## 8. Fix direction

Open sign-on the way this app does. Each rule names the code to copy from this project. The short pieces are quoted here; the whole path is quoted in the last part of this note.

### Rule 1: do not change the page to open the sheet

No route push, no title change and no tab change. On iOS the tap handler calls the sheet directly. Copy `openSignIn` (last part, step 2).

### Rule 2: let the sheet's engine ask for its data, and show the sheet on that request

Dart side, the sheet's entry point: ask first, then `runApp`. From `lib/app/common_sheet_app.dart`:

```dart
/// The root of a native sheet's own engine. Blocs and closures cannot cross
/// engines, so each sheet gets plain values in and hands plain values back.
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

Native side: answer, then present on the next turn of the main queue. From `NativeWidgetSheet.swift`:

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

`NativeSheet.bootstrap` (Dart) and `presentLevel` (Swift) complete the pair. Both are in the last part, steps 6 and 7.

### Rule 3: present from a window of its own, over the full screen

The page keeps its view, its surface and its appearance. From `present` in `NativeWidgetSheet.swift`:

```swift
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
```

### Rule 4: no timer before presenting

Remove the artificial delay. Timers are for failure only. These are the only two waits this app has, and neither delays a sheet that starts normally:

```swift
/// How long a new engine may take to launch its isolate. The engine records
/// the isolate's identifier (`FlutterEngine.isolateId`) as soon as the
/// isolate exists, before any Dart runs, so no identifier by then means the
/// entrypoint was never found.
private static let launchGrace: TimeInterval = 10
// ...
/// How long a launched isolate may stay silent. The isolate reports its own
/// startup failures at once; only an attached debugger holding it paused at
/// start, or app code that never builds, keeps it silent this long. The
/// failure says which: a paused isolate never calls `bootstrap`.
private static let readyTimeout: TimeInterval = 60
```

### Rule 5: send what the sheet needs with the call

Copy `SheetArguments` (last part, step 2). The sheet then builds its first page without loading anything.

### Rule 6: if a frame wait has to stay anywhere, request the frame

This is how the package does it. From `toolbar_registry.dart`:

```dart
/// Pages register from `didChangeDependencies`, i.e. while the framework is
/// building. Notifying listeners synchronously there would mark the chrome
/// (a sibling of the navigator) dirty mid-build, which the framework
/// rejects, so notifications are always delivered after the current frame.
///
/// The scheduler phase cannot be used to tell "building" from "idle": the
/// very first build of an app runs outside of a frame, with the phase still
/// [SchedulerPhase.idle]. Deferring unconditionally is the only rule that
/// holds everywhere; bursts (several pages registering in one build) are
/// coalesced into a single notification.
void _notifySafely() {
  if (_disposed || _notifyScheduled) return;
  _notifyScheduled = true;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    _notifyScheduled = false;
    if (!_disposed) notifyListeners();
  });
  // Make sure that frame actually happens when nothing else asked for one.
  SchedulerBinding.instance.ensureVisualUpdate();
}
```

### Rule 7: keep the page's Flutter view shown when it moves

If the other app's copy of the package predates commit `dadd787`, take that change. From `NativeNavigationContent.swift`:

```swift
/// Takes Flutter out of this content. When [moving], it goes straight
/// into another content, which shows it at once: its appearance is
/// handed over (the result, for [attachFlutter]) rather than ended and
/// begun again. Ending it tears Flutter's surface down on the main
/// thread and waits for the raster thread, which may itself be waiting
/// on the main thread to add the overlay layers native views need:
/// switching tab from an open drawer froze the app that way.
@discardableResult
func detachFlutter(moving: Bool = false) -> Bool {
    guard let controller = flutter, controller.parent === self else { flutter = nil; return false }
    retainedStatusBarStyle = controller.preferredStatusBarStyle
    if forwardingAppearance { controller.endAppearanceTransition(); forwardingAppearance = false; flutterAppeared = true }
    if forwardingDisappearance { controller.endAppearanceTransition(); forwardingDisappearance = false }
    let appeared = flutterAppeared
    if flutterAppeared, !moving {
        controller.beginAppearanceTransition(false, animated: false)
        controller.endAppearanceTransition()
    }
    flutterAppeared = false
    controller.willMove(toParent: nil)
    controller.view.removeFromSuperview()
    controller.removeFromParent()
    flutter = nil
    return appeared && moving
}
```

### Rule 8: one engine draws the sign-on page

Do not build it in the page and in the sheet. Here the page route `sign-in` exists for other platforms only, and iOS never reaches it.

## 9. Flutter facts checked at 3.47.0 and 3.50.0

- Scheduler (`packages/flutter/lib/src/scheduler/binding.dart`): `addPostFrameCallback` never schedules a frame. `endOfFrame` schedules one only when the scheduler is idle. `scheduleFrame()` does nothing while frames are disabled. Frames are disabled in the states `hidden`, `paused` and `detached`. The file differs between the two tags in formatting only.
- iOS view controller at 3.47.0 (`FlutterViewController.mm`): `viewWillAppear` reports `inactive` and re-creates the surface, `viewDidAppear` reports `resumed`, and `viewDidDisappear` destroys the surface and reports `paused`. The first surface is created at the first layout, once the view has a size and the app is active.
- `Shell::OnPlatformViewCreated` schedules a frame when a surface is created, in both versions.
- `FlutterEngineGroup.mm` is identical in both versions.
- The change between the tags that touches timing on iOS is the vsync and touch rework (flutter/flutter#191444). It targets touch latency.
- Ruled out: "Only render views that need to be rendered" (flutter/flutter#179874) is in neither release. It landed after 3.47.0 and was reverted before 3.50.0. The synchronous first-frame wait removed in flutter/flutter#190432 was already dead code.

## 10. What the first version of this note got wrong

- It read the black frames at the end of video 1 as padding and missed the second stage.
- It named one cause and a one-line fix, `ensureVisualUpdate()`. That call does nothing under candidate B, and it does not touch the black sheet.
- It had not measured the frozen page, the two-step bar changes or the one-second gap.
- It had not read this repository's history or the page-navigation code of the package.

---

# How this app opens the sign-in sheet

From the tap on the sign-in button to the sheet on screen. All code is copied from this project. In the excerpts, `// ...` marks lines left out.

## The path in one view

1. The button closes the drawer and calls `openSignIn`.
2. `openSignIn` calls `NativeSheet.show` with the route name `signIn`, the words of the current language and the bar's first title.
3. `NativeSheet.show` sends `present` to the native side. One call, at once.
4. The plugin hands the call to `NativeWidgetSheet`.
5. `present` starts a second engine at `commonSheetMain`, builds a hidden window and the sheet's view controllers, and fills the bar. Nothing is on screen yet.
6. The second engine starts and calls `bootstrap`.
7. The native side answers `bootstrap` and shows the sheet.
8. The sheet's engine builds the sign-in page.
9. The first frame reports `ready`, and the first page confirms its bar.

Nothing in steps 1 to 7 waits for a drawn frame or for a timer. The only wait is the drawer closing, capped at 350 ms.

## Set-up, done once

The sheet's engine has only the package's own plugin, so the app registers what its sheets need. `ios/Runner/AppDelegate.swift`, the whole file:

```swift
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
```

The second engine's entry point, in `lib/main.dart`:

```dart
/// Each native sheet runs in an engine of its own, started here.
@pragma('vm:entry-point')
void commonSheetMain() {
  _sharePdfium();
  runCommonSheetApp();
}
```

Every engine the package starts comes from one group, in `NativeOverlayContainer.swift`:

```swift
/// Engines the package starts beside the page's own: native sheets and the
/// overlay container. They spawn from one group, so each after the first
/// shares the group's loaded program instead of starting from nothing.
enum NativeEngines {
    static let group = FlutterEngineGroup(name: "flutter_native_widgets.engines", project: nil)
}
```

## Step 1: the tap

`lib/features/shell/widgets/keel_drawer.dart`. The drawer closes first. Sign-in then opens from the scaffold's context, which outlives the drawer.

```dart
final scaffold = NativeScaffold.of(context);

// The drawer's own context goes when it closes; pages are pushed from
// the scaffold's, which stays.
final host = scaffold.context;
final router = GoRouter.of(context);
final shellBloc = context.read<ShellBloc>();

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

What `closeDrawer` waits for, in `native_scaffold.dart`:

```dart
/// Completes when the open drawer has finished closing.
Completer<void>? _drawerClosed;

/// Closes the drawer without a selection. Completes once it has finished
/// closing, so a tap that also opens a page can wait for it: a page pushed
/// over a drawer still sliding away pauses it there until the page goes.
Future<void> closeDrawer() {
  if (!isDrawerOpen) return Future<void>.value();
  final closed = _drawerClosed ??= Completer<void>();
  if (_nativeDrawerOpen) {
    NativeDrawer.dismissNative();
  } else {
    _scaffoldKey.currentState?.closeDrawer();
  }
  return closed.future;
}

void _completeDrawerClosed() {
  _drawerClosed?.complete();
  _drawerClosed = null;
}
```

## Step 2: `openSignIn`

`lib/features/session/view/open_sign_in.dart`, the whole file. On iOS it asks for a full-screen native sheet and passes the bar's first title and close control, so the bar is complete before the sheet shows. Nothing is pushed in the page.

```dart
import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/app/sheet_arguments.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/features/session/bloc/biometric_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';

/// Opens sign-in: on iOS a native sheet that rises over the whole screen,
/// elsewhere a full-screen dialog page.
///
/// An account that signs in with Face ID or Touch ID is welcomed back
/// first; otherwise sign-in opens on username and password.
///
/// [title] and [homeTitle] are the sheet's first bar, the words its own
/// route sets (sign_in_route): [title] over sign-in, [homeTitle] on the
/// welcome back's close.
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
/// What a native sheet is opened with. On iOS a sheet runs in an engine of
/// its own, which cannot read the app's blocs, so the words of the language
/// the app speaks travel with the sheet's own value: the sheet starts at
/// once, without reading or unpacking the archive.
abstract final class SheetArguments {
  /// [value] with the app's words in the language it speaks under
  /// [context].
  static Map<String, Object?> wrap(BuildContext context, Object? value) {
    final localisation = context.read<LocalisationBloc>();
    return {
      'words': localisation.library.export(localisation.state.language),
      'value': value,
    };
  }

  /// The words [wrap] sent, ready for the sheet's own `LocalisationBloc`.
  static LocalisationBloc localisation(Object? arguments) {
    final library = LocaleLibrary.words(
      localeRegistry,
      (arguments as Map)['words'] as Object,
    );
    return LocalisationBloc.fixed(library: library, language: library.fallback);
  }

  static Object? value(Object? arguments) => (arguments as Map?)?['value'];
}
```

## Step 3: `NativeSheet.show` sends `present`

`packages/flutter_native_widgets/lib/src/overlays/native_sheet/native_sheet.dart`. One channel call, made at once. Its future completes only when the sheet closes.

```dart
static const _channel = MethodChannel('flutter_native_widgets/widget_sheet');
```

```dart
static Future<T?> show<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? route,
  Object? arguments,
  T Function(Object)? decodeResult,
  NativeFilterDetents detents = NativeFilterDetents.fit,
  bool fullScreen = false,
  bool isDismissible = true,
  Color? backgroundColor,
  bool navigationBar = false,
  Color? barColor,
  Color? barForeground,
  bool barShadow = false,
  bool plainBarButtons = false,
  TextStyle? barTitleStyle,
  String? barTitle,
  bool barClose = false,
  String? barCloseTitle,
}) async {
  final native = NativeStyle.of(context) == NativeStyle.native;
  // ...
  if (native) {
    if (route == null || route.isEmpty) {
      throw ArgumentError(
        'Native sheets require a route for commonSheetMain.',
      );
    }
    _servePage();
    // The page stays mounted with its own engine, metrics and native
    // controls. UIKit presents the sheet from a window of its own, above
    // the page's native bars; a full-screen one covers them as it slides
    // up (`.overFullScreen`).
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
      // A sheet follows the system's light and dark mode as it changes,
      // as the app's own pages do; only a forced mode pins it.
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
  // ...
```

## Step 4: the plugin routes the call

`FlutterNativeWidgetsPlugin.swift`:

```swift
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
    // ...
```

`NativeWidgetSheet.swift`:

```swift
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
        // ...
```

## Step 5: a second engine, a hidden window and a filled bar

`NativeWidgetSheet.swift`. Each sheet is a `Level`. Its initialiser makes the sheet's Flutter view controller, its navigation controller and the channel to its engine:

```swift
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
    channel = FlutterMethodChannel(name: "flutter_native_widgets/widget_sheet",
                                   binaryMessenger: engine.binaryMessenger)
    // Hold the presentation container rather than just the presented
    // view, so animations applied above the sheet also pause. This
    // container includes UIKit's dimming view as well as the sheet.
    turnHold = TurnHold { [weak controller] in
        controller?.presentationController?.containerView?.layer
    }
}
```

`present`, the whole function. It starts the engine, registers the plugins, builds the window and fills the bar. It shows nothing. Its two timers are deadlines for failure.

```swift
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
    controller.view.backgroundColor = UIColor.adaptive(
        args["backgroundColor"], dark: args["backgroundColorDark"]) ?? .systemBackground
    // Flutter draws the sheet's new size half way through a turn; until
    // then its last frame stays unscaled at the top left of the view
    // rather than stretching to the view's new bounds.
    controller.view.contentMode = .topLeft
    controller.view.addGestureRecognizer(level.scrollGuard)
    switch args["brightness"] as? String {
    case "dark": controller.overrideUserInterfaceStyle = .dark
    case "light": controller.overrideUserInterfaceStyle = .light
    default: controller.overrideUserInterfaceStyle = .unspecified
    }
    if let navigation = level.navigation {
        navigation.configure(
            color: (args["barColor"] as? NSNumber)?.intValue,
            darkColor: (args["barColorDark"] as? NSNumber)?.intValue,
            foreground: (args["barForeground"] as? NSNumber).map { UIColor(argb: $0.intValue) },
            shadow: args["barShadow"] as? Bool ?? false,
            plainButtons: args["plainButtons"] as? Bool ?? false,
            titleStyle: args["barTitleStyle"] as? [String: Any])
        navigation.send = { [weak level] method, arguments in
            level?.channel.invokeMethod(method, arguments: arguments)
        }
        navigation.overrideUserInterfaceStyle = controller.overrideUserInterfaceStyle
        navigation.view.backgroundColor = controller.view.backgroundColor
        // The first page's bar before the sheet shows: on an iPhone Duo an
        // empty bar has no title band, which would appear a moment later.
        if let bar = args["bar"] as? [String: Any] {
            navigation.setBar(bar)
        }
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
                + "The app's main.dart must define `@pragma('vm:entry-point') void commonSheetMain()`, "
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
```

The sheet's bar is a real navigation controller around the Flutter view. From `SheetNavigationController` in the same file:

```swift
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
// ...
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
// ...
func setBar(_ args: [String: Any]) {
    guard let page = front else { return }
    // The same bar again, such as the first page confirming what the
    // sheet was shown with: keep the items already on screen.
    if page === barPage, let last = barArgs,
       NSDictionary(dictionary: last).isEqual(to: args) {
        return
    }
    barPage = page
    barArgs = args
    configureItems(of: page, args, back: viewControllers.count > 1)
}
// ...
private func configureItems(of page: SheetPageController, _ args: [String: Any],
                            back: Bool) {
    let item = page.navigationItem
    item.title = args["title"] as? String
    item.hidesBackButton = true
    item.leftBarButtonItem = back
        ? button("chevron.backward", "Back") { [weak self] in self?.goBack() }
        : nil
    let close: () -> Void = { [weak self] in self?.send?("barAction", ["id": "close"]) }
    var trailing: [UIBarButtonItem] = []
    if args["close"] as? Bool != true {
    } else if let title = args["closeTitle"] as? String {
        // Leaving named in words, such as going home without signing in.
        trailing.append(UIBarButtonItem(
            title: title, image: nil, primaryAction: UIAction { _ in close() }, menu: nil))
    } else {
        trailing.append(button("xmark", "Close", close))
    }
    // The page's own control, such as going back a step in a flow.
    if let action = args["action"] as? [String: Any],
       let symbol = action["symbol"] as? String {
        trailing.append(button(symbol, action["label"] as? String ?? "") { [weak self] in
            self?.send?("barAction", ["id": "action"])
        })
    }
    item.rightBarButtonItems = trailing.isEmpty ? nil : trailing
    styleButtons()
}

private func button(_ symbol: String, _ label: String,
                    _ action: @escaping () -> Void) -> UIBarButtonItem {
    let item = UIBarButtonItem(title: nil, image: UIImage(systemName: symbol),
                               primaryAction: UIAction { _ in action() }, menu: nil)
    item.accessibilityLabel = label
    return item
}
```

At this point the engine is starting, the window exists and the bar reads its title. Nothing is on screen yet.

## Step 6: the second engine starts and calls `bootstrap`

`lib/app/common_sheet_app.dart`:

```dart
/// The root of a native sheet's own engine. Blocs and closures cannot cross
/// engines, so each sheet gets plain values in and hands plain values back.
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

`NativeSheet.bootstrap`, in `native_sheet.dart`:

```dart
/// Called once by `commonSheetMain`, before building the sheet app.
///
/// The returned map contains `route`, `arguments`, `detents`,
/// `backgroundColor` and `brightness`. [encodeResult] converts the value
/// passed to [pop] into StandardMessageCodec-compatible data.
///
/// Until [NativeSheetContent] reports its first frame, an uncaught
/// error in this isolate, or a first frame without that content, fails the
/// caller's [show] at once with the error instead of leaving it waiting.
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

## Step 7: the native side answers, then shows the sheet

`NativeWidgetSheet.swift`. The sheet is shown here, as soon as its engine is alive, on the next turn of the main queue. It does not wait for a drawn frame.

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

`presentLevel`, the whole function:

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
```

The sheet is now sliding up with its bar and its background colour. Its Flutter view is in a window, so it has a surface, and the content follows in the next step.

## Step 8: the sheet's engine builds the sign-in page

`lib/app/common_sheet_app.dart`. The sheet speaks the language it was handed, and the `signIn` route gets an app of its own:

```dart
@override
Widget build(BuildContext context) => BlocProvider(
  // The sheet speaks the language the app spoke when it opened it.
  create: (_) => SheetArguments.localisation(configuration['arguments']),
  child: _sheet(context),
);

Widget _sheet(BuildContext context) {
  // The app's forced mode, or the system's as it changes: the sheet's
  // window follows the system live, and this rebuilds with it.
  final brightness = switch (configuration['brightness']) {
    'dark' => Brightness.dark,
    'light' => Brightness.light,
    _ => MediaQuery.platformBrightnessOf(context),
  };
  final theme = brightness == Brightness.dark
      ? KeelTheme.dark
      : KeelTheme.light;
  final background =
      (brightness == Brightness.dark
              ? configuration['backgroundColorDark']
              : null)
          as int? ??
      configuration['backgroundColor'] as int?;

  Widget themed(BuildContext context, Widget child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(platformBrightness: brightness),
    child: NativeTheme(
      data: theme,
      child: Theme(data: theme.material(brightness), child: child),
    ),
  );

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
  // ...
```

That app has its own router, so Register and the forgotten-password pages push inside the sheet:

```dart
/// The sign-in sheet: its own router, so Register and the forgotten
/// username and password pages push inside the sheet and come back to it.
///
/// With a [biometric] account it opens on the welcome back; signing in with
/// a password pushes onto the same stack from there.
class _SignInSheetApp extends StatefulWidget {
  const _SignInSheetApp({
    required this.biometric,
    required this.theme,
    required this.themed,
    required this.background,
  });

  final BiometricAccount? biometric;
  final CupertinoThemeData theme;
  final Widget Function(BuildContext, Widget) themed;
  final Color? background;

  @override
  State<_SignInSheetApp> createState() => _SignInSheetAppState();
}

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

`lib/features/session/view/sign_in_route.dart`. The route builds `SignInPage`, wrapped so that the native bar follows it:

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
  // ...
```

```dart
Page<void> _page(
  GoRouterState state, {
  required bool sheet,
  required FlowWords? title,
  required Widget child,
  bool first = false,
  FlowWords? closeTitle,
}) {
  Widget worded(Widget Function(String? title, String? closeTitle) build) =>
      LocalisedBuilder.namespaces(
        namespaces: _barNamespaces,
        builder: (context, locale) {
          final session = locale[0] as SessionLocale;
          final account = locale[1] as AccountLocale;
          return build(
            title?.call(session, account),
            closeTitle?.call(session, account),
          );
        },
      );

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
  // ...
```

## Step 9: the first frame reports `ready`, and the page confirms its bar

`NativeSheetContent` in `native_sheet.dart`:

```dart
void _scheduleMeasurement() {
  if (_measureScheduled) return;
  _measureScheduled = true;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    _measureScheduled = false;
    if (!mounted) return;
    if (widget.fits) {
      final box = _contentKey.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize && box.size.height.isFinite) {
        final height = box.size.height;
        if (_height == null || (height - _height!).abs() >= 0.5) {
          _height = height;
          _heightTimer?.cancel();
          if (!_ready) {
            _reportHeight(height);
          } else {
            _heightTimer = Timer(
              const Duration(milliseconds: 40),
              () => _reportHeight(height),
            );
          }
        }
      }
    }
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
// ...
static Future<void> _send(String method, [Object? arguments]) async {
  try {
    await _channel.invokeMethod<void>(method, arguments);
  } on PlatformException {
    // The native side has already closed this sheet.
  } on MissingPluginException {
    // Not a sheet engine.
  }
}
```

`NativeWidgetSheet.swift`:

```swift
case "ready":
    guard let source else { result(FlutterMethodNotImplemented); return }
    source.ready = true
    source.cancelStartupWork()
    result(nil)
```

This post-frame callback is safe for two reasons:

- It is registered while the first frame is being built, and `runApp` requests that frame itself.
- Nothing visible waits on it. The sheet is already on screen from step 7. `ready` only cancels the start-up deadlines.

The first page then confirms its bar. `lib/features/session/widgets/sheet_bar_binder.dart`:

```dart
@override
Widget build(BuildContext context) {
  // Rebuilds when the page comes to the front again after a pop.
  final current = ModalRoute.of(context)?.isCurrent ?? true;
  if (current && !_current) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _arrive());
  }
  _current = current;
  return widget.child;
}

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

void _setBar() => NativeSheet.setBar(
  title: widget.title,
  onClose: widget.onClose,
  closeTitle: widget.closeTitle,
  action: widget.action?.value,
);
```

`NativeSheet.setBar`, in `native_sheet.dart`:

```dart
static void setBar({
  String? title,
  VoidCallback? onClose,
  String? closeTitle,
  NativeSheetBarAction? action,
}) {
  if (!_hosted) return;
  _barClose = onClose;
  _barAction = action?.onPressed;
  unawaited(_send('setBar', _bar(title, onClose, closeTitle, action)));
}

static Map<String, Object?> _bar(
  String? title,
  VoidCallback? onClose,
  String? closeTitle,
  NativeSheetBarAction? action,
) => {
  'title': title,
  'close': onClose != null,
  if (closeTitle != null) 'closeTitle': closeTitle,
  if (action != null)
    'action': {'symbol': action.sfSymbol, 'label': action.label},
};
```

The words match what step 5 already set, so the bar does not change. The sheet is shown.

## After it is shown

Signing in calls `NativeSheet.pop(context, name)`. The sheet closes, the `present` call from step 3 completes with the name, and `openSignIn` adds `SessionSignedIn(name)`.
