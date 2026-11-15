import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/common_overlay.dart';
import 'package:investnotes_app_sample1/app/keel_router.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/data/repositories/biometric_repository.dart';
import 'package:investnotes_app_sample1/data/repositories/connectivity_repository.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/connectivity/bloc/connectivity_bloc.dart';
import 'package:investnotes_app_sample1/features/finder/bloc/finder_bloc.dart';
import 'package:investnotes_app_sample1/features/issued/bloc/issued_bloc.dart';
import 'package:investnotes_app_sample1/features/my_notes/bloc/my_notes_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/biometric_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';
import 'package:investnotes_app_sample1/features/splash/bloc/splash_bloc.dart';
import 'package:investnotes_app_sample1/features/splash/view/splash_page.dart';

class KeelApp extends StatefulWidget {
  const KeelApp({super.key});

  @override
  State<KeelApp> createState() => _KeelAppState();
}

class _KeelAppState extends State<KeelApp> {
  final _repository = NotesRepository();
  late final GoRouter _router = keelRouter(_repository);

  /// Built once: the scopes above it change (who signs in with Face ID),
  /// and rebuilding the app would reset its native navigation stack.
  late final Widget _app = NativeApp.router(
    title: 'Keel',
    theme: KeelTheme.light,
    darkTheme: KeelTheme.dark,
    routerConfig: _router,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepositoryProvider.value(
    value: _repository,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashBloc()),
        BlocProvider(create: (_) => ShellBloc()),
        BlocProvider(create: (_) => SessionBloc()),
        BlocProvider(
          create: (_) =>
              BiometricBloc(BiometricRepository())
                ..add(const BiometricStarted()),
        ),
        BlocProvider(create: (_) => OfferingsBloc(_repository)),
        BlocProvider(create: (_) => IssuedBloc(_repository)),
        BlocProvider(
          create: (_) => MyNotesBloc(_repository)..add(const MyNotesStarted()),
        ),
        // One run of "find my note" at a time; starting it clears the last.
        BlocProvider(create: (_) => FinderBloc(_repository)),
        BlocProvider(
          create: (_) =>
              ConnectivityBloc(ConnectivityRepository())
                ..add(const ConnectivityStarted()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SessionBloc, SessionState>(
            listenWhen: (before, now) =>
                now.name != null && now.name != before.name,
            listener: (context, session) => context.read<BiometricBloc>().add(
              BiometricAccountSignedIn(session.name!),
            ),
          ),
          // The first answer hides too: a hot restart can find the strip
          // still up from before.
          BlocListener<ConnectivityBloc, ConnectivityState>(
            listener: (context, network) {
              if (!network.offline) {
                NativeOverlayContainer.hide();
              } else if (context.read<SplashBloc>().state.done) {
                CommonOverlay.showNetworkLost();
              }
            },
          ),
          // Lost before the opening screen ended: shown once the app is up,
          // so its few seconds are not spent on the opening screen.
          BlocListener<SplashBloc, SplashState>(
            listenWhen: (before, now) => now.done && !before.done,
            listener: (context, _) {
              if (context.read<ConnectivityBloc>().state.offline) {
                CommonOverlay.showNetworkLost();
              }
            },
          ),
        ],
        child: Builder(
          // Sign-in as a page of this router (Android): finishing returns home.
          builder: (context) => SignInScope(
            base: KeelRoutes.signIn,
            biometric: switch (context.watch<BiometricBloc>().state) {
              BiometricState(:final name?, :final kind?) => (
                name: name,
                kind: kind,
              ),
              _ => null,
            },
            onSignedIn: (name) {
              context.read<SessionBloc>().add(SessionSignedIn(name));
              _router.go(KeelRoutes.home);
            },
            onClose: () => _router.go(KeelRoutes.home),
            // The opening screen first; the app once it has had its time.
            child: BlocBuilder<SplashBloc, SplashState>(
              builder: (context, splash) =>
                  splash.done ? _app : const SplashPage(),
            ),
          ),
        ),
      ),
    ),
  );
}
