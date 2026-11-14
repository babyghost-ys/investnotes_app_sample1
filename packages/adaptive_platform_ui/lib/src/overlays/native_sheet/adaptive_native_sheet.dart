import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:developer' as developer;
import 'dart:io' show WebSocket;
import 'dart:math' as math;
import 'dart:ui' show ErrorCallback, PlatformDispatcher;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart'
    show
        FlutterError,
        FlutterErrorDetails,
        FlutterExceptionHandler,
        ValueListenable,
        debugPrint,
        kReleaseMode;
import 'package:material_ui/material_ui.dart'
    show
        MaterialPageRoute,
        ModalBottomSheetRoute,
        PopScope,
        kMinInteractiveDimension;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/adaptive_style.dart';
import '../../devices/duo/duo_layout.dart';
import '../../devices/duo/system_vertical_bar.dart';
import '../../navigation/app_bar/native_toolbar.dart';
import '../../navigation/chrome/hosted_top_toolbar.dart';
import '../../navigation/chrome/toolbar_registry.dart';
import '../bottom_sheet/adaptive_bottom_sheet.dart';
import '../filter_sheet/adaptive_filter_sheet.dart';

/// A sheet that hosts any widget, with native platform views inside it.
///
/// On iOS the sheet is a real UIKit sheet with its own Flutter engine: [show]
/// sends [route] and codec-safe [arguments] to the app's `nativeSheetMain`
/// entrypoint, which calls [bootstrap] and builds the route inside
/// [AdaptiveNativeSheetContent]. UIKit owns the grabber, detents, dimming and
/// drag dismissal, and hides the sheet while the screen turns (see
/// `docs/sheet-rotation-cut-failed-attempts.md`). Widgets, closures and
/// notifiers cannot cross engines, so [decodeResult] restores the result in
/// the caller.
///
/// A [fullScreen] sheet is the same engine in UIKit's `.overFullScreen`
/// presentation, which slides up over the native bars.
///
/// Elsewhere [builder] supplies the content in the caller's isolate as a
/// Flutter route.
class AdaptiveNativeSheet {
  AdaptiveNativeSheet._();

  static const _channel = MethodChannel('adaptive_platform_ui/widget_sheet');
  static bool _servingPage = false;
  static bool _hosted = false;
  static bool _closing = false;
  static Object? Function(Object?) _encodeResult = (value) => value;
  static bool _startupReported = false;
  static String? _firstError;
  static FlutterExceptionHandler? _previousFlutterError;
  static VoidCallback? _barClose;

  /// Called when the sheet's navigation popped its page in front by back or
  /// swipe: the page's Flutter route should pop, without a transition.
  static VoidCallback? onPagePopped;
  static ErrorCallback? _previousPlatformError;

  static final Set<Route<Object?>> _leavingRoutes = <Route<Object?>>{};
  static final ValueNotifier<bool> _leaving = ValueNotifier(false);

  /// True while a sheet shown by [show] slides away after it was popped.
  ///
  /// The page under it is current again from the moment of the pop, so its
  /// native tab bar would come back over the sheet as it slides down. The
  /// scaffold keeps the tab bar away until this is false.
  static ValueListenable<bool> get leaving => _leaving;

