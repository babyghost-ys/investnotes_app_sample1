import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/push_page.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/features/home/view/home_page.dart';
import 'package:investnotes_app_sample1/features/issued/view/issued_page.dart';
import 'package:investnotes_app_sample1/features/learn/view/learn_page.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_page.dart';
import 'package:investnotes_app_sample1/features/search/view/search_page.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/widgets/keel_drawer.dart';

/// The app's frame: the native bar, the native tab bar, and the menu that
/// slides in from the left.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  final _scaffold = GlobalKey<AdaptiveScaffoldState>();

  @override
  Widget build(BuildContext context) => BlocBuilder<ShellBloc, ShellState>(
    builder: (context, state) => AdaptiveScaffold(
      key: _scaffold,
      extendBody: true,
      extendBodyBehindSides: true,
      backgroundColor: KeelColors.page.of(context),
      appBar: AdaptiveAppBar(
        title: state.tab == ShellTab.home ? 'Keel' : null,
        actions: [
          AdaptiveAppBarAction(
            icon: const AdaptiveIcon(
              sfSymbol: 'line.3.horizontal',
              icon: Icons.menu_rounded,
            ),
            label: 'Menu',
            spacerAfter: ToolbarSpacerType.flexible,
            onPressed: () => _scaffold.currentState?.openDrawer(),
          ),
          AdaptiveAppBarAction(
            icon: const AdaptiveIcon(
              sfSymbol: 'magnifyingglass',
              icon: Icons.search,
            ),
            label: 'Search',
            onPressed: () => pushPage<void>(
              context,
              title: 'Search',
              builder: (_) => const SearchPage(),
            ),
          ),
        ],
      ),
      drawer: AdaptiveDrawer.custom(
        backgroundColor: KeelColors.tide.of(context),
        child: const KeelDrawer(),
      ),
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: state.tab.index,
        selectedItemColor: KeelColors.azure.of(context),
        onTap: (i) {
          _scaffold.currentState?.closeDrawer();
          context.read<ShellBloc>().add(ShellTabSelected(ShellTab.values[i]));
        },
        items: const [
          AdaptiveNavigationDestination(
            icon: AdaptiveIcon(sfSymbol: 'house', icon: Icons.home_outlined),
            selectedIcon: AdaptiveIcon(
              sfSymbol: 'house.fill',
              icon: Icons.home,
            ),
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: AdaptiveIcon(sfSymbol: 'tag', icon: Icons.sell_outlined),
            selectedIcon: AdaptiveIcon(sfSymbol: 'tag.fill', icon: Icons.sell),
            label: 'Offerings',
          ),
          AdaptiveNavigationDestination(
            icon: AdaptiveIcon(
              sfSymbol: 'clock.arrow.circlepath',
              icon: Icons.history,
            ),
            label: 'Issued',
          ),
          AdaptiveNavigationDestination(
            icon: AdaptiveIcon(
              sfSymbol: 'graduationcap',
              icon: Icons.school_outlined,
            ),
            selectedIcon: AdaptiveIcon(
              sfSymbol: 'graduationcap.fill',
              icon: Icons.school,
            ),
            label: 'Learn',
          ),
        ],
      ),
      body: IndexedStack(
        index: state.tab.index,
        children: const [
          HomePage(),
          OfferingsPage(),
          IssuedPage(),
          LearnPage(),
        ],
      ),
    ),
  );
}
