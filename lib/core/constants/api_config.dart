import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  // Android emulator: http://10.0.2.2:8080
  // Real device: use your laptop/server LAN IP, for example http://192.168.1.10:8080
  // Production: use your deployed API URL.
  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');

    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  static const apiPrefix = '/api';
}
