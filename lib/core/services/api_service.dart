import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.uri});

  final String message;
  final int? statusCode;
  final Uri? uri;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

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
    final uri = _uri(path);
    try {
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(_timeout);
      return _decode(response, uri);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw _connectionException(uri, error);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    try {
      final response = await _client
          .post(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
      return _decode(response, uri);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw _connectionException(uri, error);
    }
  }

  dynamic _decode(http.Response response, Uri uri) {
    final body = response.body.trim();
    final dynamic decoded;

    try {
      decoded = body.isEmpty ? null : jsonDecode(body);
    } on FormatException {
      throw ApiException(
        'Respons CI4 bukan JSON valid. Cek error di server.',
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? decoded['error']?.toString()
          : null;
      throw ApiException(
        '${message ?? 'Request API gagal'} (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    return decoded;
  }

  ApiException _connectionException(Uri uri, Object error) {
    return ApiException(
      'Tidak bisa menghubungi API CI4 di $uri. Pastikan CI4 berjalan, route benar, dan CORS mengizinkan Flutter Web.',
      uri: uri,
    );
  }
}
