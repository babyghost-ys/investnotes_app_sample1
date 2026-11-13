import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/issued/bloc/issued_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';
import 'package:investnotes_app_sample1/features/shell/view/shell_page.dart';

class KeelApp extends StatelessWidget {
  const KeelApp({super.key});

  @override
  Widget build(BuildContext context) => RepositoryProvider(
    create: (_) => NotesRepository(),
    child: Builder(
      builder: (context) {
        final repository = context.read<NotesRepository>();
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ShellBloc()),
            BlocProvider(create: (_) => SessionBloc()),
            BlocProvider(create: (_) => OfferingsBloc(repository)),
            BlocProvider(create: (_) => IssuedBloc(repository)),
          ],
          child: const AdaptiveApp(
            title: 'Keel',
            theme: KeelTheme.light,
            darkTheme: KeelTheme.dark,
            home: ShellPage(),
          ),
        );
      },
    ),
  );
}
