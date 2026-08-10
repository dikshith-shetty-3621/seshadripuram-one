import '../domain/app_user.dart';

/// Abstract interface for Authentication.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<void> loginWithUSN(String usn, String password);
  Future<void> loginWithEmployeeId(String employeeId, String password);
  Future<void> logout();
}
