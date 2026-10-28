import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';

/// Firebase Authentication (email/password, Google, Apple) plus a small
/// profile document at users/{uid} in Firestore.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  static Future<void>? _googleSignInInitialization;

  AppUser? _toUser(User? u) {
    if (u == null) return null;
    return AppUser(
      id: u.uid,
      email: u.email ?? '',
      name: u.displayName ?? '',
      photoUrl: u.photoURL,
      provider: u.providerData.isNotEmpty
          ? u.providerData.first.providerId
          : 'password',
    );
  }

  /// userChanges() also fires when the display name is updated after sign-up.
  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_toUser);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    final cred = await _guard(
      () => _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
    await _saveProfile(cred);
  }

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _guard(
      () => _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
    try {
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
    } catch (_) {
      // Account exists; the name can be fixed later.
    }
    await _saveProfile(cred, name: name.trim());
  }

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final cred = await _guard(
        () => _auth.signInWithPopup(GoogleAuthProvider()),
      );
      await _saveProfile(cred);
      return;
    }

    try {
      _googleSignInInitialization ??= GoogleSignIn.instance.initialize();
      await _googleSignInInitialization;
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure('Google did not return an ID token.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _guard(() => _auth.signInWithCredential(credential));
      await _saveProfile(cred);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('', cancelled: true);
      }
      throw AuthFailure(
        e.description == null || e.description!.isEmpty
            ? 'Google sign-in failed (${e.code.name}).'
            : 'Google sign-in failed: ${e.description}',
      );
    }
  }

  @override
  Future<void> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final cred = await _guard(() => _auth.signInWithProvider(provider));
    await _saveProfile(cred);
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() => _auth.signOut();

  /// Creates/updates users/{uid}. Failures here never block sign-in.
  Future<void> _saveProfile(UserCredential cred, {String? name}) async {
    final u = cred.user;
    if (u == null) return;
    final displayName = (name != null && name.isNotEmpty)
        ? name
        : u.displayName;
    try {
      await _db.collection('users').doc(u.uid).set({
        if (displayName != null && displayName.isNotEmpty) 'name': displayName,
        'email': u.email,
        'photoUrl': u.photoURL,
        'provider': u.providerData.isNotEmpty
            ? u.providerData.first.providerId
            : 'password',
        'lastLoginAt': FieldValue.serverTimestamp(),
        if (cred.additionalUserInfo?.isNewUser ?? false)
          'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  AuthFailure _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AuthFailure('Enter a valid email address.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('Incorrect email or password.');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.');
      case 'email-already-in-use':
        return const AuthFailure(
          'An account with this email already exists. Try signing in.',
        );
      case 'weak-password':
        return const AuthFailure(
          'Password is too weak. Use at least 6 characters.',
        );
      case 'too-many-requests':
        return const AuthFailure(
          'Too many attempts. Please wait and try again.',
        );
      case 'network-request-failed':
        return const AuthFailure('No internet connection.');
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          'This email is registered with a different sign-in method.',
        );
      case 'operation-not-allowed':
        return const AuthFailure('This sign-in method is not enabled yet.');
      case 'canceled':
      case 'cancelled':
      case 'web-context-canceled':
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return const AuthFailure('', cancelled: true);
      default:
        return AuthFailure('Sign-in failed (${e.code}).');
    }
  }
}
