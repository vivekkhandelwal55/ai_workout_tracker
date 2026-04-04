enum FitnessGoal { hypertrophy, fatLoss, endurance, strength, generalFitness }

class UserProfile {
  final String id;
  final String name;
  final int age;
  final double weight; // kg
  final double height; // cm
  final FitnessGoal primaryGoal;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.primaryGoal,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    double? weight,
    double? height,
    FitnessGoal? primaryGoal,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
