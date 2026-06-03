import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}$normalizedPath',
    );
  }

  Future<Map<String, String>> _headers() async {
    return {'Content-Type': 'application/json'};
  }

  Future<dynamic> get(String path) async {
    final response = await _client.get(_uri(path), headers: await _headers());
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final body = response.body.trim();
    final decoded = body.isEmpty ? null : jsonDecode(body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? decoded['error']?.toString()
          : null;
      throw ApiException(
        message ?? 'Request API gagal',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}
