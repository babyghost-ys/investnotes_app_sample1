import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// The top of Home: the way to open an account, or, once signed in, the
/// account's welcome. One height either way, so the page never jumps.
class AccountBanner extends StatelessWidget {
  const AccountBanner({
    super.key,
    required this.name,
    required this.onRegister,
  });

  /// Who is signed in; null shows the way to register.
  final String? name;
  final VoidCallback onRegister;

  static const height = 84.0;
  static const _white = CupertinoColors.white;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 260),
    child: SizedBox(
      key: ValueKey(name),
      height: height,
      child: name == null ? _register() : _welcome(name!),
    ),
  );

  Widget _card({required Widget child}) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0x38000000),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0x1FFFFFFF)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    ),
  );

  Widget _register() => Semantics(
    container: true,
    button: true,
    label: 'Register today',
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onRegister();
      },
      child: _card(
        child: const Row(
          children: [
            Text(
              'Register Today',
              style: TextStyle(
                color: _white,
                fontSize: 21,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(width: 6),
            Icon(CupertinoIcons.chevron_right, color: _white, size: 18),
            Spacer(),
            Icon(
              CupertinoIcons.person_crop_circle_badge_plus,
              color: KeelColors.foam,
              size: 34,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _welcome(String name) => Semantics(
    container: true,
    label: 'Welcome, $name',
    excludeSemantics: true,
    child: _card(
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.person_crop_circle_fill,
            color: KeelColors.foam,
            size: 40,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(color: KeelColors.foam, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
