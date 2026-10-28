import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Sign-in / sign-up state plus form validators.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) {
    _subscription = _repository.authStateChanges().listen(
      (user) {
        _user = user;
        _status =
            user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
        notifyListeners();
      },
      onError: (_) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
    );
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? _user;
  AuthStatus _status = AuthStatus.unknown;
  bool _busy = false;
  String? _error;

  AppUser? get user => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get busy => _busy;
  String? get error => _error;

  // ---- Validators (error message, or null when valid) ----

  static String? validateName(String? v) =>
      (v == null || v.trim().length < 2) ? 'Enter your full name' : null;

  static String? validateEmail(String? v) {
    final value = (v ?? '').trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
        ? null
        : 'Enter a valid email address';
  }

  static String? validatePassword(String? v) =>
      (v == null || v.length < 6) ? 'Use at least 6 characters' : null;

  // ---- Actions (return true on success) ----

  Future<bool> signIn(String email, String password) =>
      _run(() => _repository.signInWithEmail(email, password));

  Future<bool> signUp(String name, String email, String password) => _run(() =>
      _repository.signUpWithEmail(name: name, email: email, password: password));

  Future<bool> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<bool> signInWithApple() => _run(_repository.signInWithApple);

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _repository.sendPasswordReset(email));

  Future<void> signOut() async {
    await _repository.signOut();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_busy) return false; // ignore double taps
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      if (!e.cancelled) _error = e.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
