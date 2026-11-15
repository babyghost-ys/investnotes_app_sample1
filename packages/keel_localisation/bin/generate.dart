// Turns the app's JSON into typed classes and one archive.
//
// Run from the app's root:
//
//   dart run keel_localisation:generate
//
// Options (defaults in brackets):
//   --source   the JSON folders                    [l10n]
//   --out      where the Dart classes go           [lib/core/l10n/generated]
//   --archive  the archive the app ships           [assets/l10n/l10n.tar.bz2]
//   --master   the language every other must match [en]
//
// Each namespace is a folder of `<namespace>-<language>.json` files. Every
// language must have every namespace, with the same sections, the same
// keys and the same placeholders as the master. The generator stops with
// every problem listed when one does not.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

void main(List<String> arguments) {
  final options = _options(arguments);
  final source = Directory(options['source']!);
  final out = Directory(options['out']!);
  final archive = File(options['archive']!);
  final master = options['master']!;

  if (!source.existsSync()) {
    _fail(['No source folder at ${source.path}.']);
  }

  final problems = <String>[];
  final namespaces = _read(source, master, problems);
  if (problems.isNotEmpty) _fail(problems);

  // Only what changed is written, so a build with the same JSON finds every
  // file as it was and recompiles nothing.
  out.createSync(recursive: true);
  final dart = <String, String>{
    for (final namespace in namespaces)
      '${out.path}/${namespace.fileName}_locale.dart': _namespaceClass(
        namespace,
      ),
    '${out.path}/locales.dart': _locales(namespaces),
  };
  var changed = 0;
  for (final stale in out.listSync().whereType<File>()) {
    if (stale.path.endsWith('.dart') && !dart.containsKey(stale.path)) {
      stale.deleteSync();
      changed++;
    }
  }
  final formatted = _format(dart);
  for (final MapEntry(key: path, value: text) in formatted.entries) {
    final file = File(path);
    if (file.existsSync() && file.readAsStringSync() == text) continue;
    file.writeAsStringSync(text);
    changed++;
  }

  final bytes = _pack(namespaces);
  if (!archive.existsSync() || !_sameBytes(archive.readAsBytesSync(), bytes)) {
    archive.parent.createSync(recursive: true);
    archive.writeAsBytesSync(bytes);
    changed++;
  }

  final languages = namespaces.first.files.keys.toList()..sort();
  stdout.writeln(
    'keel_localisation: ${namespaces.length} namespaces in '
    '${languages.join(', ')}; '
    '${changed == 0 ? 'nothing changed' : '$changed files written'}.',
  );
}

/// [files] as `dart format` leaves them, so formatting the project never
/// disagrees with the generator and no build rewrites a file for nothing.
Map<String, String> _format(Map<String, String> files) {
  final temp = Directory.systemTemp.createTempSync('keel_localisation');
  try {
    final names = <String, String>{};
    var i = 0;
    for (final path in files.keys) {
      final name = '${temp.path}/f${i++}.dart';
      names[path] = name;
      File(name).writeAsStringSync(files[path]!);
    }
    final result = Process.runSync(Platform.resolvedExecutable, [
      'format',
      temp.path,
    ]);
    if (result.exitCode != 0) {
      _fail(['dart format failed: ${result.stderr}']);
    }
    return {
      for (final MapEntry(key: path, value: name) in names.entries)
        path: File(name).readAsStringSync(),
    };
  } finally {
    temp.deleteSync(recursive: true);
  }
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Map<String, String> _options(List<String> arguments) {
  final options = {
    'source': 'l10n',
    'out': 'lib/core/l10n/generated',
    'archive': 'assets/l10n/l10n.tar.bz2',
    'master': 'en',
  };
  for (var i = 0; i < arguments.length; i++) {
    final name = arguments[i].replaceFirst(RegExp('^--'), '');
    if (!options.containsKey(name) || i + 1 >= arguments.length) {
      _fail(['Unknown or incomplete option: ${arguments[i]}']);
    }
    options[name] = arguments[++i];
  }
  return options;
}

Never _fail(List<String> problems) {
  stderr.writeln('keel_localisation: nothing generated.');
  for (final problem in problems) {
    stderr.writeln('  - $problem');
  }
  exit(1);
}

/// One namespace: its folder name and every language's decoded file.
class _Namespace {
  _Namespace(this.name, this.files, this.master);

  final String name;

  /// Language, then section, then key, then text.
  final Map<String, Map<String, Map<String, String>>> files;
  final String master;

  Map<String, Map<String, String>> get masterFile => files[master]!;

  /// `my-notes` as `my_notes`, for the file.
  String get fileName => name.replaceAll('-', '_');

  /// `my-notes` as `myNotes`, for the constant.
  String get constant => _camel(name.split('-'));

  /// `my-notes` as `MyNotes`, for the classes.
  String get type => _pascal(name.split('-'));
}

String _camel(List<String> words) =>
    words.first + words.skip(1).map(_capital).join();

String _pascal(List<String> words) => words.map(_capital).join();

String _capital(String word) =>
    word.isEmpty ? word : word[0].toUpperCase() + word.substring(1);

const _sections = ['labels', 'semantics'];
final _namespaceName = RegExp(r'^[a-z][a-z0-9]*(-[a-z0-9]+)*$');
final _fileName = RegExp(r'^(.+)-([a-z]{2,3})\.json$');
final _key = RegExp(r'^[a-z][A-Za-z0-9]*$');
final _placeholder = RegExp(r'\{(\w+)\}');

const _reserved = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
  'hashCode',
  'runtimeType',
  'toString',
  'noSuchMethod',
  'language',
};

