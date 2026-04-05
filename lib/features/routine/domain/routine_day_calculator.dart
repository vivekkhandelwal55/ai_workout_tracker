import '../../../shared/models/workout_routine.dart';

class TodayRoutineDay {
  const TodayRoutineDay({
    required this.dayIndex,
    required this.dayNumber,
    required this.routineDay,
  });

  /// 0-based index into the routine's days list.
  final int dayIndex;

  /// 1-based display number (dayIndex + 1).
  final int dayNumber;

  /// The RoutineDay that falls on today.
  final RoutineDay routineDay;
}

/// Pure function — no side effects.
///
/// Computes which [RoutineDay] is scheduled for [today] based on cycling
/// through the routine starting at [routine.startDate].
///
/// Returns `null` when [routine.days] is empty.
TodayRoutineDay? computeTodayRoutineDay(
  WorkoutRoutine routine,
  DateTime today,
) {
  final days = routine.days;
  if (days.isEmpty) return null;

  final cycleLength = days.length;

  // Normalise both dates to midnight so time-of-day doesn't affect the diff.
  final startMidnight = DateTime(
    routine.startDate.year,
    routine.startDate.month,
    routine.startDate.day,
  );
  final todayMidnight = DateTime(today.year, today.month, today.day);

  final rawDiff = todayMidnight.difference(startMidnight).inDays;

  // Positive modulo — handles negative rawDiff (today before startDate) safely.
  final dayIndex = ((rawDiff % cycleLength) + cycleLength) % cycleLength;

  return TodayRoutineDay(
    dayIndex: dayIndex,
    dayNumber: dayIndex + 1,
    routineDay: days[dayIndex],
  );
}
