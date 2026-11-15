import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/features/splash/widgets/arc_spinner.dart';

/// The opening screen: the stone doorway full bleed, as the system's launch
/// screen already shows it, with the brand and a spinner rising over it.
///
/// It stands before the app exists, so it brings its own text direction
/// and media query.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// The doorway framed tall, for a phone held upright or a folded Duo.
  static const background = AssetImage('assets/images/splash_background.jpg');

  /// The whole portico, for a screen wider than it is tall, such as an
  /// unfolded Duo, where the tall framing would be cropped and enlarged.
  static const wideBackground = AssetImage(
    'assets/images/splash_background_wide.jpg',
  );

  /// The picture for a screen of [size].
  static AssetImage backgroundFor(Size size) =>
      size.width > size.height ? wideBackground : background;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// The brand fades in over the launch screen's picture.
  late final _rise = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void dispose() {
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaQuery.fromView(
    // Follows the window as it changes: a fold, an unfold, a turn.
    view: View.of(context),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(builder: _content),
    ),
  );

  Widget _content(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image(
        image: SplashPage.backgroundFor(MediaQuery.sizeOf(context)),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
      FadeTransition(
        opacity: CurvedAnimation(parent: _rise, curve: Curves.easeOut),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Deepens the doorway behind the brand, so white reads on stone.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [Color(0x66000000), Color(0x14000000)],
                ),
              ),
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeelMark(
                      color: CupertinoColors.white,
                      size: 40,
                      excludeFromSemantics: true,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Keel',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(color: Color(0x55000000), blurRadius: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                ArcSpinner(color: CupertinoColors.white),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
