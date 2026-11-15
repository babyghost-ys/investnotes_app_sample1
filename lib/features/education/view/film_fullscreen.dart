import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:video_player/video_player.dart';

import 'package:investnotes_app_sample1/features/education/widgets/film_view.dart';

/// Where full screen leaves off: the film's place and whether it played.
typedef FilmPlace = ({Duration position, bool playing});

/// A film full screen, on its side. Given the inline [controller] (one
/// engine) it carries on with it; in a sheet's own engine it opens the
/// film itself at [start] and hands its place back when closed.
class FilmFullscreen extends StatefulWidget {
  const FilmFullscreen({
    super.key,
    this.controller,
    required this.asset,
    this.start = Duration.zero,
    this.playing = true,
  });

  final VideoPlayerController? controller;
  final String asset;
  final Duration start;
  final bool playing;

  /// [place] as a sheet's result, which must cross engines as plain values.
  static Map<String, Object> encode(FilmPlace place) => {
    'position': place.position.inMilliseconds,
    'playing': place.playing,
  };

  static FilmPlace decode(Object value) {
    final map = value as Map;
    return (
      position: Duration(milliseconds: map['position'] as int),
      playing: map['playing'] as bool,
    );
  }

  @override
  State<FilmFullscreen> createState() => _FilmFullscreenState();
}

class _FilmFullscreenState extends State<FilmFullscreen> {
  VideoPlayerController? _own;

  /// The sheet's own player, released before the sheet's engine goes: a
  /// player left running would report to an engine that no longer exists.
  bool _released = false;
  bool _closing = false;

  VideoPlayerController get _c => widget.controller ?? _own!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _own = VideoPlayerController.asset(widget.asset)
        ..initialize().then((_) async {
          await _own!.seekTo(widget.start);
          if (widget.playing) await _own!.play();
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    if (!_released) _own?.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    final own = _own;
    if (own == null) {
      // The inline controller carries on by itself.
      return NativeSheet.pop<Object?>(context);
    }
    final v = own.value;
    final place = FilmFullscreen.encode((
      position: v.position,
      playing: v.isPlaying,
    ));
    await own.pause();
    setState(() => _released = true);
    await own.dispose();
    if (!mounted) return;
    // The inline film picks up from here.
    await NativeSheet.pop<Object?>(context, place);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _close();
    },
    child: ColoredBox(
      color: CupertinoColors.black,
      child: _released
          // Black while the sheet slides away.
          ? const SizedBox.expand()
          : _c.value.isInitialized
          ? FilmView(controller: _c, expanded: true, onExpand: _close)
          : const Center(
              child: CupertinoActivityIndicator(color: Color(0xFFFFFFFF)),
            ),
    ),
  );
}
