import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seshadripuram_one/core/config/app_config.dart';
import 'package:seshadripuram_one/core/storage/secure_storage_service.dart';
import 'package:seshadripuram_one/features/auth/data/api_auth_repository.dart';

class _MockDio extends Mock implements Dio {}
class _MockStorage extends Mock implements SecureStorageService {}

void main() {
  late Dio dio;
  late SecureStorageService storage;
  late ApiAuthRepository repository;

  setUp(() {
    AppConfig.debugBaseUrl = 'https://api.test';
    dio = _MockDio();
    storage = _MockStorage();
    repository = ApiAuthRepository(dio, storage);
  });

  tearDown(() {
    AppConfig.debugBaseUrl = null;
    repository.dispose();
  });

  test('persists tokens and maps the server role on successful login', () async {
    when(() => dio.post<Map<String, dynamic>>('/api/auth/login', data: any(named: 'data'))).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        data: {
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
          'user': {'id': '1', 'institutionId': 'S-001', 'name': 'Student', 'role': 'STUDENT'},
        },
      ),
    );
    when(() => storage.saveToken(any())).thenAnswer((_) async {});
    when(() => storage.saveRefreshToken(any())).thenAnswer((_) async {});

    await repository.login('S-001', 'secure-password-123');

    expect(repository.currentUser?.institutionId, 'S-001');
    expect(repository.currentUser?.role.name, 'student');
    verify(() => storage.saveToken('access-token')).called(1);
    verify(() => storage.saveRefreshToken('refresh-token')).called(1);
  });

  test('surfaces a safe API error on login failure', () async {
    when(() => dio.post<Map<String, dynamic>>('/api/auth/login', data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(requestOptions: RequestOptions(path: '/api/auth/login'), statusCode: 401, data: {'error': 'Invalid credentials'}),
      ),
    );

    expect(() => repository.login('S-001', 'wrong-password'), throwsA(isA<AuthException>()));
  });
}
