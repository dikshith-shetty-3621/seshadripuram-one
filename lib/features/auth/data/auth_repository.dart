import '../domain/app_user.dart';

/// Abstract interface for Authentication.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<void> login(String institutionId, String password);
  Future<void> requestActivation(String institutionId);
  Future<ActivationGrant> verifyOtp(String institutionId, String otp);
  Future<void> setPassword({
    required String institutionId,
    required String activationGrant,
    required String password,
  });
  Future<AppUser?> restoreSession();
  Future<void> logout();
}

class ActivationGrant {
  final String value;
  final Duration expiresIn;

  const ActivationGrant({required this.value, required this.expiresIn});
}
