class ApiConfig {
  const ApiConfig._();

  static const configuredUrl = String.fromEnvironment('API_BASE_URL');

  // Flutter web with local CI4 backend.
  // TODO(api): Change through --dart-define=API_BASE_URL=... for non-local builds.
  static String get baseUrl {
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    return 'http://localhost:8080';
  }

  static const apiPrefix = '/api';

  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  static const loginPath = '/login';
  static const registerPath = '/register';
  static const logoutPath = '/logout';
  static const profilePath = '/profile';
  static const doctorsPath = '/doctors';
  static const schedulesPath = '/schedules';
  static const bookingsPath = '/bookings';
  static const paymentsPath = '/payments';
}
