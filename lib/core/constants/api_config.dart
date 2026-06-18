import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const configuredUrl = String.fromEnvironment('API_BASE_URL');

  // XAMPP Apache Android emulator: http://10.0.2.2/klinik_mawon/public
  // XAMPP Apache Flutter web/local desktop: http://localhost/klinik_mawon/public
  // php spark serve Android emulator: http://10.0.2.2:8080
  // php spark serve Flutter web/local desktop: http://localhost:8080
  // Real device: use your laptop/server LAN IP, for example http://192.168.1.10:8080
  // Production: use your deployed API URL.
  static String get baseUrl {
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/klinik_mawon/public';
    }

    return 'http://localhost/klinik_mawon/public';
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
  static const appointmentPath = '/appointment';
  static const paymentsPath = '/payments';

  static const bookingReadPaths = [bookingsPath, appointmentPath];
  static const bookingCreatePaths = [bookingsPath, appointmentPath];
}