  static void _watchLeaving(TransitionRoute<Object?> route) {
    route.animation?.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.reverse:
          _leavingRoutes.add(route);
        case AnimationStatus.dismissed:
          _leavingRoutes.remove(route);
        case AnimationStatus.forward:
        case AnimationStatus.completed:
          return;
      }
      _leaving.value = _leavingRoutes.isNotEmpty;
    });
  }

  /// Called once by `nativeSheetMain`, before building the sheet app.
  ///
  /// The returned map contains `route`, `arguments`, `detents`,
  /// `backgroundColor` and `brightness`. [encodeResult] converts the value
  /// passed to [pop] into StandardMessageCodec-compatible data.
  ///
  /// Until [AdaptiveNativeSheetContent] reports its first frame, an uncaught
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

  /// Keeps the first framework error for the failure message, fails startup
  /// on an uncaught error, and checks the first frame built after `runApp`.
  static void _watchStartup() {
    _previousFlutterError = FlutterError.onError;
    FlutterError.onError = _keepFirstError;
    final dispatcher = PlatformDispatcher.instance;
    _previousPlatformError = dispatcher.onError;
    dispatcher.onError = _failOnUncaught;
    _checkFirstFrame();
  }

  static void _keepFirstError(FlutterErrorDetails details) {
    _firstError ??= details.exceptionAsString();
    _previousFlutterError?.call(details);
  }

  static bool _failOnUncaught(Object error, StackTrace stack) {
    _failStartup('$error');
    return _previousPlatformError?.call(error, stack) ?? false;
  }

  static void _restoreErrorHandlers() {
    // App code may have installed its own handlers since; those stay.
    if (FlutterError.onError == _keepFirstError) {
      FlutterError.onError = _previousFlutterError;
    }
    final dispatcher = PlatformDispatcher.instance;
    if (dispatcher.onError == _failOnUncaught) {
      dispatcher.onError = _previousPlatformError;
    }
  }

  /// Fails startup when the first frame built after `runApp` holds no
  /// [AdaptiveNativeSheetContent], or was built with an error.
  static void _checkFirstFrame() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // The content's ready report is a later post-frame callback of the
      // same frame; all of them run before this microtask.
      scheduleMicrotask(() {
        if (_startupReported) return;
        if (WidgetsBinding.instance.rootElement == null) {
          // A frame before runApp, such as one forced by new view metrics.
          _checkFirstFrame();
          return;
        }
        _failStartup(
          _firstError ?? 'The first frame built no AdaptiveNativeSheetContent.',
        );
      });
    });
  }

  /// Inside a full-screen sheet shown with `navigationBar`, what the bar
  /// shows for the page in front: [title], and a close control when
  /// [onClose] is given. Back appears on its own once a page has been
  /// pushed. UIKit lays the bar out for the device, across the top or, on an
  /// iPhone Duo, in the system's vertical bar. Does nothing elsewhere.
  ///
  /// The sheet's pages push as whole native pages, bar and all:
  /// [preparePush] before the Flutter route is pushed (without a
  /// transition), then [pushPage] once the new page has drawn. A pop by back
  /// or swipe calls [onPagePopped]; a pop of Flutter's own goes through
  /// [popPage] first. Either way the page now in front calls [revealPage]
  /// once it has drawn again.
  ///
  /// The close control is an xmark, or [closeTitle] in words when given.
  static void setBar({
    String? title,
    VoidCallback? onClose,
    String? closeTitle,
  }) {
    if (!_hosted) return;
    _barClose = onClose;
    unawaited(_send('setBar', _bar(title, onClose, closeTitle)));
  }

  static Map<String, Object?> _bar(
    String? title,
    VoidCallback? onClose,
    String? closeTitle,
  ) => {
    'title': title,
    'close': onClose != null,
    if (closeTitle != null) 'closeTitle': closeTitle,
  };

  /// Covers the page in front with a picture of itself, so the next page
  /// can be drawn beneath it unseen.
  static Future<void> preparePush() async {
    if (_hosted) await _send('preparePush');
  }

  /// UIKit pushes a new page showing what Flutter now draws.
  static void pushPage({
    String? title,
    VoidCallback? onClose,
    String? closeTitle,
  }) {
    if (!_hosted) return;
    _barClose = onClose;
    unawaited(_send('pushPage', _bar(title, onClose, closeTitle)));
  }

  /// UIKit pops the page in front; completes once it has, for the Flutter
  /// route to follow.
  static Future<void> popPage() async {
    if (_hosted) await _send('popPage');
  }

  /// The page in front has drawn again after a pop: its picture lifts.
  static void revealPage() {
    if (_hosted) unawaited(_send('revealPage'));
  }

  /// The content built its first frame: the native side stops waiting.
  static void _reportReady() {
    if (!_hosted || _startupReported) return;
    _startupReported = true;
    _restoreErrorHandlers();
    unawaited(_send('ready'));
  }

  /// The isolate cannot show its sheet: the caller's [show] fails at once
  /// with [message].
  static void _failStartup(String message) {
    if (!_hosted || _startupReported) return;
    _startupReported = true;
    _restoreErrorHandlers();
    unawaited(_send('failed', {'message': message}));
  }

  static Future<void> _send(String method, [Object? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException {
      // The native side has already closed this sheet.
    } on MissingPluginException {
      // Not a sheet engine.
    }
  }

  /// Shows the sheet and completes after it has been dismissed, with the
  /// value given to [pop], or null when it was dragged away or tapped
  /// outside.
  ///
  /// A [fullScreen] sheet covers the whole screen and, like an [isDismissible]
  /// `false` sheet, only closes through [pop]; [detents] and [isDismissible]
  /// do not apply to it. On iOS [route] is required and [arguments] must be
  /// StandardMessageCodec data.
  ///
  /// A [fullScreen] sheet with [navigationBar] sits in a native navigation
  /// controller, so UIKit draws its bar where the device keeps one: across
  /// the top, or on an iPhone Duo in the system's vertical bar. The bar is
  /// [barColor] with [barForeground] controls, plain across the top when
  /// [plainBarButtons], its titles in [barTitleStyle] (family, size and
  /// weight; a font from Flutter assets needs
  /// [AdaptiveNativeFonts.registerAssets] first). The sheet's pages fill
  /// it in through [setBar].
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? route,
    Object? arguments,
    T Function(Object)? decodeResult,
    AdaptiveFilterDetents detents = AdaptiveFilterDetents.fit,
    bool fullScreen = false,
    bool isDismissible = true,
    Color? backgroundColor,
    bool navigationBar = false,
    Color? barColor,
    Color? barForeground,
    bool plainBarButtons = false,
    TextStyle? barTitleStyle,
  }) async {
    final native = AdaptiveStyle.of(context) == AdaptiveStyle.native;
    if (fullScreen && !native) {
      // An opaque page on the root navigator. With native bars it would slide
      // up beneath them, so a native page presents it from UIKit instead.
      return Navigator.of(context, rootNavigator: true).push<T>(
        MaterialPageRoute<T>(
          fullscreenDialog: true,
          builder: (context) => PopScope(
            canPop: false,
            child: ColoredBox(
              color:
                  backgroundColor ??
                  CupertinoColors.systemBackground.resolveFrom(context),
              child: builder(context),
            ),
          ),
        ),
      );
    }
    if (native) {
      if (route == null || route.isEmpty) {
        throw ArgumentError(
          'Native sheets require a route for nativeSheetMain.',
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
        'backgroundColor':
            (backgroundColor ??
                    CupertinoColors.systemBackground.resolveFrom(context))
                .toARGB32(),
        'brightness': CupertinoTheme.brightnessOf(context).name,
        if (fullScreen && navigationBar) ...{
          'navigationBar': true,
          'barColor': ?barColor?.toARGB32(),
          'barForeground': ?barForeground?.toARGB32(),
          'plainButtons': plainBarButtons,
          if (barTitleStyle != null)
            'barTitleStyle': {
              'fontFamily': barTitleStyle.fontFamily,
              'fontSize': barTitleStyle.fontSize,
              'fontWeight': barTitleStyle.fontWeight?.value,
            },
        },
      });
      if (value == null) return null;
      return decodeResult == null ? value as T : decodeResult(value);
    }
    // Elsewhere the sheet is Flutter's own modal bottom sheet on the root
    // navigator.
    final fill =
        backgroundColor ??
        CupertinoColors.systemBackground.resolveFrom(context);
    if (detents == AdaptiveFilterDetents.fit) {
      // `showModalBottomSheet` with its route in hand, so the tab bar can
      // wait for the sheet to slide away (see [leaving]).
      final navigator = Navigator.of(context, rootNavigator: true);
      final route = ModalBottomSheetRoute<T>(
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: isDismissible,
        enableDrag: isDismissible,
        isDismissible: isDismissible,
        backgroundColor: fill,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        barrierLabel: 'Dismiss',
        builder: (context) => PopScope(
          canPop: isDismissible,
          child: _BelowNativeBars(
            handle: isDismissible,
            child: ValueListenableBuilder<bool>(
              valueListenable: _leaving,
              builder: (context, leaving, child) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [Flexible(child: child!)],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: builder(context),
              ),
            ),
          ),
        ),
      );
      final result = navigator.push<T>(route);
      _watchLeaving(route);
      return result;
    }
    return AdaptiveBottomSheet.show<T>(
      context: context,
      builder: builder,
      heightFactor: switch (detents) {
        AdaptiveFilterDetents.short => 0.34,
        AdaptiveFilterDetents.full => 0.94,
        AdaptiveFilterDetents.halfAndFull || AdaptiveFilterDetents.fit => 0.5,
      },
      expandedHeightFactor: detents == AdaptiveFilterDetents.halfAndFull
          ? 0.94
          : null,
      backgroundColor: fill,
      isDismissible: isDismissible,
    );
  }

  /// Answers the native side's requests to this isolate.
  static void _servePage() {
    if (_servingPage) return;
    _servingPage = true;
    _channel.setMethodCallHandler(_handleCall);
  }

  /// The native side's requests to this isolate: as a page, to resume a
  /// sheet isolate; as a sheet, a tap on its navigation bar.
  static Future<Object?> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'resumeIsolate':
        final arguments = call.arguments as Map<Object?, Object?>;
        return _resumeIsolatePausedAtStart(
          arguments['isolateId']! as String,
          arguments['route'] as String?,
        );
      case 'barAction':
        final arguments = call.arguments as Map<Object?, Object?>;
        if (arguments['id'] == 'close') _barClose?.call();
        return null;
      case 'pagePopped':
        onPagePopped?.call();
        return null;
      default:
        throw MissingPluginException();
    }
  }

  /// Resumes the sheet isolate [isolateId] when a debugger left it paused at
  /// start, through the VM service that serves this app, so the sheet shows
  /// whichever debugger launched the app. Only an isolate paused at start is
  /// touched: one at a breakpoint or an exception stays with its developer.
  ///
  /// Returns `resumed`, or what the VM service reports instead: the
  /// isolate's pause event kind (`Resume` for a running isolate, `None` for
  /// one still loading after [_firstPauseWait]), `gone` for one that no
  /// longer exists, `unreachable` when the service address could not be
  /// reached (a physical device under an IDE debug session, where the
  /// address is the host's), `error` for a failed request, `no-service`
  /// without a VM service, and `release` in a release build, which has none.
  static Future<String> _resumeIsolatePausedAtStart(
    String isolateId,
    String? route,
  ) async {
    if (kReleaseMode) return 'release';
    final Uri? uri;
    try {
      uri = (await developer.Service.getInfo()).serverWebSocketUri;
    } on Object {
      return 'no-service';
    }
    if (uri == null) return 'no-service';
    final WebSocket socket;
    try {
      socket = await WebSocket.connect(
        uri.toString(),
      ).timeout(_VmService.timeout);
    } on Object {
      return 'unreachable';
    }
    final service = _VmService(socket);
    try {
      var kind = await _pauseKind(service, isolateId);
      // A new isolate reaches its pause at start only once its program has
      // loaded, which an early request can beat; `None` says it is on its way.
      final deadline = DateTime.now().add(_firstPauseWait);
      while (kind == 'None' && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        kind = await _pauseKind(service, isolateId);
      }
      if (kind != 'PauseStart') return kind;
      await service.call('resume', {'isolateId': isolateId});
    } on Object {
      return 'error';
    } finally {
      await service.close();
    }
    debugPrint(
      'adaptive_platform_ui: resumed the sheet isolate for route "$route" '
      '($isolateId), which the debugger had left paused at start.',
    );
    return 'resumed';
  }

  /// How long a new isolate may take to reach its pause at start.
  static const _firstPauseWait = Duration(seconds: 1);

  /// The kind of [isolateId]'s last pause event (`None` before the first,
  /// `PauseStart` while paused at start, `Resume` once running), or `gone`
  /// for an isolate that no longer exists.
  static Future<String> _pauseKind(_VmService service, String isolateId) async {
    final isolate = await service.call('getIsolate', {'isolateId': isolateId});
    final pause = isolate['pauseEvent'];
    if (pause is! Map) return 'gone';
    final kind = pause['kind'];
    return kind is String ? kind : 'error';
  }

  /// Closes the sheet [context] is in, completing its [show] with [value].
  static Future<void> pop<T>(BuildContext context, [T? value]) async {
    if (!_hosted) {
      Navigator.of(context).pop<T>(value);
      return;
    }
    if (_closing) return;
    _closing = true;
    try {
      await _channel.invokeMethod<void>('dismiss', {
        'value': _encodeResult(value),
      });
    } finally {
      _closing = false;
    }
  }
}

