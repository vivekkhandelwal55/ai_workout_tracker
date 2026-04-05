import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/workout_template.dart';
import '../../../../shared/models/exercise.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'workout_providers.dart';

const _uuid = Uuid();

/// State for the template editor (create / edit).
class CreateTemplateState {
  final WorkoutTemplate? originalTemplate; // null = new template
  final String name;
  final String description;
  final List<TemplateExercise> exercises;
  final bool isSaving;
  final String? error;

  const CreateTemplateState({
    this.originalTemplate,
    this.name = '',
    this.description = '',
    this.exercises = const [],
    this.isSaving = false,
    this.error,
  });

  bool get isEditing => originalTemplate != null;

  CreateTemplateState copyWith({
    WorkoutTemplate? originalTemplate,
    String? name,
    String? description,
    List<TemplateExercise>? exercises,
    bool? isSaving,
    String? error,
  }) {
    return CreateTemplateState(
      originalTemplate: originalTemplate ?? this.originalTemplate,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class CreateTemplateNotifier extends StateNotifier<CreateTemplateState> {
  final Ref _ref;

  CreateTemplateNotifier(this._ref) : super(const CreateTemplateState());

  // -------------------------------------------------------------------------
  // Template metadata
  // -------------------------------------------------------------------------

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  // -------------------------------------------------------------------------
  // Exercise management
  // -------------------------------------------------------------------------

  /// Adds an exercise derived from an [Exercise] model with default values.
  void addExercise(Exercise exercise, {
    int sets = 3,
    int? reps,
    double? weight,
  }) {
    final templateExercise = TemplateExercise(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      defaultSets: sets,
      defaultReps: reps,
      defaultWeight: weight,
      trackingUnit: exercise.trackingUnit,
    );
    state = state.copyWith(
      exercises: [...state.exercises, templateExercise],
    );
  }

  /// Adds a [TemplateExercise] directly (e.g. after editing an existing one).
  void addTemplateExercise(TemplateExercise exercise) {
    state = state.copyWith(
      exercises: [...state.exercises, exercise],
    );
  }

  void removeExercise(int index) {
    if (index < 0 || index >= state.exercises.length) return;
    final updated = List<TemplateExercise>.from(state.exercises)..removeAt(index);
    state = state.copyWith(exercises: updated);
  }

  void updateExercise(int index, TemplateExercise updated) {
    if (index < 0 || index >= state.exercises.length) return;
    final updatedList = List<TemplateExercise>.from(state.exercises);
    updatedList[index] = updated;
    state = state.copyWith(exercises: updatedList);
  }

  // -------------------------------------------------------------------------
  // Load / clear
  // -------------------------------------------------------------------------

  void loadTemplate(WorkoutTemplate template) {
    state = CreateTemplateState(
      originalTemplate: template,
      name: template.name,
      description: template.description ?? '',
      exercises: List<TemplateExercise>.from(template.exercises),
    );
  }

  void clear() {
    state = const CreateTemplateState();
  }

  // -------------------------------------------------------------------------
  // Save
  // -------------------------------------------------------------------------

  Future<Failure?> save() async {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(error: 'Template name is required');
      return const ValidationFailure('Template name is required');
    }
    if (state.exercises.isEmpty) {
      state = state.copyWith(error: 'Add at least one exercise');
      return const ValidationFailure('Add at least one exercise');
    }

    state = state.copyWith(isSaving: true, error: null);

    final template = WorkoutTemplate(
      id: state.originalTemplate?.id ?? 'tmpl-${_uuid.v4()}',
      name: state.name.trim(),
      description: state.description.trim().isEmpty ? null : state.description.trim(),
      exercises: state.exercises,
      estimatedMinutes: _estimateMinutes(state.exercises),
      lastUsed: state.originalTemplate?.lastUsed,
    );

    final userId = _ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001';

    final failure = await _ref.read(workoutRepositoryProvider).saveTemplate(
      userId,
      template,
    );

    if (failure != null) {
      state = state.copyWith(isSaving: false, error: failure.message);
      return failure;
    }

    state = state.copyWith(isSaving: false);
    return null;
  }

  int _estimateMinutes(List<TemplateExercise> exercises) {
    // Rough estimate: 2 min per set + 30 sec transition between exercises
    final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.defaultSets);
    return (totalSets * 2) + (exercises.length * 1);
  }
}

final createTemplateProvider =
    StateNotifierProvider<CreateTemplateNotifier, CreateTemplateState>((ref) {
  return CreateTemplateNotifier(ref);
});

/// Tracks which template is currently selected for viewing / editing.
final selectedTemplateProvider = StateProvider<WorkoutTemplate?>((ref) => null);

/// Family provider to fetch a single template by ID from the cached list.
final templateByIdProvider =
    FutureProvider.family<WorkoutTemplate?, String>((ref, templateId) async {
  final templatesAsync = await ref.watch(workoutTemplatesProvider('local').future);
  try {
    return templatesAsync.firstWhere((t) => t.id == templateId);
  } catch (_) {
    return null;
  }
});
