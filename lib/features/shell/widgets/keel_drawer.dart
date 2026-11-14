import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_page.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/widgets/drawer_row.dart';

/// The menu that slides in from the left: the account, every tab, and the
/// places that are not tabs.
class KeelDrawer extends StatelessWidget {
  const KeelDrawer({super.key});

  static const _white = CupertinoColors.white;

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellBloc>().state;
    final session = context.watch<SessionBloc>().state;
    final scaffold = AdaptiveScaffold.of(context);

    Future<void> go(ShellTab tab) async {
      context.read<ShellBloc>().add(ShellTabSelected(tab));
      await scaffold.closeDrawer();
    }

    // The drawer's own context goes when it closes; pages are pushed from
    // the scaffold's, which stays.
    final host = scaffold.context;
    final router = GoRouter.of(context);

    // The Material drawer can finish closing without completing the
    // scaffold's future, so the wait is capped at the close animation.
    Future<void> close() => scaffold.closeDrawer().timeout(
      const Duration(milliseconds: 350),
      onTimeout: () {},
    );

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
              const KeelMark(color: _white, size: 40),
              const SizedBox(width: 10),
              const Text(
                'Keel',
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
                  label: 'Sign out',
                  foreground: KeelColors.foam,
                  onPressed: () =>
                      context.read<SessionBloc>().add(const SessionSignedOut()),
                )
              else
                RoundIconButton(
                  icon: CupertinoIcons.person_crop_circle_badge_plus,
                  label: 'Sign in',
                  foreground: KeelColors.tide.of(context),
                  background: _white,
                  iconSize: 22,
                  onPressed: () => open(KeelRoutes.signIn),
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
        for (final (tab, icon, title) in const [
          (ShellTab.home, CupertinoIcons.house_fill, 'Home'),
          (ShellTab.offerings, CupertinoIcons.tag_fill, 'Offerings'),
          (ShellTab.issued, CupertinoIcons.clock_fill, 'Issued'),
          (ShellTab.learn, CupertinoIcons.book_fill, 'Learn'),
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
          title: 'Saved',
          onTap: () => open(KeelRoutes.saved),
        ),
        DrawerRow(
          icon: CupertinoIcons.wand_stars,
          title: 'Find my note',
          onTap: () async {
            await close();
            if (host.mounted) await startFinder(host);
          },
        ),
      ],
    );
  }
}
