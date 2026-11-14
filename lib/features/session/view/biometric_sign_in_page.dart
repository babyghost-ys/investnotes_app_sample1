import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bar_strip.dart';
import 'package:investnotes_app_sample1/core/widgets/biometric_glyph.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/repositories/biometric_repository.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';

enum _Check { idle, checking, failed }

/// Welcome back for an account that signs in with Face ID or Touch ID: who
/// it is, one large control that checks and signs in, and a way to sign in
/// with username and password instead.
class BiometricSignInPage extends StatefulWidget {
  const BiometricSignInPage({super.key});

  @override
  State<BiometricSignInPage> createState() => _BiometricSignInPageState();
}

class _BiometricSignInPageState extends State<BiometricSignInPage>
    with SingleTickerProviderStateMixin {
  final _repository = BiometricRepository();

  /// A no-match shakes the control, the way a wrong passcode does.
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DraftBloc<_Check>(_Check.idle),
    child: BlocBuilder<DraftBloc<_Check>, DraftState<_Check>>(
      builder: (context, state) {
        final scope = SignInScope.of(context);
        final account = scope.biometric;
        if (account == null) return const SizedBox.shrink();
        final check = context.read<DraftBloc<_Check>>();
        final insets = MediaQuery.paddingOf(context);
        final azure = KeelColors.azure.of(context);
        final muted = KeelColors.muted.of(context);

        Future<void> signIn() async {
          check.change(_Check.checking);
          final matched = await _repository.authenticate(
            'Sign in to Keel with ${account.kind.title}',
          );
          if (!mounted) return;
          if (matched) {
            scope.onSignedIn(account.name);
            return;
          }
          check.change(_Check.failed);
          HapticFeedback.heavyImpact();
          _shake.forward(from: 0);
        }

        final failed = state.value == _Check.failed;

        return BarStrip(
          child: Material(
            type: MaterialType.transparency,
            child: ColoredBox(
              color: KeelColors.raised.of(context),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          _Band(insets: insets),
                          const SizedBox(height: 40),
                          // Whose account this signs in.
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              24 + insets.left,
                              0,
                              24 + insets.right,
                              0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.person_crop_circle_fill,
                                  color: muted,
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    account.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: KeelColors.ink.of(context),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          AnimatedBuilder(
                            animation: _shake,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(
                                math.sin(_shake.value * math.pi * 6) *
                                    14 *
                                    (1 - _shake.value),
                                0,
                              ),
                              child: child,
                            ),
                            child: _BiometricButton(
                              account: account,
                              failed: failed,
                              color: azure,
                              onPressed: state.value == _Check.checking
                                  ? null
                                  : signIn,
                            ),
                          ),
                          const SizedBox(height: 36),
                          RoundIconButton(
                            icon: CupertinoIcons.keyboard,
                            label: 'Sign in with username and password',
                            foreground: azure,
                            background: KeelColors.mist.of(context),
                            size: 56,
                            iconSize: 24,
                            onPressed: () => scope.pushPasswordSignIn(context),
                          ),
                          SizedBox(height: insets.bottom + 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// The tide blue carried down from the bar, holding the brand, as on
/// sign-in.
class _Band extends StatelessWidget {
  const _Band({required this.insets});

  final EdgeInsets insets;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      24 + insets.left,
      insets.top + 28,
      24 + insets.right,
      36,
    ),
    color: KeelColors.tide.of(context),
    child: Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: FlowPage.measure - 48),
        child: const Row(
          children: [
            KeelMark(color: CupertinoColors.white, size: 56),
            SizedBox(width: 14),
            Text(
              'Keel',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 36,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The large round control that checks the face or finger and signs in.
/// After a no-match it turns red until tried again.
class _BiometricButton extends StatelessWidget {
  const _BiometricButton({
    required this.account,
    required this.failed,
    required this.color,
    required this.onPressed,
  });

  final BiometricAccount account;
  final bool failed;
  final Color color;
  final VoidCallback? onPressed;

  static const _size = 128.0;

  @override
  Widget build(BuildContext context) {
    final fill = failed
        ? CupertinoColors.systemRed.resolveFrom(context)
        : color;
    return Semantics(
      button: true,
      label: 'Sign in with ${account.kind.title}',
      excludeSemantics: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(_size),
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: fill.withValues(alpha: 0.32),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: BiometricGlyph(
            kind: account.kind,
            color: CupertinoColors.white,
            size: 60,
          ),
        ),
      ),
    );
  }
}
