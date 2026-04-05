// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  age: (json['age'] as num?)?.toInt(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  heightCm: (json['heightCm'] as num?)?.toDouble(),
  primaryGoal:
      $enumDecodeNullable(_$FitnessGoalEnumMap, json['primaryGoal']) ??
      FitnessGoal.generalFitness,
  experienceLevel:
      $enumDecodeNullable(_$ExperienceLevelEnumMap, json['experienceLevel']) ??
      ExperienceLevel.beginner,
  onboardingComplete: json['onboardingComplete'] as bool? ?? false,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'age': instance.age,
      'weightKg': instance.weightKg,
      'heightCm': instance.heightCm,
      'primaryGoal': _$FitnessGoalEnumMap[instance.primaryGoal]!,
      'experienceLevel': _$ExperienceLevelEnumMap[instance.experienceLevel]!,
      'onboardingComplete': instance.onboardingComplete,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$FitnessGoalEnumMap = {
  FitnessGoal.hypertrophy: 'hypertrophy',
  FitnessGoal.fatLoss: 'fatLoss',
  FitnessGoal.endurance: 'endurance',
  FitnessGoal.strength: 'strength',
  FitnessGoal.generalFitness: 'generalFitness',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};
