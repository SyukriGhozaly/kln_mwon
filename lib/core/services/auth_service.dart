import 'api_service.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final Map<String, dynamic> user;
}

class AuthService {
  AuthService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static AuthSession? _currentSession;

  final ApiService _apiService;

  Future<AuthSession> login({
    required String login,
    required String password,
  }) async {
    final response = await _apiService.post('/login', {
      'login': login,
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
    final response = await _apiService.post('/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    final session = _sessionFromResponse(response);
    await saveSession(session);
    return session;
  }

  Future<bool> hasSession() async {
    return _currentSession != null;
  }

  Future<void> saveSession(AuthSession session) async {
    _currentSession = session;
  }

  Future<void> logout() async {
    _currentSession = null;
  }

  AuthSession _sessionFromResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException('Respons login tidak valid');
    }

    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    final token = payload['token']?.toString();
    final user = payload['user'];

    if (token == null || token.isEmpty || user is! Map<String, dynamic>) {
      throw const ApiException('Data sesi dari server tidak lengkap');
    }

    return AuthSession(token: token, user: user);
  }
}
