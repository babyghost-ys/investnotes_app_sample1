import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:investnotes_app_sample1/data/models/article.dart';

/// Articles kept on this device to read offline.
///
/// There is no server yet: [fetch] simulates a transfer at a realistic,
/// uneven pace. When the API lands, it streams the real bytes received
/// over the file's size instead, and nothing above it changes.
class DownloadsRepository {
  DownloadsRepository();

  static const _key = 'downloads.articles';

  /// How far along the transfer of [article] is, from 0 to 1. Ends at 1.
  Stream<double> fetch(Article article) async* {
    final random = math.Random();
    var received = 0.0;
    yield received;
    while (received < 1) {
      await Future<void>.delayed(
        Duration(milliseconds: 180 + random.nextInt(160)),
      );
      // Bursts and stalls, the way a file arrives over a phone network.
      received = math.min(1, received + 0.02 + random.nextDouble() * 0.09);
      yield received;
    }
  }

  /// The ids of the articles on this device, most recent first.
  Future<List<String>> kept() async =>
      (await SharedPreferences.getInstance()).getStringList(_key) ?? const [];

  Future<void> keep(List<String> ids) async =>
      (await SharedPreferences.getInstance()).setStringList(_key, ids);
}
