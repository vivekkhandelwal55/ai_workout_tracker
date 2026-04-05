import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/user_profile.dart';

class UserProfileDataSource {
  UserProfileDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirestoreCollections.users);

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
      UserProfileFields.updatedAt: profile.updatedAt != null
          ? Timestamp.fromDate(profile.updatedAt!)
          : null,
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

  Future<UserProfile?> fetchProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return _fromFirestore(uid, doc.data()!);
  }

  Future<void> createProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.id).set(_toFirestore(profile));
  }

  Future<void> updateProfile(UserProfile profile) async {
    final data = _toFirestore(profile);
    data[UserProfileFields.updatedAt] = Timestamp.fromDate(DateTime.now());
    await _usersCollection.doc(profile.id).set(data, SetOptions(merge: true));
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return _fromFirestore(uid, snapshot.data()!);
    });
  }
}
