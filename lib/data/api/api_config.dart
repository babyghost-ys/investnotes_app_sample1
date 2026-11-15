/// Where the app's API lives: the Keel Worker on Cloudflare, unless a build
/// passes `--dart-define=API_BASE_URL=...`.
abstract final class ApiConfig {
  static final Uri baseUrl = Uri.parse(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://investnotes-api.tips-hk.workers.dev/',
    ),
  );

  /// How long a request may take before it counts as failed.
  static const timeout = Duration(seconds: 15);

  /// [path] under the API, e.g. `offerings` or `products/ppn-1`.
  static Uri endpoint(String path) => baseUrl.resolve(path);
}