/// A JSON-RPC client for the VM service, enough to inspect and resume one
/// isolate.
class _VmService {
  _VmService(this._socket) {
    _subscription = _socket.listen(_onMessage, onDone: _fail, onError: _fail);
  }

  static const timeout = Duration(seconds: 3);

  final WebSocket _socket;
  late final StreamSubscription<Object?> _subscription;
  final _pending = <int, Completer<Map<String, Object?>>>{};
  var _nextId = 1;

  Future<Map<String, Object?>> call(
    String method,
    Map<String, Object?> params,
  ) {
    final id = _nextId++;
    final completer = Completer<Map<String, Object?>>();
    _pending[id] = completer;
    _socket.add(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        'params': params,
      }),
    );
    return completer.future.timeout(timeout);
  }

  void _onMessage(Object? message) {
    if (message is! String) return;
    final decoded = jsonDecode(message);
    if (decoded is! Map) return;
    final completer = _pending.remove(decoded['id']);
    if (completer == null) return;
    final error = decoded['error'];
    if (error != null) {
      completer.completeError(StateError('$error'));
      return;
    }
    final result = decoded['result'];
    completer.complete(
      result is Map ? result.cast<String, Object?>() : <String, Object?>{},
    );
  }

  void _fail([Object? error, StackTrace? stack]) {
    for (final completer in _pending.values) {
      completer.completeError(error ?? StateError('The VM service closed.'));
    }
    _pending.clear();
  }

  Future<void> close() async {
    await _subscription.cancel();
    try {
      await _socket.close();
    } on Object {
      // Already closed by the other side.
    }
    _fail();
  }
}