Set<String> _placeholders(String text) => {
  for (final m in _placeholder.allMatches(text)) m[1]!,
};

List<_Namespace> _read(Directory source, String master, List<String> problems) {
  final folders = source.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final namespaces = <_Namespace>[];
  final languages = <String>{};

  for (final folder in folders) {
    final name = folder.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (!_namespaceName.hasMatch(name)) {
      problems.add('$name: a namespace is lower-case words joined by "-".');
      continue;
    }
    final files = <String, Map<String, Map<String, String>>>{};
    for (final file in folder.listSync().whereType<File>()) {
      final base = file.uri.pathSegments.last;
      if (base.startsWith('.')) continue;
      final match = _fileName.firstMatch(base);
      if (match == null || match[1] != name) {
        problems.add('$name/$base: expected $name-<language>.json.');
        continue;
      }
      final language = match[2]!;
      final where = '$name/$base';
      final Object? json;
      try {
        json = jsonDecode(file.readAsStringSync());
      } on FormatException catch (e) {
        problems.add('$where: not valid JSON (${e.message}).');
        continue;
      }
      if (json is! Map) {
        problems.add('$where: the file must be an object.');
        continue;
      }
      final sections = <String, Map<String, String>>{};
      for (final MapEntry(:key, :value) in json.entries) {
        if (!_sections.contains(key)) {
          problems.add('$where: unknown section "$key".');
          continue;
        }
        if (value is! Map || value.isEmpty) {
          problems.add(
            '$where: "$key" must be an object with at least one key; '
            'leave the section out instead.',
          );
          continue;
        }
        final texts = <String, String>{};
        for (final MapEntry(key: k, value: v) in value.entries) {
          if (k is! String || !_key.hasMatch(k) || _reserved.contains(k)) {
            problems.add('$where: "$key.$k" is not a usable key name.');
          } else if (v is! String || v.isEmpty) {
            problems.add('$where: "$key.$k" must be text.');
          } else {
            texts[k] = v;
          }
        }
        sections[key as String] = texts;
      }
      if (!sections.containsKey('labels')) {
        problems.add('$where: every file needs a "labels" section.');
      }
      files[language] = sections;
      languages.add(language);
    }
    if (!files.containsKey(master)) {
      problems.add('$name: no $name-$master.json, the master language.');
      continue;
    }
    namespaces.add(_Namespace(name, files, master));
  }

  if (namespaces.isEmpty && problems.isEmpty) {
    problems.add('No namespaces in ${source.path}.');
  }

  final constants = <String, String>{};
  for (final namespace in namespaces) {
    final clash = constants[namespace.constant];
    if (clash != null) {
      problems.add('${namespace.name} and $clash make the same constant.');
    }
    constants[namespace.constant] = namespace.name;

    final masterFile = namespace.masterFile;
    for (final language in languages) {
      final where = '${namespace.name}/${namespace.name}-$language.json';
      final file = namespace.files[language];
      if (file == null) {
        problems.add('$where: missing; every language needs every namespace.');
        continue;
      }
      if (language == master) continue;
      for (final section in _sections) {
        final want = masterFile[section];
        final have = file[section];
        if (want == null && have == null) continue;
        if (want == null || have == null) {
          problems.add(
            '$where: ${want == null ? 'has' : 'lacks'} a "$section" '
            'section, unlike $master.',
          );
          continue;
        }
        for (final key in want.keys) {
          final text = have[key];
          if (text == null) {
            problems.add('$where: "$section.$key" is missing.');
          } else if (!_same(_placeholders(want[key]!), _placeholders(text))) {
            problems.add(
              '$where: "$section.$key" must use the placeholders '
              '${_placeholders(want[key]!)} as $master does.',
            );
          }
        }
        for (final key in have.keys) {
          if (!want.containsKey(key)) {
            problems.add('$where: "$section.$key" is not in $master.');
          }
        }
      }
    }
  }
  return namespaces;
}

