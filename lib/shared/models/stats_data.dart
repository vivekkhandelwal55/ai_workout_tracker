class WeeklyStats {
  final int workoutsThisWeek;
  final double totalVolumeKg;
  final double averageIntensity; // 0-100
  final int currentStreak; // days
  final int totalPRsThisWeek;

  const WeeklyStats({
    required this.workoutsThisWeek,
    required this.totalVolumeKg,
    required this.averageIntensity,
    required this.currentStreak,
    required this.totalPRsThisWeek,
  });
}

class StrengthDataPoint {
  final DateTime date;
  final double weight;
  final int reps;

  const StrengthDataPoint({
    required this.date,
    required this.weight,
    required this.reps,
  });
}

class MonthlyFrequency {
  final int month; // 1-12
  final int year;
  final int workoutCount;

  const MonthlyFrequency({
    required this.month,
    required this.year,
    required this.workoutCount,
  });
}

class LifetimeStats {
  final int totalSessions;
  final double totalVolumeKg;
  final int totalSets;

  const LifetimeStats({
    required this.totalSessions,
    required this.totalVolumeKg,
    required this.totalSets,
  });
}
