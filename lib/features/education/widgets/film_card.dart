import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:video_player/video_player.dart';

import 'package:investnotes_app_sample1/app/sheet_arguments.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/domain/models/film.dart';
import 'package:investnotes_app_sample1/features/education/view/film_fullscreen.dart';
import 'package:investnotes_app_sample1/features/education/widgets/film_view.dart';
import 'package:investnotes_app_sample1/features/education/widgets/play_glyph.dart';

/// A film in the Videos list. Its poster until tapped, then it plays right
/// there, and fills the screen on demand.
class FilmCard extends StatefulWidget {
  const FilmCard({super.key, required this.film});

  final Film film;

  @override
  State<FilmCard> createState() => _FilmCardState();
}

class _FilmCardState extends State<FilmCard> {
  VideoPlayerController? _controller;
  bool _starting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Another tab in front: the film waits for it to come back.
    if (!TickerMode.valuesOf(context).enabled) _controller?.pause();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_starting) return;
    HapticFeedback.selectionClick();
    setState(() => _starting = true);
    final c = VideoPlayerController.asset(widget.film.asset);
    await c.initialize();
    if (!mounted) {
      c.dispose();
      return;
    }
    setState(() {
      _controller = c;
      _starting = false;
    });
    await c.play();
  }

  Future<void> _expand() async {
    final c = _controller!;
    final playing = c.value.isPlaying;
    final native = NativeStyle.of(context) == NativeStyle.native;
    // Full screen the way the phone is held: turning it is the user's call.
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // On iOS full screen is a sheet over the native bars, with an engine of
    // its own: it picks the film up where this one leaves it.
    if (native) await c.pause();
    if (!mounted) return;
    final place = await NativeSheet.show<FilmPlace>(
      context: context,
      route: 'film',
      arguments: SheetArguments.wrap(context, {
        'asset': widget.film.asset,
        'position': c.value.position.inMilliseconds,
        'playing': playing,
      }),
      decodeResult: FilmFullscreen.decode,
      fullScreen: true,
      backgroundColor: CupertinoColors.black,
      builder: (_) => FilmFullscreen(controller: c, asset: widget.film.asset),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (place == null || !mounted) return;
    await c.seekTo(place.position);
    place.playing ? await c.play() : await c.pause();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: controller == null
                  ? Semantics(
                      button: true,
                      label: widget.film.title,
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: _start,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(widget.film.poster, fit: BoxFit.cover),
                            Center(
                              child: _starting
                                  ? const CupertinoActivityIndicator(
                                      color: CupertinoColors.white,
                                      radius: 14,
                                    )
                                  : const PlayGlyph(size: 58),
                            ),
                          ],
                        ),
                      ),
                    )
                  : FilmView(
                      controller: controller,
                      expanded: false,
                      onExpand: _expand,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.film.title,
            style: TextStyle(
              color: KeelColors.ink.of(context),
              fontSize: 19,
              height: 1.2,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
