import '../../../shared/models/user_profile.dart';
import '../../../core/errors/failures.dart';

abstract class ProfileRepository {
  Future<(UserProfile?, Failure?)> getProfile(String userId);
  Future<Failure?> saveProfile(UserProfile profile);
}
