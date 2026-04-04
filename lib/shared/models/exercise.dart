enum MuscleGroup { chest, back, legs, shoulders, arms, core, fullBody }

enum TrackingUnit { weightReps, timeOnly, distanceTime, bodyweightReps }

enum ExerciseType { compound, isolation, cardio }

class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final String? secondaryMuscleDescription; // e.g. "UPPER CHEST"
  final ExerciseType type;
  final TrackingUnit trackingUnit;
  final String? equipmentName; // e.g. "BARBELL", "DUMBBELL", "CABLE"
  final String? gifUrl;
  final List<String> tips;
  final bool isCustom;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscleDescription,
    required this.type,
    required this.trackingUnit,
    this.equipmentName,
    this.gifUrl,
    required this.tips,
    required this.isCustom,
  });

  Exercise copyWith({
    String? id,
    String? name,
    MuscleGroup? primaryMuscle,
    String? secondaryMuscleDescription,
    ExerciseType? type,
    TrackingUnit? trackingUnit,
    String? equipmentName,
    String? gifUrl,
    List<String>? tips,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscleDescription: secondaryMuscleDescription ?? this.secondaryMuscleDescription,
      type: type ?? this.type,
      trackingUnit: trackingUnit ?? this.trackingUnit,
      equipmentName: equipmentName ?? this.equipmentName,
      gifUrl: gifUrl ?? this.gifUrl,
      tips: tips ?? this.tips,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
