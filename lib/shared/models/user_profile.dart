import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum FitnessGoal { hypertrophy, fatLoss, endurance, strength, generalFitness }

enum ExperienceLevel { beginner, intermediate, advanced }

@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    int? age,
    double? weightKg,
    double? heightCm,
    @Default(FitnessGoal.generalFitness) FitnessGoal primaryGoal,
    @Default(ExperienceLevel.beginner) ExperienceLevel experienceLevel,
    @Default(false) bool onboardingComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
