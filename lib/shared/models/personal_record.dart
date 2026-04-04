class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime achievedAt;
  final bool isNew; // achieved in the current session

  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.achievedAt,
    required this.isNew,
  });

  PersonalRecord copyWith({
    String? exerciseId,
    String? exerciseName,
    double? weight,
    int? reps,
    DateTime? achievedAt,
    bool? isNew,
  }) {
    return PersonalRecord(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      achievedAt: achievedAt ?? this.achievedAt,
      isNew: isNew ?? this.isNew,
    );
  }
}
