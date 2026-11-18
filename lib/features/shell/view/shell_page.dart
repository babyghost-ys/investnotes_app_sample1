import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/page_loader.dart';
import 'package:investnotes_app_sample1/core/widgets/responsive_master_detail.dart';
import 'package:investnotes_app_sample1/features/home/view/home_page.dart';
import 'package:investnotes_app_sample1/features/issued/widgets/issued_skeleton.dart';
import 'package:investnotes_app_sample1/features/education/widgets/education_skeleton.dart';
import 'package:investnotes_app_sample1/features/my_notes/widgets/my_notes_skeleton.dart';
import 'package:investnotes_app_sample1/features/issued/view/issued_page.dart';
import 'package:investnotes_app_sample1/features/education/view/education_page.dart';
import 'package:investnotes_app_sample1/features/my_notes/view/my_notes_page.dart';
import 'package:investnotes_app_sample1/features/my_notes/bloc/my_notes_bloc.dart';
import 'package:investnotes_app_sample1/features/issued/bloc/issued_bloc.dart';
import 'package:investnotes_app_sample1/features/education/bloc/education_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_page.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/widgets/keel_drawer.dart';

/// The app's frame: the native bar, the native tab bar, and the menu that
/// slides in from the left.
class ShellPage extends StatefulWidget implements LocalisationConsumer {
  @override
  List<String> get namespaces => const [Locales.shell, Locales.product];

  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  final _scaffold = GlobalKey<NativeScaffoldState>();

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: widget,
    builder: (context, locale) =>
        _build(context, locale[0] as ShellLocale, locale[1] as ProductLocale),
  );

  Widget _build(
    BuildContext context,
    ShellLocale shell,
    ProductLocale product,
  ) {
    final signedIn = context.select<SessionBloc, bool>((b) => b.state.signedIn);
    return BlocListener<SessionBloc, SessionState>(
      // Signing out takes My Notes away; whoever was on it goes home.
      listenWhen: (before, now) => before.signedIn && !now.signedIn,
      listener: (context, _) {
        if (context.read<ShellBloc>().state.tab == ShellTab.myNotes) {
          context.read<ShellBloc>().add(const ShellTabSelected(ShellTab.home));
        }
      },
      child: BlocBuilder<ShellBloc, ShellState>(
        builder: (context, state) =>
            _frame(context, state, signedIn, shell, product),
      ),
    );
  }

  Widget _frame(
    BuildContext context,
    ShellState state,
    bool signedIn,
    ShellLocale shell,
    ProductLocale product,
  ) {
    final tab = !signedIn && state.tab == ShellTab.myNotes
        ? ShellTab.home
        : state.tab;
    final shown = ShellTab.shown(signedIn: signedIn);
    // The offering beside the Offerings list in a split window: its
    // bookmark joins the bar, as it would on the offering's own page.
    final split = ResponsiveMasterDetail.isSplit(context);
    final beside = context.select<OfferingsBloc, (String, bool)?>((b) {
      final detail = b.state.detail;
      if (tab != ShellTab.offerings || !split || detail == null) return null;
      return (detail.id, b.state.saved.contains(detail.id));
    });
    return NativeScaffold(
      key: _scaffold,
      extendBody: true,
      extendBodyBehindSides: true,
      backgroundColor: KeelColors.page.of(context),
      appBar: NativeAppBar(
        title: tab == ShellTab.home ? shell.labels.brand : null,
        actions: [
          NativeAppBarAction(
            icon: const NativeIcon(
              sfSymbol: 'line.3.horizontal',
              icon: Icons.menu_rounded,
            ),
            label: shell.semantics.menu,
            spacerAfter: ToolbarSpacerType.flexible,
            onPressed: () => _scaffold.currentState?.openDrawer(),
          ),
          NativeAppBarAction(
            icon: const NativeIcon(
              sfSymbol: 'magnifyingglass',
              icon: Icons.search,
            ),
            label: shell.semantics.search,
            onPressed: () => context.push<void>(KeelRoutes.search),
          ),
          if (beside != null)
            bookmarkAction(
              context,
              beside.$1,
              saved: beside.$2,
              product: product,
            ),
        ],
      ),
      drawer: NativeDrawer.custom(
        backgroundColor: KeelColors.tide.of(context),
        child: const KeelDrawer(),
      ),
      bottomNavigationBar: NativeBottomNavigationBar(
        selectedIndex: shown.indexOf(tab),
        selectedItemColor: KeelColors.azure.of(context),
        onTap: (i) {
          _scaffold.currentState?.closeDrawer();
          context.read<ShellBloc>().add(ShellTabSelected(shown[i]));
        },
        items: [
          NativeNavigationDestination(
            icon: const NativeIcon(
              sfSymbol: 'house',
              icon: Icons.home_outlined,
            ),
            selectedIcon: const NativeIcon(
              sfSymbol: 'house.fill',
              icon: Icons.home,
            ),
            label: shell.labels.home,
          ),
          if (signedIn)
            NativeNavigationDestination(
              icon: const NativeIcon(
                sfSymbol: 'briefcase',
                icon: Icons.work_outline,
              ),
              selectedIcon: const NativeIcon(
                sfSymbol: 'briefcase.fill',
                icon: Icons.work,
              ),
              label: shell.labels.myNotes,
            ),
          NativeNavigationDestination(
            icon: const NativeIcon(sfSymbol: 'tag', icon: Icons.sell_outlined),
            selectedIcon: const NativeIcon(
              sfSymbol: 'tag.fill',
              icon: Icons.sell,
            ),
            label: shell.labels.offerings,
          ),
          NativeNavigationDestination(
            icon: const NativeIcon(
              sfSymbol: 'clock.arrow.circlepath',
              icon: Icons.history,
            ),
            label: shell.labels.issued,
          ),
          NativeNavigationDestination(
            icon: const NativeIcon(
              sfSymbol: 'graduationcap',
              icon: Icons.school_outlined,
            ),
            selectedIcon: const NativeIcon(
              sfSymbol: 'graduationcap.fill',
              icon: Icons.school,
            ),
            label: shell.labels.education,
          ),
        ],
      ),
      body: IndexedStack(
        index: tab.index,
        // In ShellTab order, so each page keeps its place as My Notes comes
        // and goes from the bar.
        // Home and Offerings show the offerings as they arrive, each in
        // its own way; the other tabs wait for their fetch.
        children: const [
          HomePage(),
          PageLoader<MyNotesBloc, MyNotesState>(
            skeleton: MyNotesSkeleton(),
            load: requestHoldings,
            child: MyNotesPage(),
          ),
          OfferingsPage(),
          PageLoader<IssuedBloc, IssuedState>(
            skeleton: IssuedSkeleton(),
            load: requestIssued,
            child: IssuedPage(),
          ),
          PageLoader<EducationBloc, EducationState>(
            skeleton: EducationSkeleton(),
            load: requestEducation,
            child: EducationPage(),
          ),
        ],
      ),
    );
  }
}
