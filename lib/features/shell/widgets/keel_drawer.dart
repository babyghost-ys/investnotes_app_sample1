import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/biometric_glyph.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_page.dart';
import 'package:investnotes_app_sample1/features/session/bloc/biometric_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';
import 'package:investnotes_app_sample1/features/session/view/open_sign_in.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/widgets/drawer_row.dart';

/// The menu that slides in from the left: the account, every tab, and the
/// places that are not tabs.
class KeelDrawer extends StatelessWidget implements LocalisationConsumer {
  const KeelDrawer({super.key});

  static const _white = CupertinoColors.white;

  @override
  List<String> get namespaces => const [Locales.shell];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as ShellLocale),
  );

  Widget _build(BuildContext context, ShellLocale words) {
    final shell = context.watch<ShellBloc>().state;
    final session = context.watch<SessionBloc>().state;
    final biometric = context.watch<BiometricBloc>().state.kind;
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

    // Closed first, like every other row: the tab changes on a settled
    // screen, not under the drawer as it slides away.
    Future<void> go(ShellTab tab) async {
      await close();
      shellBloc.add(ShellTabSelected(tab));
    }

    Future<void> open(String location) async {
      await close();
      await router.push<void>(location);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const KeelMark(
                color: _white,
                size: 40,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 10),
              Text(
                words.labels.brand,
                semanticsLabel: words.semantics.keelMenu,
                style: TextStyle(
                  color: _white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const Spacer(),
              if (session.signedIn)
                RoundIconButton(
                  icon: CupertinoIcons.square_arrow_right,
                  label: words.semantics.signOut,
                  foreground: KeelColors.foam,
                  onPressed: () =>
                      context.read<SessionBloc>().add(const SessionSignedOut()),
                )
              else
                RoundIconButton(
                  icon: CupertinoIcons.person_crop_circle_badge_plus,
                  label: words.semantics.signIn,
                  foreground: KeelColors.tide.of(context),
                  background: _white,
                  iconSize: 22,
                  onPressed: () async {
                    await close();
                    if (host.mounted) await openSignIn(host);
                  },
                ),
            ],
          ),
        ),
        if (session.signedIn)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  color: KeelColors.foam,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: KeelColors.foam,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        for (final (tab, icon, title) in [
          (ShellTab.home, CupertinoIcons.house_fill, words.labels.home),
          if (session.signedIn)
            (
              ShellTab.myNotes,
              CupertinoIcons.briefcase_fill,
              words.labels.myNotes,
            ),
          (ShellTab.offerings, CupertinoIcons.tag_fill, words.labels.offerings),
          (ShellTab.issued, CupertinoIcons.clock_fill, words.labels.issued),
          (
            ShellTab.education,
            CupertinoIcons.book_fill,
            words.labels.education,
          ),
        ])
          DrawerRow(
            icon: icon,
            title: title,
            selected: shell.tab == tab,
            onTap: () => go(tab),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: Color(0x33FFFFFF)),
          ),
        ),
        DrawerRow(
          icon: CupertinoIcons.bookmark_fill,
          title: words.labels.saved,
          onTap: () => open(KeelRoutes.saved),
        ),
        DrawerRow(
          icon: CupertinoIcons.wand_stars,
          title: words.labels.findMyNote,
          onTap: () async {
            await close();
            if (host.mounted) await startFinder(host);
          },
        ),
        // Signing in with Face ID or Touch ID, for the account in use on a
        // device that has one.
        if (session.signedIn && biometric != null)
          DrawerRow(
            glyph: BiometricGlyph(
              kind: biometric,
              color: KeelColors.foam,
              size: 22,
            ),
            title: biometric.title,
            onTap: () => open(KeelRoutes.biometricSettings),
          ),
        DrawerRow(
          icon: CupertinoIcons.gear_alt_fill,
          title: words.labels.settings,
          onTap: () => open(KeelRoutes.settings),
        ),
      ],
    );
  }
}
