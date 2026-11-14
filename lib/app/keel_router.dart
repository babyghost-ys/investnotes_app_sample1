import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/app/keel_page.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_page.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_results_page.dart';
import 'package:investnotes_app_sample1/features/learn/view/article_page.dart';
import 'package:investnotes_app_sample1/features/saved/view/saved_page.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/search/view/search_page.dart';
import 'package:investnotes_app_sample1/features/session/bloc/biometric_bloc.dart';
import 'package:investnotes_app_sample1/features/session/view/biometric_settings_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_route.dart';
import 'package:investnotes_app_sample1/features/shell/view/shell_page.dart';

/// Keel's routes. The shell is the root; every other page is pushed over
/// it as an [AdaptivePage], so iOS keeps the native push and swipe-back.
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
              title: article.type.code,
              child: ArticlePage(article: article),
            );
          },
        ),
        GoRoute(
          path: 'search',
          pageBuilder: (context, state) =>
              keelPage(state, title: 'Search', child: const SearchPage()),
        ),
        GoRoute(
          path: 'saved',
          pageBuilder: (context, state) =>
              keelPage(state, title: 'Saved', child: const SavedPage()),
        ),
        GoRoute(
          path: 'finder/step/:step',
          pageBuilder: (context, state) => keelPage(
            state,
            title: 'Find my note',
            child: FinderPage(step: int.parse(state.pathParameters['step']!)),
          ),
        ),
        GoRoute(
          path: 'finder/results',
          pageBuilder: (context, state) => keelPage(
            state,
            title: 'Your notes',
            actions: [
              AdaptiveAppBarAction(
                icon: const AdaptiveIcon(
                  sfSymbol: 'checkmark',
                  icon: CupertinoIcons.checkmark,
                ),
                label: 'Done',
                onPressed: () => context.go(KeelRoutes.home),
              ),
            ],
            child: const FinderResultsPage(),
          ),
        ),
        GoRoute(
          path: 'settings/biometric',
          pageBuilder: (context, state) => keelPage(
            state,
            title: context.read<BiometricBloc>().state.kind?.title ?? 'Face ID',
            child: const BiometricSettingsPage(),
          ),
        ),
        signInRoute(path: 'sign-in', sheet: false),
        biometricSignInRoute(path: 'sign-in-biometric', sheet: false),
      ],
    ),
  ],
);

/// A note's page, open or issued. The page carries its own scaffold for
/// its bookmark.
AdaptivePage<void> _productPage(
  GoRouterState state,
  NotesRepository repository,
) => AdaptivePage<void>(
  key: state.pageKey,
  name: state.matchedLocation,
  child: ProductPage(
    product: repository.productById(state.pathParameters['id']!)!,
  ),
);
