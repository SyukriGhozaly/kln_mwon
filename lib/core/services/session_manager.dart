class SessionManager {
  const SessionManager._();

  static String? token;
  static Map<String, dynamic>? user;

  static bool get hasSession => token != null && token!.isNotEmpty;

  static void save({
    required String newToken,
    required Map<String, dynamic> newUser,
  }) {
    token = newToken;
    user = newUser;
  }

  static void clear() {
    token = null;
    user = null;
  }
}
