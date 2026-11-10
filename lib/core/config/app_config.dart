abstract final class AppConfig {
  // Keep the API version explicit; it must match the backend's appversion value.
  static const version = '1.0.0';
  static const requestTimeout = Duration(seconds: 25);

  static final apiBaseUrl = Uri.parse(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://serviceportal.slt.lk/ApiGisCon/public/api/',
    ),
  );
}
