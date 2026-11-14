import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/data/models/biometric_kind.dart';
import 'package:investnotes_app_sample1/data/models/issued_filter.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/issued/view/date_pick_sheet.dart';
import 'package:investnotes_app_sample1/features/issued/view/issued_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_route.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';

/// The root of a native sheet's own engine. Blocs and closures cannot cross
/// engines, so each sheet gets plain values in and hands plain values back.
Future<void> runNativeSheetApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configuration = await NativeSheet.bootstrap(
    encodeResult: (value) => switch (value) {
      OfferingFilter filter => filter.encode(),
      IssuedFilter filter => filter.encode(),
      DateTime date => date.toIso8601String(),
      _ => value,
    },
  );
  runApp(NativeSheetApp(configuration: configuration));
}

class NativeSheetApp extends StatelessWidget {
  const NativeSheetApp({super.key, required this.configuration});

  final Map<String, dynamic> configuration;

  Widget _content() {
    final argument = configuration['arguments'];
    final repository = NotesRepository();
    return switch (configuration['route']) {
      'offeringsFilter' => OfferingsFilterSheet(
        initial: OfferingFilter.decode((argument as Map)['filter'] as Object),
        type: NoteType.values.byName(argument['type'] as String),
        offerings: repository.offerings,
      ),
      'issuedFilter' => IssuedFilterSheet(
        initial: IssuedFilter.decode(argument as Object),
        notes: repository.issued,
      ),
      'datePick' => DatePickSheet(
        date: DateTime.parse((argument as Map)['date'] as String),
        first: DateTime.parse(argument['first'] as String),
        last: DateTime.parse(argument['last'] as String),
        end: argument['end'] as bool,
      ),
      final route => throw ArgumentError.value(route, 'route', 'Unknown sheet'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = configuration['brightness'] == 'dark'
        ? Brightness.dark
        : Brightness.light;
    final theme = brightness == Brightness.dark
        ? KeelTheme.dark
        : KeelTheme.light;
    final background = configuration['backgroundColor'] as int?;

    Widget themed(BuildContext context, Widget child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(platformBrightness: brightness),
      child: NativeTheme(
        data: theme,
        child: Theme(data: theme.material(brightness), child: child),
      ),
    );

    if (configuration['route'] == 'signIn') {
      return NativeStyleScope(
        style: NativeStyle.native,
        child: _SignInSheetApp(
          biometric: switch (configuration['arguments']) {
            {
              'biometricName': final String name,
              'biometricKind': final String kind,
            } =>
              (name: name, kind: BiometricKind.values.byName(kind)),
            _ => null,
          },
          theme: theme.cupertino(brightness),
          themed: themed,
          background: background == null ? null : Color(background),
        ),
      );
    }

    return NativeStyleScope(
      style: NativeStyle.native,
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: theme.cupertino(brightness),
        localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
        builder: (context, child) => themed(context, child!),
        home: NativeSheetContent(
          // Only a fit sheet measures its content; a full-height one lays
          // its own scrolling out in the space UIKit gives it.
          fits:
              configuration['detents'] == null ||
              configuration['detents'] == 'fit',
          backgroundColor: background == null ? null : Color(background),
          child: _content(),
        ),
      ),
    );
  }
}

/// The sign-in sheet: its own router, so Register and the forgotten
/// username and password pages push inside the sheet and come back to it.
///
/// With a [biometric] account it opens on the welcome back; signing in with
/// a password pushes onto the same stack from there.
class _SignInSheetApp extends StatefulWidget {
  const _SignInSheetApp({
    required this.biometric,
    required this.theme,
    required this.themed,
    required this.background,
  });

  final BiometricAccount? biometric;
  final CupertinoThemeData theme;
  final Widget Function(BuildContext, Widget) themed;
  final Color? background;

  @override
  State<_SignInSheetApp> createState() => _SignInSheetAppState();
}

class _SignInSheetAppState extends State<_SignInSheetApp> {
  late final _router = GoRouter(
    initialLocation: widget.biometric == null ? '/' : '/biometric',
    routes: [
      signInRoute(path: '/', sheet: true),
      biometricSignInRoute(path: '/biometric', sheet: true),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoApp.router(
    debugShowCheckedModeBanner: false,
    theme: widget.theme,
    localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
    routerConfig: _router,
    builder: (context, child) => widget.themed(
      context,
      NativeSheetContent(
        fits: false,
        backgroundColor: widget.background,
        child: SignInScope(
          base: '/',
          sheet: true,
          biometric: widget.biometric,
          onSignedIn: (name) => NativeSheet.pop(context, name),
          onClose: () => NativeSheet.pop(context),
          child: child!,
        ),
      ),
    ),
  );
}
