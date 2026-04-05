import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/models/exercise.dart';
import '../../../../shared/models/workout_template.dart';
import '../../../../shared/widgets/exercise_picker.dart';
import '../providers/workout_providers.dart';

const _uuid = Uuid();

/// Screen for creating or editing a workout template.
///
/// Pass an existing [WorkoutTemplate] via `extra` on the route to edit it,
/// otherwise a new template is created.
class CreateTemplateScreen extends ConsumerStatefulWidget {
  final WorkoutTemplate? template;

  const CreateTemplateScreen({super.key, this.template});

  @override
  ConsumerState<CreateTemplateScreen> createState() =>
      _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends ConsumerState<CreateTemplateScreen> {
  late final TextEditingController _nameController;
  late List<TemplateExercise> _exercises;
  bool _isSaving = false;

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _exercises = List.from(widget.template?.exercises ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _estimatedMinutes {
    // Each exercise roughly 2.5 minutes
    return (_exercises.length * 2.5).ceil();
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      builder:
          (_) => ExercisePicker(
            onExerciseSelected: (exercise) {
              Navigator.pop(context);
              _addExercise(exercise);
            },
          ),
    );
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _exercises.add(
        TemplateExercise(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          defaultSets: 3,
          defaultReps: 10,
          defaultWeight: null,
          trackingUnit: exercise.trackingUnit,
        ),
      );
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _updateExerciseSets(int index, int sets) {
    setState(() {
      _exercises[index] = _exercises[index].copyWith(defaultSets: sets);
    });
  }

  void _updateExerciseReps(int index, int? reps) {
    setState(() {
      _exercises[index] = _exercises[index].copyWith(defaultReps: reps);
    });
  }

  void _updateExerciseWeight(int index, double? weight) {
    setState(() {
      _exercises[index] = _exercises[index].copyWith(defaultWeight: weight);
    });
  }

  Future<void> _saveTemplate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter a template name');
      return;
    }
    if (_exercises.isEmpty) {
      _showError('Add at least one exercise');
      return;
    }

    setState(() => _isSaving = true);

    final template = WorkoutTemplate(
      id: widget.template?.id ?? _uuid.v4(),
      name: name,
      exercises: _exercises,
      estimatedMinutes: _estimatedMinutes,
      lastUsed: widget.template?.lastUsed,
    );

    final repo = ref.read(workoutRepositoryProvider);
    final userId =
        ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001';
    final failure = await repo.saveTemplate(userId, template);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (failure != null) {
      _showError(failure.message);
      return;
    }

    // Refresh the templates cache
    ref.invalidate(workoutTemplatesProvider);

    context.pop();
  }

  void _showError(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'EDIT TEMPLATE' : 'NEW TEMPLATE',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTemplate,
            child:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                    : Text(
                      'SAVE',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.primary,
                      ),
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Template name field
                _SectionLabel(label: 'TEMPLATE NAME'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'E.g. PUSH A, LEGS B, FULL BODY...',
                    hintStyle: GoogleFonts.lexend(
                      fontSize: 14,
                      color: AppColors.surfaceContainerHighest,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Estimated duration
                _SectionLabel(label: 'ESTIMATED DURATION'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surfaceContainerLow,
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$_estimatedMinutes MIN',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_exercises.length} exercises)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Exercises section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionLabel(label: 'EXERCISES'),
                    TextButton.icon(
                      onPressed: _showExercisePicker,
                      icon: Icon(Icons.add, color: AppColors.primary, size: 18),
                      label: Text(
                        'ADD',
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_exercises.isEmpty)
                  _EmptyExercisesPlaceholder(onAddPressed: _showExercisePicker)
                else
                  ...List.generate(_exercises.length, (index) {
                    return _ExerciseTemplateCard(
                      key: ValueKey(
                        _exercises[index].exerciseId + index.toString(),
                      ),
                      exercise: _exercises[index],
                      onRemove: () => _removeExercise(index),
                      onSetsChanged: (v) => _updateExerciseSets(index, v),
                      onRepsChanged: (v) => _updateExerciseReps(index, v),
                      onWeightChanged: (v) => _updateExerciseWeight(index, v),
                      onMoveUp:
                          index > 0 ? () => _moveExercise(index, -1) : null,
                      onMoveDown:
                          index < _exercises.length - 1
                              ? () => _moveExercise(index, 1)
                              : null,
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _moveExercise(int index, int direction) {
    setState(() {
      final item = _exercises.removeAt(index);
      _exercises.insert(index + direction, item);
    });
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _EmptyExercisesPlaceholder extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyExercisesPlaceholder({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAddPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              color: AppColors.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'NO EXERCISES YET',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to add exercises from the library',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTemplateCard extends StatelessWidget {
  final TemplateExercise exercise;
  final VoidCallback onRemove;
  final void Function(int) onSetsChanged;
  final void Function(int?) onRepsChanged;
  final void Function(double?) onWeightChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _ExerciseTemplateCard({
    super.key,
    required this.exercise,
    required this.onRemove,
    required this.onSetsChanged,
    required this.onRepsChanged,
    required this.onWeightChanged,
    this.onMoveUp,
    this.onMoveDown,
  });

  bool get _hasWeight =>
      exercise.trackingUnit == TrackingUnit.weightReps ||
      exercise.trackingUnit == TrackingUnit.distanceTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.exerciseName.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Reorder buttons
                if (onMoveUp != null)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                    onPressed: onMoveUp,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                if (onMoveDown != null)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_downward,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                    onPressed: onMoveDown,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.error,
                    size: 18,
                  ),
                  onPressed: onRemove,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.outlineVariant, height: 1),

          // Defaults row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Sets
                Expanded(
                  child: _NumberField(
                    label: 'SETS',
                    value: exercise.defaultSets,
                    min: 1,
                    max: 20,
                    onChanged: (v) => onSetsChanged(v!),
                  ),
                ),
                const SizedBox(width: 12),
                // Reps
                Expanded(
                  child: _NumberField(
                    label: 'REPS',
                    value: exercise.defaultReps,
                    min: 1,
                    max: 100,
                    allowNull: true,
                    onChanged: onRepsChanged,
                  ),
                ),
                if (_hasWeight) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WeightField(
                      label: 'WEIGHT (KG)',
                      value: exercise.defaultWeight,
                      onChanged: onWeightChanged,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final int? value;
  final int min;
  final int max;
  final bool allowNull;
  final void Function(int?) onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.allowNull = false,
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parse() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (widget.allowNull) {
        widget.onChanged(null);
      }
      return;
    }
    final parsed = int.tryParse(text);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      widget.onChanged(clamped);
      if (parsed != clamped) {
        _controller.text = clamped.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (_) => _parse(),
            onEditingComplete: _parse,
          ),
        ),
      ],
    );
  }
}

class _WeightField extends StatefulWidget {
  final String label;
  final double? value;
  final void Function(double?) onChanged;

  const _WeightField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_WeightField> createState() => _WeightFieldState();
}

class _WeightFieldState extends State<_WeightField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parse() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final parsed = double.tryParse(text);
    widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (_) => _parse(),
            onEditingComplete: _parse,
          ),
        ),
      ],
    );
  }
}
