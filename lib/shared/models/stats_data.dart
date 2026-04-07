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
  final DateTime date;   // day-precision (time zeroed to midnight)
  final double weight;   // weight of the best set (highest e1RM set)
  final int reps;        // reps of that best set
  final double e1rm;     // Epley: weight * (1 + reps / 30)
  final bool isPR;       // true if ANY completed set that day had isPR == true

  const StrengthDataPoint({
    required this.date,
    required this.weight,
    required this.reps,
    required this.e1rm,
    required this.isPR,
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
