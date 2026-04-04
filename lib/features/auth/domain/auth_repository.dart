import '../../../shared/models/user_profile.dart';
import '../../../core/errors/failures.dart';

abstract class AuthRepository {
  Stream<String?> get authStateChanges; // user ID or null
  Future<(UserProfile?, Failure?)> signInWithEmail(String email, String password);
  Future<(UserProfile?, Failure?)> signUpWithEmail(String email, String password);
  Future<Failure?> signOut();
  String? get currentUserId;
}
