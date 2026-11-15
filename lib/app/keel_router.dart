import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/app/keel_page.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/widgets/page_loader.dart';
import 'package:investnotes_app_sample1/core/widgets/responsive_detail_page.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/downloads/view/downloads_page.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_page.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_results_page.dart';
import 'package:investnotes_app_sample1/features/finder/widgets/finder_results_skeleton.dart';
import 'package:investnotes_app_sample1/features/education/view/article_page.dart';
import 'package:investnotes_app_sample1/features/education/view/education_search_page.dart';
import 'package:investnotes_app_sample1/features/education/view/explainer_page.dart';
import 'package:investnotes_app_sample1/features/education/widgets/article_skeleton.dart';
import 'package:investnotes_app_sample1/features/saved/view/saved_page.dart';
import 'package:investnotes_app_sample1/features/saved/widgets/saved_skeleton.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/search/view/search_page.dart';
import 'package:investnotes_app_sample1/features/session/bloc/biometric_bloc.dart';
import 'package:investnotes_app_sample1/features/session/view/biometric_settings_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_route.dart';
import 'package:investnotes_app_sample1/features/settings/view/settings_page.dart';
import 'package:investnotes_app_sample1/features/shell/view/shell_page.dart';

/// Keel's routes. The shell is the root; every other page is pushed over
/// it as an [NativePage], so iOS keeps the native push and swipe-back.
GoRouter keelRouter(NotesRepository repository) => GoRouter(
  routes: [
    GoRoute(
      path: KeelRoutes.home,
      builder: (context, state) => const ShellPage(),
      routes: [
        GoRoute(
          path: 'offering/:id',
          pageBuilder: (context, state) => _productPage(state, repository),
        ),
        GoRoute(
          path: 'offerings/:id',
          pageBuilder: (context, state) =>
              _productPage(state, repository, responsive: true),
        ),
        GoRoute(
          path: 'note/:id',
          pageBuilder: (context, state) => _productPage(state, repository),
        ),
        GoRoute(
          path: 'article/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];
            final article = repository.articles.firstWhere((a) => a.id == id);
            return keelPage(
              state,
              namespaces: const [Locales.general],
              title: (_) => article.type.code,
              semanticTitle: (locale) =>
                  article.type.title(locale[0] as GeneralLocale),
              child: PageLoader(
                skeleton: const ArticleSkeleton(),
                child: ArticlePage(article: article),
              ),
            );
          },
        ),
        GoRoute(
          path: 'explainer/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];
            final explainer = repository.explainers.firstWhere(
              (e) => e.id == id,
            );
            final type = explainer.payoff.type;
            return keelPage(
              state,
              namespaces: const [Locales.general],
              title: (_) => type.code,
              semanticTitle: (locale) => type.title(locale[0] as GeneralLocale),
              child: ExplainerPage(explainer: explainer),
            );
          },
        ),
        GoRoute(
          path: 'education/search',
          pageBuilder: (context, state) => keelPage(
            state,
            namespaces: const [Locales.education],
            title: (locale) =>
                (locale[0] as EducationLocale).labels.searchTitle,
            child: const EducationSearchPage(),
          ),
        ),
        GoRoute(
          path: 'search',
          pageBuilder: (context, state) => keelPage(
            state,
            namespaces: const [Locales.search],
            title: (locale) => (locale[0] as SearchLocale).labels.title,
            // Nothing to load before typing: the field shows at once.
            child: const SearchPage(),
          ),
        ),
        GoRoute(
          path: 'saved',
          pageBuilder: (context, state) => keelPage(
            state,
            namespaces: const [Locales.saved],
            title: (locale) => (locale[0] as SavedLocale).labels.title,
            child: const PageLoader(
              skeleton: SavedSkeleton(),
              child: SavedPage(),
            ),
          ),
        ),
        GoRoute(
          path: 'downloads',
          pageBuilder: (context, state) => keelPage(
            state,
            namespaces: const [Locales.downloads],
            title: (locale) => (locale[0] as DownloadsLocale).labels.title,
            // Kept on the device: nothing to wait for.
            child: const DownloadsPage(),
          ),
        ),
        GoRoute(
          path: 'finder/step/:step',
          pageBuilder: (context, state) => keelPage(
            state,
            namespaces: const [Locales.finder],
            title: (locale) => (locale[0] as FinderLocale).labels.title,
            child: FinderPage(step: int.parse(state.pathParameters['step']!)),
          ),
        ),
        GoRoute(
          path: 'finder/results',
          pageBuilder: (context, state) => keelPage(
            state,
            namespaces: const [Locales.finder],
            title: (locale) => (locale[0] as FinderLocale).labels.resultsTitle,
            actions: (locale) => [
              NativeAppBarAction(
                icon: const NativeIcon(
                  sfSymbol: 'checkmark',
                  icon: CupertinoIcons.checkmark,
                ),
                label: (locale[0] as FinderLocale).semantics.done,
                onPressed: () => context.go(KeelRoutes.home),
              ),
            ],
            child: const PageLoader(
              skeleton: FinderResultsSkeleton(),
              child: FinderResultsPage(),
            ),
          ),
        ),
        GoRoute(
          path: 'settings',
          pageBuilder: (context, state) => keelPage(
            state,
            namespaces: const [Locales.settings],
            title: (locale) => (locale[0] as SettingsLocale).labels.title,
            child: const SettingsPage(),
          ),
        ),
        GoRoute(
          path: 'settings/biometric',
          pageBuilder: (context, state) => keelPage(
            state,
            // Face ID and Touch ID are called so in every language.
            namespaces: const [],
            title: (_) =>
                context.read<BiometricBloc>().state.kind?.title ?? 'Face ID',
            child: const BiometricSettingsPage(),
          ),
        ),
        registerRoute(path: 'register'),
        signInRoute(path: 'sign-in', sheet: false),
        biometricSignInRoute(path: 'sign-in-biometric', sheet: false),
      ],
    ),
  ],
);

/// A note's page, open or issued. The page carries its own scaffold for
/// its bookmark. A [responsive] page is the detail of a list that splits in
/// a wide window, and steps back to that split when the window widens.
NativePage<void> _productPage(
  GoRouterState state,
  NotesRepository repository, {
  bool responsive = false,
}) {
  final page = ProductPage(
    product: repository.productById(state.pathParameters['id']!)!,
  );
  return NativePage<void>(
    key: state.pageKey,
    name: state.matchedLocation,
    child: responsive ? ResponsiveDetailPage(child: page) : page,
  );
}
