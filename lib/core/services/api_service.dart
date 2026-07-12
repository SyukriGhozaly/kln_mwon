import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import 'session_manager.dart';

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
  static const _timeout = Duration(seconds: 5);

  Uri _uri(String path) {
    return ApiConfig.apiUri(path);
  }

  Future<Map<String, String>> _headers() async {
    await SessionManager.load();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (SessionManager.hasSession)
        'Authorization': 'Bearer ${SessionManager.token}',
    };
  }

  Future<Map<String, String>> requestHeaders() => _headers();

  Duration get timeout => _timeout;

  dynamic decodeResponse(http.Response response, Uri uri) => _decode(response, uri);

  Future<dynamic> get(String path) async {
    final uri = _uri(path);
    try {
      _debugRequest('GET', uri);
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(_timeout);
      return _decode(response, uri);
    } on ApiException {
      rethrow;
    } catch (error) {
      _debugRequestError('GET', uri, error);
      throw _connectionException(uri, error);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    try {
      _debugRequest('POST', uri, body);
      final response = await _client
          .post(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
      return _decode(response, uri);
    } on ApiException {
      rethrow;
    } catch (error) {
      _debugRequestError('POST', uri, error);
      throw _connectionException(uri, error);
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    try {
      _debugRequest('PUT', uri, body);
      final response = await _client
          .put(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
      return _decode(response, uri);
    } on ApiException {
      rethrow;
    } catch (error) {
      _debugRequestError('PUT', uri, error);
      throw _connectionException(uri, error);
    }
  }

  dynamic _decode(http.Response response, Uri uri) {
    final body = response.body.trim();
    debugPrint('API RESPONSE ${response.statusCode} $uri');
    debugPrint(body.isEmpty ? '<empty body>' : body);
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
      if (_shouldClearSession(response.statusCode, uri)) {
        unawaited(SessionManager.clear());
      }

      final message = decoded is Map<String, dynamic>
          ? _errorMessage(decoded)
          : null;
      throw ApiException(
        '${message ?? 'Request API gagal'} (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    if (decoded is Map<String, dynamic> && decoded['success'] == false) {
      throw ApiException(
        decoded['message']?.toString() ?? 'Request API gagal',
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    return decoded;
  }

  ApiException _connectionException(Uri uri, Object error) {
    return ApiException(
      'Tidak bisa menghubungi API CI4 di $uri. Detail: $error',
      uri: uri,
    );
  }

  void _debugRequestError(String method, Uri uri, Object error) {
    debugPrint('API $method $uri gagal: $error');
  }

  void _debugRequest(String method, Uri uri, [Map<String, dynamic>? body]) {
    debugPrint('API REQUEST $method $uri');
    if (body != null) debugPrint('API BODY ${jsonEncode(body)}');
  }

  bool _shouldClearSession(int statusCode, Uri uri) {
    if (statusCode != 401 && statusCode != 403) return false;
    return !uri.path.endsWith(ApiConfig.loginPath) &&
        !uri.path.endsWith(ApiConfig.registerPath);
  }

  String? _errorMessage(Map<String, dynamic> decoded) {
    final baseMessage =
        decoded['message']?.toString() ?? decoded['error']?.toString();
    final errors = decoded['errors'];
    final detail = _validationDetail(errors);

    if (detail == null || detail.isEmpty) return baseMessage;
    if (baseMessage == null || baseMessage.isEmpty) return detail;
    return '$baseMessage\n$detail';
  }

  String? _validationDetail(Object? errors) {
    if (errors is Map) {
      return errors.entries
          .map((entry) => entry.value?.toString() ?? '')
          .where((message) => message.trim().isNotEmpty)
          .join('\n');
    }
    if (errors is List) {
      return errors
          .map((message) => message.toString())
          .where((message) => message.trim().isNotEmpty)
          .join('\n');
    }
    return null;
  }
}
