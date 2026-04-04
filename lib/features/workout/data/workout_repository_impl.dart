import '../domain/workout_repository.dart';
import '../../../shared/models/workout_template.dart';
import '../../../shared/models/workout_session.dart';
import '../../../shared/models/exercise.dart';
import '../../../core/errors/failures.dart';

class StubWorkoutRepository implements WorkoutRepository {
  final List<WorkoutTemplate> _templates = [
    WorkoutTemplate(
      id: 'tmpl-001',
      name: 'PUSH A',
      description: 'Chest, shoulders, triceps',
      estimatedMinutes: 65,
      lastUsed: DateTime.now().subtract(const Duration(days: 2)),
      exercises: const [
        TemplateExercise(
          exerciseId: 'ex-001',
          exerciseName: 'Flat Bench Press',
          defaultSets: 4,
          defaultReps: 8,
          defaultWeight: 80,
          trackingUnit: TrackingUnit.weightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-013',
          exerciseName: 'Overhead Press',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeight: 50,
          trackingUnit: TrackingUnit.weightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-016',
          exerciseName: 'Tricep Pushdown',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeight: 30,
          trackingUnit: TrackingUnit.weightReps,
        ),
      ],
    ),
    WorkoutTemplate(
      id: 'tmpl-002',
      name: 'PULL A',
      description: 'Back, biceps, rear delts',
      estimatedMinutes: 60,
      lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      exercises: const [
        TemplateExercise(
          exerciseId: 'ex-007',
          exerciseName: 'Pull-Ups',
          defaultSets: 4,
          defaultReps: 8,
          trackingUnit: TrackingUnit.bodyweightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-006',
          exerciseName: 'Bent Over Row',
          defaultSets: 4,
          defaultReps: 8,
          defaultWeight: 70,
          trackingUnit: TrackingUnit.weightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-015',
          exerciseName: 'Barbell Curl',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeight: 35,
          trackingUnit: TrackingUnit.weightReps,
        ),
      ],
    ),
    WorkoutTemplate(
      id: 'tmpl-003',
      name: 'LEGS B',
      description: 'Quad-focused leg day',
      estimatedMinutes: 70,
      lastUsed: DateTime.now().subtract(const Duration(days: 3)),
      exercises: const [
        TemplateExercise(
          exerciseId: 'ex-009',
          exerciseName: 'Barbell Back Squat',
          defaultSets: 5,
          defaultReps: 5,
          defaultWeight: 100,
          trackingUnit: TrackingUnit.weightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-011',
          exerciseName: 'Bulgarian Split Squat',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeight: 20,
          trackingUnit: TrackingUnit.weightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-012',
          exerciseName: 'Leg Press',
          defaultSets: 4,
          defaultReps: 10,
          defaultWeight: 120,
          trackingUnit: TrackingUnit.weightReps,
        ),
      ],
    ),
    WorkoutTemplate(
      id: 'tmpl-004',
      name: 'FULL BODY',
      description: 'Full body strength',
      estimatedMinutes: 75,
      exercises: const [
        TemplateExercise(
          exerciseId: 'ex-017',
          exerciseName: 'Conventional Deadlift',
          defaultSets: 3,
          defaultReps: 5,
          defaultWeight: 120,
          trackingUnit: TrackingUnit.weightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-009',
          exerciseName: 'Barbell Back Squat',
          defaultSets: 3,
          defaultReps: 8,
          defaultWeight: 90,
          trackingUnit: TrackingUnit.weightReps,
        ),
        TemplateExercise(
          exerciseId: 'ex-001',
          exerciseName: 'Flat Bench Press',
          defaultSets: 3,
          defaultReps: 8,
          defaultWeight: 75,
          trackingUnit: TrackingUnit.weightReps,
        ),
      ],
    ),
  ];

  final List<WorkoutSession> _history = [];

  @override
  Future<(List<WorkoutTemplate>, Failure?)> getTemplates(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return (_templates, null);
  }

  @override
  Future<Failure?> saveTemplate(WorkoutTemplate template) async {
    final idx = _templates.indexWhere((t) => t.id == template.id);
    if (idx >= 0) {
      _templates[idx] = template;
    } else {
      _templates.add(template);
    }
    return null;
  }

  @override
  Future<Failure?> deleteTemplate(String templateId) async {
    _templates.removeWhere((t) => t.id == templateId);
    return null;
  }

  @override
  Future<Failure?> saveWorkoutSession(WorkoutSession session) async {
    final idx = _history.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      _history[idx] = session;
    } else {
      _history.add(session);
    }
    return null;
  }

  @override
  Future<(List<WorkoutSession>, Failure?)> getWorkoutHistory(
    String userId, {
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return (_history.take(limit).toList(), null);
  }

  @override
  Future<(WorkoutSession?, Failure?)> getSession(String sessionId) async {
    try {
      final session = _history.firstWhere((s) => s.id == sessionId);
      return (session, null);
    } catch (_) {
      return (null, const NotFoundFailure('Session not found'));
    }
  }
}
