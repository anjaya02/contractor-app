abstract final class AppConfig {
  static const name = 'GIS Contractor';
  static const mapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const initialPlan = 'FTTH_Civilect Zone_2024_049_20261103104951';
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
