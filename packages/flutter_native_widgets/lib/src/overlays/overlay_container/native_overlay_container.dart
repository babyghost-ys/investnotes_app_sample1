import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show AppBarTheme, Theme, kToolbarHeight;

import '../../core/platform_info.dart';

/// Builds the content of a [NativeOverlayContainer] strip for [route].
typedef NativeOverlayBuilder =
    Widget Function(BuildContext context, String route, Object? arguments);

/// What a [NativeOverlayContainer] strip shows.
@immutable
class NativeOverlayRequest {
  const NativeOverlayRequest({
    required this.route,
    required this.color,
    this.arguments,
  });

  factory NativeOverlayRequest.decode(Map<Object?, Object?> data) =>
      NativeOverlayRequest(
        route: data['route']! as String,
        color: Color(data['color']! as int),
        arguments: data['arguments'],
      );

  final String route;

  /// The strip's background, shown before its content's first frame too.
  final Color color;

  /// Codec-safe values for the content: on iOS they cross engines.
  final Object? arguments;

  Map<String, Object?> encode() => {
    'route': route,
    'color': color.toARGB32(),
    'arguments': arguments,
  };
}

/// A strip of app content laid exactly over the navigation bar, directly
/// below the status bar, at the bar's own height. Nothing below it moves.
///
/// The height is never given: on iOS it is measured from UIKit's bar (or, on
/// an iPhone Duo with the bar in the vertical strip, from the band UIKit
/// keeps for an inline title); elsewhere it is the Material app bar's.
///
/// On iOS the navigation bar is UIKit's and sits above the page's Flutter
/// view, so the strip is a native container with an engine of its own: the
/// app's `commonOverlayMain` entrypoint calls [run] with a builder. The
/// engine starts on the first [show] and stays warm afterwards. Like native
/// sheets, it runs the program as built, so a change to the content needs a
/// relaunch in Debug.
///
/// Elsewhere [NativeApp] lays the strip above its navigator in this isolate,
/// with the builder given to [builder].
///
/// ```dart
/// NativeOverlayContainer.builder = buildCommonOverlay; // in main()
///
/// @pragma('vm:entry-point')
/// void commonOverlayMain() => NativeOverlayContainer.run(buildCommonOverlay);
/// ```
abstract final class NativeOverlayContainer {
  static const _channel = MethodChannel(
    'flutter_native_widgets/overlay_container',
  );
  static const _contentChannel = MethodChannel(
    'flutter_native_widgets/overlay_content',
  );

  static final ValueNotifier<NativeOverlayRequest?> _current = ValueNotifier(
    null,
  );

  /// Builds the strip in this isolate where it is not native (not iOS).
  static NativeOverlayBuilder? builder;

  /// The strip shown in this isolate, or null. Never set on iOS.
  static ValueListenable<NativeOverlayRequest?> get current => _current;

  static bool get _native => PlatformInfo.isIOS;

  /// Shows the strip, or changes what it shows.
  static Future<void> show(
    String route, {
    required Color color,
    Object? arguments,
  }) async {
    final request = NativeOverlayRequest(
      route: route,
      color: color,
      arguments: arguments,
    );
    if (_native) {
      await _channel.invokeMethod<void>('show', request.encode());
    } else {
      _current.value = request;
    }
  }

  /// Hides the strip and gives the pages their space back.
  static Future<void> hide() async {
    if (_native) {
      await _channel.invokeMethod<void>('hide');
    } else {
      _current.value = null;
    }
  }

  /// Runs the strip's own engine (iOS): call it from `commonOverlayMain`.
  static Future<void> run(NativeOverlayBuilder builder) async {
    WidgetsFlutterBinding.ensureInitialized();
    final data = await _contentChannel.invokeMapMethod<Object?, Object?>(
      'bootstrap',
    );
    if (data == null || data['route'] == null) return;
    final request = ValueNotifier(NativeOverlayRequest.decode(data));
    _contentChannel.setMethodCallHandler((call) async {
      if (call.method == 'update') {
        request.value = NativeOverlayRequest.decode(
          call.arguments as Map<Object?, Object?>,
        );
      }
    });
    runApp(_OverlayRoot(request: request, builder: builder));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _contentChannel.invokeMethod<void>('ready');
    });
  }
}

class _OverlayRoot extends StatelessWidget {
  const _OverlayRoot({required this.request, required this.builder});

  final ValueListenable<NativeOverlayRequest> request;
  final NativeOverlayBuilder builder;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: ValueListenableBuilder<NativeOverlayRequest>(
      valueListenable: request,
      builder: (context, request, _) => ColoredBox(
        color: request.color,
        child: builder(context, request.route, request.arguments),
      ),
    ),
  );
}

/// Lays the strip of a [NativeOverlayContainer] over [child], directly below
/// the status bar, where it is not native. [NativeApp] adds this.
///
/// The strip slides down out from under the status bar and back up again.
class NativeOverlayHost extends StatefulWidget {
  const NativeOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  State<NativeOverlayHost> createState() => _NativeOverlayHostState();
}

class _NativeOverlayHostState extends State<NativeOverlayHost> {
  /// What the strip last showed, kept while it slides away.
  NativeOverlayRequest? _last;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<NativeOverlayRequest?>(
        valueListenable: NativeOverlayContainer.current,
        // The navigator keeps its place in the tree whether the strip shows.
        child: widget.child,
        builder: (context, request, child) {
          final builder = NativeOverlayContainer.builder;
          final shown = request ?? _last;
          if (request != null) _last = request;
          final media = MediaQuery.of(context);
          return Stack(
            fit: StackFit.expand,
            children: [
              child!,
              if (shown != null && builder != null)
                Positioned(
                  top: media.padding.top,
                  left: media.padding.left,
                  right: media.padding.right,
                  height:
                      AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight,
                  child: ClipRect(
                    child: TweenAnimationBuilder<double>(
                      // Starts above the band, hidden by the clip.
                      tween: Tween(begin: -1, end: request != null ? 0 : -1),
                      duration: const Duration(milliseconds: 300),
                      curve: request != null
                          ? Curves.easeOutCubic
                          : Curves.easeInCubic,
                      builder: (context, y, strip) => FractionalTranslation(
                        translation: Offset(0, y),
                        child: strip,
                      ),
                      // Takes the touches on it, so the bar buttons it covers
                      // cannot be pressed blind.
                      child: AbsorbPointer(
                        absorbing: request != null,
                        child: ColoredBox(
                          color: shown.color,
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            removeLeft: true,
                            removeRight: true,
                            child: Builder(
                              // Above the navigator, outside any page's text
                              // style: take the app's own.
                              builder: (context) => DefaultTextStyle(
                                style: Theme.of(context).textTheme.bodyMedium!,
                                child: builder(
                                  context,
                                  shown.route,
                                  shown.arguments,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
