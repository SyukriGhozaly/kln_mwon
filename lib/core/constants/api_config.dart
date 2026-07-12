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
    final rawBaseUrl = configuredUrl.isNotEmpty ? configuredUrl : _defaultUrl;

    return _withoutApiSuffix(_trimTrailingSlash(rawBaseUrl));
  }

  static String get _defaultUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  static String get apiBaseUrl => '$baseUrl/api';
  static const loginPath = '/login';
  static const registerPath = '/register';
  static const logoutPath = '/logout';
  static const profilePath = '/profile';
  static const doctorsPath = '/doctors';
  static const schedulesPath = '/schedules';
  static const bookingsPath = '/bookings';
  static const appointmentPath = '/appointment';
  static const paymentsPath = '/payments';

  static const bookingReadPaths = [bookingsPath];
  static const bookingCreatePaths = [bookingsPath];

  static Uri apiUri(String path) => _joinUri(apiBaseUrl, path);

  static Uri appUri(String path) => _joinUri(baseUrl, path);

  static String publicFileUrl(String? path) {
    final raw = path?.trim() ?? '';
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw.replaceFirst('/api/uploads/', '/uploads/').replaceFirst('/api/img/', '/img/');
    }

    final normalized = raw.replaceFirst(RegExp(r'^/+'), '');
    if (normalized.startsWith('api/uploads/') || normalized.startsWith('api/img/')) {
      return appUri(normalized.replaceFirst(RegExp(r'^api/'), '')).toString();
    }
    if (normalized.startsWith('uploads/') || normalized.startsWith('img/')) {
      return appUri(normalized).toString();
    }
    return appUri('img/$normalized').toString();
  }

  static Uri _joinUri(String base, String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }

    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse('${_trimTrailingSlash(base)}/$normalizedPath');
  }

  static String _trimTrailingSlash(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  static String _withoutApiSuffix(String value) {
    return value.replaceFirst(RegExp(r'/api$', caseSensitive: false), '');
  }
}