bool _same(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

const _header =
    '// Generated by keel_localisation from the JSON in l10n/.\n'
    '// Do not edit: change the JSON and run\n'
    '//   dart run keel_localisation:generate\n\n';

String _namespaceClass(_Namespace namespace) {
  final type = namespace.type;
  final file = namespace.masterFile;
  final hasSemantics = file.containsKey('semantics');
  final buffer = StringBuffer(_header)
    ..writeln("import 'package:keel_localisation/keel_localisation.dart';")
    ..writeln()
    ..writeln('/// The "${namespace.name}" namespace.')
    ..writeln('final class ${type}Locale extends LocaleBundle {')
    ..writeln(
      '  ${type}Locale.fromJson(super.language, Map<String, Object?> json)',
    )
    ..write(
      "    : labels = ${type}Labels._(LocaleText.section(json, 'labels'))",
    );
  if (hasSemantics) {
    buffer
      ..writeln(',')
      ..write(
        '      semantics = ${type}Semantics._('
        "LocaleText.section(json, 'semantics'))",
      );
  }
  buffer
    ..writeln(';')
    ..writeln()
    ..writeln('  final ${type}Labels labels;');
  if (hasSemantics) {
    buffer
      ..writeln()
      ..writeln('  /// What assistive technologies say, where it differs.')
      ..writeln('  final ${type}Semantics semantics;');
  }
  buffer.writeln('}');
  _section(buffer, '${type}Labels', file['labels']!);
  if (hasSemantics) {
    _section(buffer, '${type}Semantics', file['semantics']!);
  }
  return buffer.toString();
}

void _section(StringBuffer buffer, String type, Map<String, String> texts) {
  buffer
    ..writeln()
    ..writeln('final class $type {')
    ..writeln('  const $type._(this._text);')
    ..writeln()
    ..writeln('  final Map<String, String> _text;');
  final keys = texts.keys.toList()..sort();
  for (final key in keys) {
    final english = texts[key]!.replaceAll('\n', ' ');
    final names = _placeholders(texts[key]!).toList()..sort();
    buffer
      ..writeln()
      ..writeln('  /// $english');
    if (names.isEmpty) {
      buffer.writeln("  String get $key => _text['$key']!;");
    } else {
      final parameters = names.map((n) => 'required Object $n').join(', ');
      final values = names.map((n) => "'$n': $n").join(', ');
      buffer
        ..writeln('  String $key({$parameters}) =>')
        ..writeln("      LocaleText.fill(_text['$key']!, {$values});");
    }
  }
  buffer.writeln('}');
}

String _locales(List<_Namespace> namespaces) {
  final buffer = StringBuffer(_header)
    ..writeln("import 'package:keel_localisation/keel_localisation.dart';")
    ..writeln();
  for (final namespace in namespaces) {
    buffer.writeln("import '${namespace.fileName}_locale.dart';");
  }
  buffer.writeln();
  for (final namespace in namespaces) {
    buffer.writeln("export '${namespace.fileName}_locale.dart';");
  }
  buffer
    ..writeln()
    ..writeln('/// Every namespace, for `LocalisationConsumer.namespaces`.')
    ..writeln('abstract final class Locales {');
  for (final namespace in namespaces) {
    buffer.writeln(
      "  static const ${namespace.constant} = '${namespace.name}';",
    );
  }
  buffer
    ..writeln()
    ..writeln('  static const all = [')
    ..writeAll(namespaces.map((n) => '    ${n.constant},\n'))
    ..writeln('  ];')
    ..writeln('}')
    ..writeln()
    ..writeln('/// How each namespace is built from its JSON.')
    ..writeln('const localeRegistry = LocaleRegistry({');
  for (final namespace in namespaces) {
    buffer.writeln(
      '  Locales.${namespace.constant}: ${namespace.type}Locale.fromJson,',
    );
  }
  buffer.writeln('});');
  return buffer.toString();
}

/// Every file, sorted and dated alike, so the same JSON packs to the same
/// bytes.
List<int> _pack(List<_Namespace> namespaces) {
  final archive = Archive();
  const encoder = JsonEncoder.withIndent('  ');
  for (final namespace in namespaces) {
    final languages = namespace.files.keys.toList()..sort();
    for (final language in languages) {
      final bytes = utf8.encode(encoder.convert(namespace.files[language]));
      archive.add(
        ArchiveFile.bytes(
          '${namespace.name}/${namespace.name}-$language.json',
          bytes,
        )..lastModTime = 0,
      );
    }
  }
  return BZip2Encoder().encodeBytes(TarEncoder().encodeBytes(archive));
}
