import '../constants/api_config.dart';
import 'api_service.dart';
import 'session_manager.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final Map<String, dynamic> user;
}

class AuthService {
  AuthService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<AuthSession> login({
    required String login,
    required String password,
  }) async {
    final normalizedLogin = login.trim();
    final response = await _apiService.post(ApiConfig.loginPath, {
      'login': normalizedLogin,
      if (normalizedLogin.contains('@')) 'email': normalizedLogin,
      if (!normalizedLogin.contains('@')) 'username': normalizedLogin,
      'password': password,
    });
    final session = _sessionFromResponse(response);
    await saveSession(session);
    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiService.post(ApiConfig.registerPath, {
      'name': name,
      'nama': name,
      'email': email,
      'phone': phone,
      'no_hp': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final session = _sessionFromResponse(response);
    await saveSession(session);
    return session;
  }

  Future<bool> hasSession() async {
    await SessionManager.load();
    return SessionManager.hasSession;
  }

  Future<void> saveSession(AuthSession session) async {
    await SessionManager.save(newToken: session.token, newUser: session.user);
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logoutPath, {});
    } on ApiException {
      // Local logout must still work when the backend token is expired/offline.
    } finally {
      await SessionManager.clear();
    }
  }

  AuthSession _sessionFromResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException('Respons login tidak valid');
    }

    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    final token =
        payload['token']?.toString() ??
        payload['access_token']?.toString() ??
        payload['bearer_token']?.toString();
    final user = _userFromPayload(payload);

    if (token == null || token.isEmpty || user.isEmpty) {
      throw const ApiException('Data sesi dari server tidak lengkap');
    }

    return AuthSession(token: token, user: user);
  }

  Map<String, dynamic> _userFromPayload(Map<String, dynamic> payload) {
    final user = payload['user'] ?? payload['pasien'] ?? payload['patient'];
    if (user is Map<String, dynamic>) return user;
    if (user is Map) {
      return user.map((key, value) => MapEntry(key.toString(), value));
    }

    final dataUser = <String, dynamic>{};
    for (final key in [
      'id',
      'user_id',
      'id_user',
      'name',
      'nama',
      'nama_lengkap',
      'username',
      'email',
      'phone',
      'no_hp',
      'role',
    ]) {
      final value = payload[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        dataUser[key] = value;
      }
    }

    return dataUser;
  }
}
