import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/keel_router.dart';
import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/finder/bloc/finder_bloc.dart';
import 'package:investnotes_app_sample1/features/issued/bloc/issued_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';

class KeelApp extends StatefulWidget {
  const KeelApp({super.key});

  @override
  State<KeelApp> createState() => _KeelAppState();
}

class _KeelAppState extends State<KeelApp> {
  final _repository = NotesRepository();
  late final GoRouter _router = keelRouter(_repository);

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
        BlocProvider(create: (_) => ShellBloc()),
        BlocProvider(create: (_) => SessionBloc()),
        BlocProvider(create: (_) => OfferingsBloc(_repository)),
        BlocProvider(create: (_) => IssuedBloc(_repository)),
        // One run of "find my note" at a time; starting it clears the last.
        BlocProvider(create: (_) => FinderBloc(_repository)),
      ],
      child: AdaptiveApp.router(
        title: 'Keel',
        theme: KeelTheme.light,
        darkTheme: KeelTheme.dark,
        routerConfig: _router,
      ),
    ),
  );
}
