import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/profile_repository.dart';
import '../../../shared/models/user_profile.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/firestore_constants.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<(UserProfile?, Failure?)> getProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();
      if (!doc.exists || doc.data() == null) {
        return (null, null);
      }
      final data = doc.data()!;
      final profile = _fromFirestore(userId, data);
      return (profile, null);
    } catch (e) {
      return (null, UnknownFailure('Failed to fetch profile: $e'));
    }
  }

  @override
  Future<Failure?> saveProfile(UserProfile profile) async {
    try {
      final data = _toFirestore(profile);
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(profile.id)
          .set(data, SetOptions(merge: true));
      return null;
    } catch (e) {
      return UnknownFailure('Failed to save profile: $e');
    }
  }

  Map<String, dynamic> _toFirestore(UserProfile profile) {
    return {
      UserProfileFields.email: profile.email,
      UserProfileFields.displayName: profile.displayName,
      UserProfileFields.avatarUrl: profile.avatarUrl,
      UserProfileFields.age: profile.age,
      UserProfileFields.weightKg: profile.weightKg,
      UserProfileFields.heightCm: profile.heightCm,
      UserProfileFields.primaryGoal: profile.primaryGoal.name,
      UserProfileFields.experienceLevel: profile.experienceLevel.name,
      UserProfileFields.onboardingComplete: profile.onboardingComplete,
      UserProfileFields.createdAt: profile.createdAt != null
          ? Timestamp.fromDate(profile.createdAt!)
          : null,
      UserProfileFields.updatedAt: Timestamp.fromDate(DateTime.now()),
    };
  }

  UserProfile _fromFirestore(String uid, Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    FitnessGoal parseFitnessGoal(dynamic value) {
      if (value is String) {
        return FitnessGoal.values.byName(value);
      }
      return FitnessGoal.generalFitness;
    }

    ExperienceLevel parseExperienceLevel(dynamic value) {
      if (value is String) {
        return ExperienceLevel.values.byName(value);
      }
      return ExperienceLevel.beginner;
    }

    return UserProfile(
      id: uid,
      email: data[UserProfileFields.email] as String? ?? '',
      displayName: data[UserProfileFields.displayName] as String?,
      avatarUrl: data[UserProfileFields.avatarUrl] as String?,
      age: data[UserProfileFields.age] as int?,
      weightKg: (data[UserProfileFields.weightKg] as num?)?.toDouble(),
      heightCm: (data[UserProfileFields.heightCm] as num?)?.toDouble(),
      primaryGoal: parseFitnessGoal(data[UserProfileFields.primaryGoal]),
      experienceLevel:
          parseExperienceLevel(data[UserProfileFields.experienceLevel]),
      onboardingComplete:
          data[UserProfileFields.onboardingComplete] as bool? ?? false,
      createdAt: parseTimestamp(data[UserProfileFields.createdAt]),
      updatedAt: parseTimestamp(data[UserProfileFields.updatedAt]),
    );
  }
}
