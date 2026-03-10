import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/auth_user.dart';

class AuthResult {
  final String token;
  final AuthUser user;

  AuthResult({
    required this.token,
    required this.user,
  });
}

class AuthRepo {
  Dio get _dio => ApiClient.I.dio;

  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login/email', data: {
      'email': email,
      'password': password,
      'device_name': 'flutter-app',
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      final data = Map<String, dynamic>.from(body['data']);
      return AuthResult(
        token: (data['token'] ?? '').toString(),
        user: AuthUser.fromJson(Map<String, dynamic>.from(data['user'])),
      );
    }

    throw Exception('Login failed');
  }

  Future<void> sendOtp({
    required String phone,
  }) async {
    final res = await _dio.post('/auth/login/phone/send', data: {
      'phone': phone,
    });

    final body = res.data;
    if (!(body is Map && body['ok'] == true)) {
      throw Exception('OTP send failed');
    }
  }

  Future<AuthResult> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final res = await _dio.post('/auth/login/phone/verify', data: {
      'phone': phone,
      'code': code,
      'device_name': 'flutter-app',
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      final data = Map<String, dynamic>.from(body['data']);
      return AuthResult(
        token: (data['token'] ?? '').toString(),
        user: AuthUser.fromJson(Map<String, dynamic>.from(data['user'])),
      );
    }

    throw Exception('OTP verify failed');
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': 'flutter-app',
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      final data = Map<String, dynamic>.from(body['data']);
      return AuthResult(
        token: (data['token'] ?? '').toString(),
        user: AuthUser.fromJson(Map<String, dynamic>.from(data['user'])),
      );
    }

    throw Exception('Register failed');
  }

  Future<AuthUser> me() async {
    final res = await _dio.get('/auth/me');
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = Map<String, dynamic>.from(body['data']);
      return AuthUser.fromJson(Map<String, dynamic>.from(data['user']));
    }

    throw Exception('Unauthorized');
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<void> syncFavorites(List<int> ids) async {
    if (ids.isEmpty) return;

    final res = await _dio.post('/auth/favorites/sync', data: {
      'ad_ids': ids,
    });

    final body = res.data;
    if (!(body is Map && body['ok'] == true)) {
      throw Exception('Favorites sync failed');
    }
  }
}