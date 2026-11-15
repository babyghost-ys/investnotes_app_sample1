import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

import 'package:keel_localisation/src/locale_catalogue.dart';
import 'package:keel_localisation/src/locale_registry.dart';

/// Every language's JSON, unpacked once from the app's archive.
///
/// The archive holds `<namespace>/<namespace>-<language>.json` for every
/// namespace. A key missing from a language falls back to [fallback]'s, so
/// a half-translated file never shows a blank.
class LocaleLibrary {
  LocaleLibrary(this.registry, this._files, {this.fallback = 'en'});

  /// Where the generator puts the archive by default.
  static const defaultAsset = 'assets/l10n/l10n.tar.bz2';

  final LocaleRegistry registry;
  final String fallback;

  /// Language, then namespace, then the decoded file.
  final Map<String, Map<String, Map<String, Object?>>> _files;

  final _catalogues = <String, LocaleCatalogue>{};

  static final _path = RegExp(r'^([a-z0-9-]+)/\1-([a-z]{2,3})\.json$');

  /// Reads and unpacks [asset] from [bundle].
  static Future<LocaleLibrary> load(
    LocaleRegistry registry, {
    String asset = defaultAsset,
    AssetBundle? bundle,
    String fallback = 'en',
  }) async {
    final data = await (bundle ?? rootBundle).load(asset);
    return decode(
      registry,
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      fallback: fallback,
    );
  }

  /// Unpacks the bytes of a `tar.bz2` archive.
  static LocaleLibrary decode(
    LocaleRegistry registry,
    List<int> bytes, {
    String fallback = 'en',
  }) {
    final tar = TarDecoder().decodeBytes(BZip2Decoder().decodeBytes(bytes));
    final files = <String, Map<String, Map<String, Object?>>>{};
    for (final file in tar) {
      if (!file.isFile) continue;
      final match = _path.firstMatch(file.name);
      if (match == null) continue;
      final json = jsonDecode(utf8.decode(file.content));
      (files[match[2]!] ??= {})[match[1]!] = (json as Map)
          .cast<String, Object?>();
    }
    if (!files.containsKey(fallback)) {
      throw StateError('The archive has no "$fallback" files.');
    }
    return LocaleLibrary(registry, files, fallback: fallback);
  }

  /// The languages the archive has, the fallback first.
  List<String> get languages => [
    fallback,
    ...files.keys.where((l) => l != fallback).toList()..sort(),
  ];

  Map<String, Map<String, Map<String, Object?>>> get files => _files;

  /// The first of [preferred] the archive has, or [fallback].
  String resolve(Iterable<Locale> preferred) {
    for (final locale in preferred) {
      if (_files.containsKey(locale.languageCode)) return locale.languageCode;
    }
    return fallback;
  }

  /// Every namespace in [language], built once and kept.
  LocaleCatalogue catalogue(String language) =>
      _catalogues[language] ??= LocaleCatalogue(language, {
        for (final namespace in registry.namespaces)
          namespace: registry.create(
            namespace,
            _files.containsKey(language) ? language : fallback,
            _merged(namespace, language),
          ),
      });

  /// [language]'s file for [namespace] over the fallback's, section by
  /// section and key by key.
  Map<String, Object?> _merged(String namespace, String language) {
    final base = _files[fallback]![namespace];
    if (base == null) {
      throw StateError('The archive has no "$fallback" file for "$namespace".');
    }
    final own = _files[language]?[namespace];
    if (own == null || language == fallback) return base;
    return {
      for (final section in {...base.keys, ...own.keys})
        section: {
          ...?(base[section] as Map?)?.cast<String, Object?>(),
          ...?(own[section] as Map?)?.cast<String, Object?>(),
        },
    };
  }
}
