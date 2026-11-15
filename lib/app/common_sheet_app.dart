import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/app/sheet_arguments.dart';
import 'package:investnotes_app_sample1/domain/models/biometric_kind.dart';
import 'package:investnotes_app_sample1/domain/models/issued_filter.dart';
import 'package:investnotes_app_sample1/data/mappers/notes_mapper.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/offering_filter.dart';
import 'package:investnotes_app_sample1/features/education/view/film_fullscreen.dart';
import 'package:investnotes_app_sample1/features/issued/view/date_pick_sheet.dart';
import 'package:investnotes_app_sample1/features/issued/view/issued_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_route.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';

/// The root of a native sheet's own engine. Blocs and closures cannot cross
/// engines, so each sheet gets plain values in and hands plain values back.
Future<void> runCommonSheetApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configuration = await NativeSheet.bootstrap(
    encodeResult: (value) => switch (value) {
      OfferingFilter filter => filter.encode(),
      IssuedFilter filter => filter.encode(),
      DateTime date => date.toIso8601String(),
      _ => value,
    },
  );
  runApp(CommonSheetApp(configuration: configuration));
}

class CommonSheetApp extends StatelessWidget {
  const CommonSheetApp({super.key, required this.configuration});

  final Map<String, dynamic> configuration;

  /// What the page opened the sheet with, without its language.
  Object? get _argument => SheetArguments.value(configuration['arguments']);

  Widget _content() {
    final argument = _argument;
    return switch (configuration['route']) {
      'offeringsFilter' => OfferingsFilterSheet(
        initial: OfferingFilter.decode((argument as Map)['filter'] as Object),
        type: NoteType.values.byName(argument['type'] as String),
        offerings: NotesJson.toOfferings(argument['offerings']),
      ),
      'issuedFilter' => IssuedFilterSheet(
        initial: IssuedFilter.decode((argument as Map)['filter'] as Object),
        notes: NotesJson.toIssued(argument['notes']),
      ),
      'datePick' => DatePickSheet(
        date: DateTime.parse((argument as Map)['date'] as String),
        first: DateTime.parse(argument['first'] as String),
        last: DateTime.parse(argument['last'] as String),
        end: argument['end'] as bool,
      ),
      'film' => FilmFullscreen(
        asset: (argument as Map)['asset'] as String,
        start: Duration(milliseconds: argument['position'] as int),
        playing: argument['playing'] as bool,
      ),
      final route => throw ArgumentError.value(route, 'route', 'Unknown sheet'),
    };
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    // The sheet speaks the language the app spoke when it opened it.
    create: (_) => SheetArguments.localisation(configuration['arguments']),
    child: _sheet(context),
  );

  Widget _sheet(BuildContext context) {
    // The app's forced mode, or the system's as it changes: the sheet's
    // window follows the system live, and this rebuilds with it.
    final brightness = switch (configuration['brightness']) {
      'dark' => Brightness.dark,
      'light' => Brightness.light,
      _ => MediaQuery.platformBrightnessOf(context),
    };
    final theme = brightness == Brightness.dark
        ? KeelTheme.dark
        : KeelTheme.light;
    final background =
        (brightness == Brightness.dark
                ? configuration['backgroundColorDark']
                : null)
            as int? ??
        configuration['backgroundColor'] as int?;

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
          biometric: switch (_argument) {
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
