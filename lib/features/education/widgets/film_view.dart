import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';
import 'package:video_player/video_player.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/features/education/widgets/film_scrubber.dart';

/// A playing film with its controls over it: play and pause, the time
/// gone and left either side of a scrubber, and full screen in or out.
/// The controls fade away while it plays; a tap brings them back.
class FilmView extends StatefulWidget implements LocalisationConsumer {
  const FilmView({
    super.key,
    required this.controller,
    required this.expanded,
    required this.onExpand,
  });

  final VideoPlayerController controller;

  /// Full screen: the control takes the film back in.
  final bool expanded;
  final VoidCallback onExpand;

  @override
  List<String> get namespaces => const [Locales.education];

  @override
  State<FilmView> createState() => _FilmViewState();
}

class _FilmViewState extends State<FilmView> {
  static const _linger = Duration(milliseconds: 2600);

  bool _shown = true;
  Timer? _hide;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
    _schedule();
  }

  @override
  void didUpdateWidget(FilmView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onTick);
      _c.addListener(_onTick);
    }
  }

  @override
  void dispose() {
    _hide?.cancel();
    _c.removeListener(_onTick);
    super.dispose();
  }

  bool get _ended {
    final v = _c.value;
    return v.isInitialized &&
        !v.isPlaying &&
        v.duration > Duration.zero &&
        v.position >= v.duration - const Duration(milliseconds: 150);
  }

  void _onTick() {
    // Paused or finished: the controls stay until it plays again.
    if (!_c.value.isPlaying && !_shown) setState(() => _shown = true);
  }

  void _schedule() {
    _hide?.cancel();
    _hide = Timer(_linger, () {
      if (mounted && _c.value.isPlaying) setState(() => _shown = false);
    });
  }

  void _poke() {
    setState(() => _shown = !_shown || !_c.value.isPlaying);
    if (_shown) _schedule();
  }

  Future<void> _toggle() async {
    if (_ended) {
      await _c.seekTo(Duration.zero);
      await _c.play();
    } else if (_c.value.isPlaying) {
      await _c.pause();
    } else {
      await _c.play();
    }
    _schedule();
  }

  static String _clock(Duration d) {
    final s = d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: widget,
    builder: (context, locale) => _build(context, locale[0] as EducationLocale),
  );

  Widget _build(BuildContext context, EducationLocale words) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _poke,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: CupertinoColors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _c.value.aspectRatio,
              child: VideoPlayer(_c),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: !_shown,
          child: AnimatedOpacity(
            opacity: _shown ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            // Faded out, the controls still answer VoiceOver and TalkBack.
            alwaysIncludeSemantics: true,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _c,
              builder: (context, v, _) => _controls(context, words, v),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _controls(
    BuildContext context,
    EducationLocale words,
    VideoPlayerValue v,
  ) {
    final total = v.duration.inMilliseconds;
    final progress = total == 0 ? 0.0 : v.position.inMilliseconds / total;
    const figures = TextStyle(
      decoration: TextDecoration.none,
      color: CupertinoColors.white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    final pad = widget.expanded ? 28.0 : 10.0;
    // Full screen on Android sits outside any Material, whose text style
    // the figures would otherwise fall back to (underlined in yellow).
    return DefaultTextStyle(
      style: figures,
      child: _scrim(pad, words, v, progress, total, figures),
    );
  }

  Widget _scrim(
    double pad,
    EducationLocale words,
    VideoPlayerValue v,
    double progress,
    int total,
    TextStyle figures,
  ) {
    return DecoratedBox(
      // A scrim only where the controls sit, so the film stays clear.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.45, 1],
          colors: [Color(0x00000000), Color(0x99000000)],
        ),
      ),
      child: SafeArea(
        minimum: EdgeInsets.fromLTRB(pad, 0, pad, widget.expanded ? 16 : 6),
        child: Column(
          children: [
            const Spacer(),
            Row(
              children: [
                RoundIconButton(
                  icon: _ended
                      ? CupertinoIcons.arrow_counterclockwise
                      : v.isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  label: _ended
                      ? words.semantics.replay
                      : v.isPlaying
                      ? words.semantics.pause
                      : words.semantics.play,
                  foreground: CupertinoColors.white,
                  size: 40,
                  iconSize: 20,
                  onPressed: _toggle,
                ),
                const SizedBox(width: 4),
                Text(_clock(v.position), style: figures),
                const SizedBox(width: 12),
                Expanded(
                  child: FilmScrubber(
                    progress: progress,
                    label: words.semantics.position,
                    value: _clock(v.position),
                    onSeek: (k) {
                      _c.seekTo(Duration(milliseconds: (total * k).round()));
                      _schedule();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text('-${_clock(v.duration - v.position)}', style: figures),
                const SizedBox(width: 4),
                RoundIconButton(
                  icon: widget.expanded
                      ? CupertinoIcons.fullscreen_exit
                      : CupertinoIcons.fullscreen,
                  label: widget.expanded
                      ? words.semantics.exitFullScreen
                      : words.semantics.fullScreen,
                  foreground: CupertinoColors.white,
                  size: 40,
                  iconSize: 20,
                  onPressed: widget.onExpand,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
