import '../models/app_user.dart';

/// Thrown by auth repositories with a message that is safe to show to users.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.cancelled = false});

  final String message;

  /// True when the user simply closed the Google/Apple sheet (no error shown).
  final bool cancelled;

  @override
  String toString() => message;
}

/// Auth contract used by AuthProvider. The Firebase version lives in
/// firebase_auth_repository.dart.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
