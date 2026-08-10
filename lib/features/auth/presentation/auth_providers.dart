import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

/// Provider for the AuthRepository.
/// Throws UnimplementedError by default. Must be overridden in ProviderScope
/// if a concrete implementation is provided.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository is not implemented yet.');
});

/// Exposes the current authentication state as a stream.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Exposes the current user synchronously.
final currentUserProvider = Provider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});
