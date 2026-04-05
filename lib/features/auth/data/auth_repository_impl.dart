import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../domain/auth_repository.dart';
import '../../../shared/models/user_profile.dart';
import '../../../core/errors/failures.dart';
import 'firebase_auth_data_source.dart';
import 'user_profile_data_source.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  FirebaseAuthRepositoryImpl(this._authDataSource, this._profileDataSource);

  final FirebaseAuthDataSource _authDataSource;
  final UserProfileDataSource _profileDataSource;

  @override
  Stream<UserProfile?> get authStateChanges {
    return _authDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _profileDataSource.fetchProfile(firebaseUser.uid);
    });
  }

  // currentUser is not cached in memory — the router uses authStateChanges stream.
  @override
  UserProfile? get currentUser => null;

  @override
  Future<(UserProfile?, Failure?)> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDataSource.signInWithEmail(email, password);
      final profile = await _getOrCreateProfile(user);
      return (profile, null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return (null, AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(UserProfile?, Failure?)> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final user = await _authDataSource.signUpWithEmail(email, password);
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      final refreshed =
          _authDataSource.currentFirebaseUser ?? user;
      final profile = await _getOrCreateProfile(refreshed);
      return (profile, null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return (null, AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(UserProfile?, Failure?)> signInWithGoogle() async {
    try {
      final user = await _authDataSource.signInWithGoogle();
      final profile = await _getOrCreateProfile(user);
      return (profile, null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return (null, AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> updateUserProfile(UserProfile profile) async {
    try {
      await _profileDataSource.updateProfile(profile);
      return null;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> signOut() async {
    try {
      await _authDataSource.signOut();
      return null;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> sendPasswordResetEmail(String email) async {
    try {
      await _authDataSource.sendPasswordResetEmail(email);
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseError(e.code));
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  // Fetches an existing Firestore profile or creates a new one on first sign-in.
  Future<UserProfile> _getOrCreateProfile(
    firebase_auth.User firebaseUser,
  ) async {
    final existing =
        await _profileDataSource.fetchProfile(firebaseUser.uid);
    if (existing != null) return existing;

    final now = DateTime.now();
    final newProfile = UserProfile(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      avatarUrl: firebaseUser.photoURL,
      onboardingComplete: false,
      createdAt: now,
      updatedAt: now,
    );
    await _profileDataSource.createProfile(newProfile);
    return newProfile;
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found for this email',
      'wrong-password' => 'Incorrect password',
      'email-already-in-use' => 'An account already exists with this email',
      'invalid-email' => 'Please enter a valid email address',
      'weak-password' => 'Password must be at least 6 characters',
      'network-request-failed' => 'Network error. Check your connection',
      _ => 'Authentication failed. Please try again',
    };
  }
}
