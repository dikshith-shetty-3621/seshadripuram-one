class AppConfig {
  static const String appName = 'Seshadripuram One';

  /// Supply with `--dart-define=API_BASE_URL=https://your-api.example`.
  /// Deliberately empty by default: this project does not assume a hosted domain.
  static const String configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String? debugBaseUrl;

  static String get baseUrl => debugBaseUrl ?? configuredBaseUrl;
}
