import 'package:flutter_test/flutter_test.dart';
import 'package:kln_mwon/core/services/session_manager.dart';
import 'package:kln_mwon/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.clear();
  });

  test('stores profile photo url in session so profile screen can display it', () async {
    await SessionManager.save(
      newToken: 'token-123',
      newUser: {
        'name': 'Rina',
        'email': 'rina@example.com',
        'photo_url': 'https://example.com/uploads/profile.jpg',
      },
    );

    final profile = ProfileData.fromJson(SessionManager.user ?? const {});

    expect(profile.photoUrl, 'https://example.com/uploads/profile.jpg');
  });
}