/// Sheet content in its dedicated engine. UIKit supplies the real sheet,
/// grabber, detents, dimming and dismissal gestures.
///
/// Fit content scrolls once its natural height exceeds the native detent.
/// Safe areas come from this sheet's FlutterView, never from the page behind it.
class AdaptiveNativeSheetContent extends StatefulWidget {
  const AdaptiveNativeSheetContent({
    super.key,
    required this.child,
    this.fits = true,
    this.backgroundColor,
  });

  final Widget child;
  final bool fits;
  final Color? backgroundColor;

  @override
  State<AdaptiveNativeSheetContent> createState() =>
      _AdaptiveNativeSheetContentState();
}

class _AdaptiveNativeSheetContentState
    extends State<AdaptiveNativeSheetContent> {
  final _contentKey = GlobalKey();
  Timer? _heightTimer;
  double? _height;
  bool _measureScheduled = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _scheduleMeasurement();
  }

  @override
  void dispose() {
    _heightTimer?.cancel();
    super.dispose();
  }

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
        AdaptiveNativeSheet._reportReady();
      }
    });
  }

  void _reportHeight(double height) {
    unawaited(
      AdaptiveNativeSheet._channel.invokeMethod<void>('setHeight', {
        'height': height,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasurement();
    return ColoredBox(
      color:
          widget.backgroundColor ??
          CupertinoColors.systemBackground.resolveFrom(context),
      child: widget.fits
          ? NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (_) {
                _scheduleMeasurement();
                return false;
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SizeChangedLayoutNotifier(
                  child: KeyedSubtree(key: _contentKey, child: widget.child),
                ),
              ),
            )
          : widget.child,
    );
  }
}

/// Gap between the sheet's top and the native bar above it.
const double _inset = 8;

/// Caps a fit sheet's content so the sheet's top stays below the native bars
/// over the page, which UIKit draws above everything Flutter draws; taller
/// content scrolls. UIKit moves the bars when the screen turns, and the cap
/// follows them.
class _BelowNativeBars extends StatelessWidget {
  const _BelowNativeBars({required this.handle, required this.child});

  /// Whether the sheet shows Material's drag handle above [child].
  final bool handle;
  final Widget child;

  /// How far down the screen the native bars over the covered page reach:
  /// its navigation bar, with any large title, or on iPhone Duo the title
  /// band. Only the status bar when the page shows no native bar.
  double _barsBottom(BuildContext context, TopToolbarContent bar) {
    // The sheet's route has taken the status bar out of its padding.
    final statusBar = MediaQueryData.fromView(View.of(context)).viewPadding.top;
    if (DuoPoseScope.of(context) != null) {
      return SystemVerticalBar.titleBand.value?.contentTop ??
          statusBar + kMinInteractiveDimensionCupertino;
    }
    if (ToolbarRegistry.maybeOf(context) == null) {
      return nativeNavigationBarBottom.value ?? statusBar;
    }
    if (bar.isEmpty) return statusBar;
    return bar.scrollController?.navigationBarBottom.value ??
        nativeNavigationBarBottom.value ??
        statusBar + kHostedToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    // While a sheet covers it, the page in front keeps owning the bar.
    final bar = TopToolbarContent.of(ToolbarRegistry.maybeOf(context)?.owner);
    final barBottom = bar.scrollController?.navigationBarBottom;
    return ListenableBuilder(
      listenable: Listenable.merge([
        nativeNavigationBarBottom,
        SystemVerticalBar.titleBand,
        if (barBottom != null) barBottom,
      ]),
      builder: (context, _) {
        final media = MediaQuery.of(context);
        // The sheet's drag handle sits above the content and takes a row.
        final handleHeight = handle ? kMinInteractiveDimension : 0.0;
        final room = math.max(
          0.0,
          media.size.height -
              media.viewInsets.bottom -
              _barsBottom(context, bar) -
              _inset -
              handleHeight,
        );
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: room),
          child: child,
        );
      },
    );
  }
}
