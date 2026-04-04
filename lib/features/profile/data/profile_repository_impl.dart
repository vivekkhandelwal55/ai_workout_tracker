import '../domain/profile_repository.dart';
import '../../../shared/models/user_profile.dart';
import '../../../core/errors/failures.dart';

class StubProfileRepository implements ProfileRepository {
  UserProfile? _profile;

  @override
  Future<(UserProfile?, Failure?)> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profile ??= UserProfile(
      id: userId,
      name: 'Alex Mercer',
      age: 24,
      weight: 82,
      height: 185,
      primaryGoal: FitnessGoal.hypertrophy,
    );
    return (_profile, null);
  }

  @override
  Future<Failure?> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _profile = profile;
    return null;
  }
}
