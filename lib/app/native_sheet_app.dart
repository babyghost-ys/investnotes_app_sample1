import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/keel_theme.dart';
import 'package:investnotes_app_sample1/data/models/issued_filter.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/issued/view/date_pick_sheet.dart';
import 'package:investnotes_app_sample1/features/issued/view/issued_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_sheet.dart';

/// The root of a native sheet's own engine. Blocs and closures cannot cross
/// engines, so each sheet gets plain values in and hands plain values back.
Future<void> runNativeSheetApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configuration = await AdaptiveNativeSheet.bootstrap(
    encodeResult: (value) => switch (value) {
      OfferingFilter filter => filter.encode(),
      IssuedFilter filter => filter.encode(),
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
      'signIn' => const SignInSheet(),
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
    final route = configuration['route'];
    return AdaptiveStyleScope(
      style: AdaptiveStyle.native,
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: theme.cupertino(brightness),
        localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(platformBrightness: brightness),
          child: AdaptiveTheme(
            data: theme,
            child: Theme(data: theme.material(brightness), child: child!),
          ),
        ),
        home: AdaptiveNativeSheetContent(
          fits: route != 'signIn',
          backgroundColor: background == null ? null : Color(background),
          child: _content(),
        ),
      ),
    );
  }
}
