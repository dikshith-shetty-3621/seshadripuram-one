import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';
import 'auth_repository.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, this._storage);

  final Dio _dio;
  final SecureStorageService _storage;
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield await restoreSession();
    yield* _controller.stream;
  }

  @override
  Future<void> requestActivation(String institutionId) async {
    await _post('/api/auth/request-activation', {'institutionId': institutionId});
  }

  @override
  Future<ActivationGrant> verifyOtp(String institutionId, String otp) async {
    final data = await _post('/api/auth/verify-otp', {'institutionId': institutionId, 'otp': otp});
    return ActivationGrant(
      value: data['activationGrant'] as String,
      expiresIn: Duration(seconds: (data['expiresInSeconds'] as num).toInt()),
    );
  }

  @override
  Future<void> setPassword({required String institutionId, required String activationGrant, required String password}) async {
    await _post('/api/auth/set-password', {
      'institutionId': institutionId,
      'activationGrant': activationGrant,
      'password': password,
    });
  }

  @override
  Future<void> login(String institutionId, String password) async {
    final data = await _post('/api/auth/login', {'institutionId': institutionId, 'password': password});
    await _persistSession(data);
  }

  @override
  Future<AppUser?> restoreSession() async {
    if (AppConfig.baseUrl.isEmpty) return null;
    try {
      var token = await _storage.getToken();
      if (token == null) {
        token = await _refreshAccessToken();
        if (token == null) return null;
      }
      final response = await _dio.get<Map<String, dynamic>>('/api/auth/me');
      final user = _parseUser(response.data!['user'] as Map<String, dynamic>);
      _setCurrentUser(user);
      return user;
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) return null;
      final refreshed = await _refreshAccessToken();
      if (refreshed == null) {
        await _clearSession();
        return null;
      }
      try {
        final response = await _dio.get<Map<String, dynamic>>('/api/auth/me');
        final user = _parseUser(response.data!['user'] as Map<String, dynamic>);
        _setCurrentUser(user);
        return user;
      } on DioException {
        await _clearSession();
        return null;
      }
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    try {
      if (refreshToken != null && AppConfig.baseUrl.isNotEmpty) {
        await _post('/api/auth/logout', {'refreshToken': refreshToken});
      }
    } finally {
      await _clearSession();
    }
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final data = await _post('/api/auth/refresh', {'refreshToken': refreshToken});
      await _persistSession(data);
      return data['accessToken'] as String;
    } on AuthException {
      return null;
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    if (AppConfig.baseUrl.isEmpty) {
      throw const AuthException('API_BASE_URL has not been configured.');
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return response.data ?? const {};
    } on DioException catch (error) {
      final payload = error.response?.data;
      final message = payload is Map && payload['error'] is String
          ? payload['error'] as String
          : 'Unable to complete the request. Please try again.';
      throw AuthException(message);
    }
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    await _storage.saveToken(accessToken);
    await _storage.saveRefreshToken(refreshToken);
    final rawUser = data['user'];
    if (rawUser is Map<String, dynamic>) _setCurrentUser(_parseUser(rawUser));
  }

  AppUser _parseUser(Map<String, dynamic> json) {
    final role = switch (json['role']) {
      'STUDENT' => UserRole.student,
      'TEACHER' => UserRole.teacher,
      'ADMIN' => UserRole.admin,
      _ => throw const AuthException('The server returned an unknown user role.'),
    };
    return AppUser(
      id: json['id'] as String,
      institutionId: json['institutionId'] as String,
      name: json['name'] as String,
      role: role,
    );
  }

  void _setCurrentUser(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> _clearSession() async {
    await _storage.deleteToken();
    await _storage.deleteRefreshToken();
    _setCurrentUser(null);
  }

  void dispose() => _controller.close();
}
