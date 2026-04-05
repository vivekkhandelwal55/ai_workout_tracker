import '../../../shared/models/user_profile.dart';
import '../../../core/errors/failures.dart';

abstract interface class AuthRepository {
  Stream<UserProfile?> get authStateChanges;
  UserProfile? get currentUser;
  Future<(UserProfile?, Failure?)> signInWithEmail(String email, String password);
  Future<(UserProfile?, Failure?)> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  });
  Future<(UserProfile?, Failure?)> signInWithGoogle();
  Future<Failure?> updateUserProfile(UserProfile profile);
  Future<Failure?> signOut();
  Future<Failure?> sendPasswordResetEmail(String email);
}
