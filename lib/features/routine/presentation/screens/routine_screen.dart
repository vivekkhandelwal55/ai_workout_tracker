import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/features/routine/presentation/providers/routine_providers.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/providers/workout_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_routine.dart';

const _uuid = Uuid();

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  bool _isEditMode = false;
  List<RoutineDay> _editDays = [];
  DateTime _startDate = DateTime.now();

  // Track text controllers for day name fields
  final List<TextEditingController> _nameControllers = [];

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _enterEditMode(WorkoutRoutine? existing) {
    // Dispose old controllers
    for (final c in _nameControllers) {
      c.dispose();
    }
    _nameControllers.clear();

    if (existing != null) {
      _editDays = List<RoutineDay>.from(existing.days);
      _startDate = existing.startDate;
    } else {
      _editDays = [];
      _startDate = DateTime.now();
    }

    // Create controllers for each day
    for (final day in _editDays) {
      _nameControllers.add(TextEditingController(text: day.name));
    }

    setState(() {
      _isEditMode = true;
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
    });
  }

  void _addDay() {
    final newDay = RoutineDay(id: _uuid.v4(), name: '');
    setState(() {
      _editDays.add(newDay);
      _nameControllers.add(TextEditingController());
    });
  }

  void _removeDay(int index) {
    setState(() {
      _editDays.removeAt(index);
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
    });
  }

  void _reorderDays(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final day = _editDays.removeAt(oldIndex);
      _editDays.insert(newIndex, day);
      final ctrl = _nameControllers.removeAt(oldIndex);
      _nameControllers.insert(newIndex, ctrl);
    });
  }

  void _updateDayTemplate(int index, String? templateId, String? templateName) {
    setState(() {
      _editDays[index] = RoutineDay(
        id: _editDays[index].id,
        name: _editDays[index].name,
        templateId: templateId,
        templateName: templateName,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(
                ctx,
              ).colorScheme.copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveRoutine(WorkoutRoutine? existing) async {
    // Sync names from controllers back to _editDays
    for (int i = 0; i < _editDays.length; i++) {
      _editDays[i] = RoutineDay(
        id: _editDays[i].id,
        name: _nameControllers[i].text.trim().toUpperCase(),
        templateId: _editDays[i].templateId,
        templateName: _editDays[i].templateName,
      );
    }

    // Validate
    if (_editDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ADD AT LEAST ONE DAY TO YOUR ROUTINE')),
      );
      return;
    }
    final hasEmptyName = _editDays.any((d) => d.name.isEmpty);
    if (hasEmptyName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ALL DAYS MUST HAVE A NAME')),
      );
      return;
    }

    final userId = ref.read(authNotifierProvider).valueOrNull?.id ?? '';

    final routine = WorkoutRoutine(
      id: 'active',
      userId: userId,
      days: _editDays,
      startDate: _startDate,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(routineNotifierProvider.notifier).saveRoutine(routine);

    if (!mounted) return;
    _exitEditMode();
  }

  Future<void> _deleteRoutine() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            title: Text(
              'DELETE ROUTINE',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: AppColors.onSurface,
              ),
            ),
            content: Text(
              'This will permanently delete your training schedule.',
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'DELETE',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    await ref.read(routineNotifierProvider.notifier).deleteRoutine();

    if (!mounted) return;
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors from the notifier
    ref.listen(routineNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, st) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        },
      );
    });

    final routineAsync = ref.watch(currentRoutineProvider);

    return routineAsync.when(
      loading:
          () => Scaffold(
            backgroundColor: AppColors.surface,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      error:
          (e, st) => Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: Text(
                'FAILED TO LOAD ROUTINE',
                style: GoogleFonts.lexend(color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
      data: (routine) {
        if (_isEditMode) {
          return _buildEditMode(routine);
        }
        if (routine == null) {
          return _buildEmptyState();
        }
        return _buildViewMode(routine);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state — no routine set yet
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildSimpleAppBar(title: 'MY ROUTINE'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'NO ROUTINE',
                    style: GoogleFonts.lexend(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Build a weekly training schedule to get\npersonalised daily workout suggestions.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: _PrimaryButton(
                label: 'BUILD ROUTINE',
                onPressed: () => _enterEditMode(null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // View mode — routine exists
  // ---------------------------------------------------------------------------
  Widget _buildViewMode(WorkoutRoutine routine) {
    final todayDay = ref.watch(todayRoutineDayProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildViewAppBar(routine),
            // Start date row
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text(
                    'STARTING FROM ',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.6,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatDate(routine.startDate),
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Day list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                itemCount: routine.days.length,
                separatorBuilder: (_, _i) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final day = routine.days[index];
                  final isToday = todayDay?.dayIndex == index;
                  return _DayViewTile(
                    dayNumber: index + 1,
                    day: day,
                    isToday: isToday,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _PrimaryButton(
                label: 'EDIT ROUTINE',
                onPressed: () => _enterEditMode(routine),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAppBar(WorkoutRoutine routine) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
      child: Row(
        children: [
          BackButton(),
          Expanded(
            child: Text(
              'MY ROUTINE',
              style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppColors.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _enterEditMode(routine),
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Edit routine',
          ),
          IconButton(
            onPressed: _deleteRoutine,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Delete routine',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Edit mode
  // ---------------------------------------------------------------------------
  Widget _buildEditMode(WorkoutRoutine? existing) {
    final isSaving = ref.watch(routineNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildEditAppBar(existing, isSaving),
            // Date picker row
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                color: AppColors.surfaceContainerLow,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'STARTING FROM',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.6,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(_startDate),
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Reorderable day list
            Expanded(
              child:
                  _editDays.isEmpty
                      ? Center(
                        child: Text(
                          'NO DAYS YET\nTAP ADD DAY BELOW',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            letterSpacing: 1.4,
                            color: AppColors.onSurfaceVariant,
                            height: 1.8,
                          ),
                        ),
                      )
                      : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        onReorder: _reorderDays,
                        proxyDecorator:
                            (child, index, animation) =>
                                _ProxyDecorator(child: child),
                        itemCount: _editDays.length,
                        itemBuilder: (context, index) {
                          final day = _editDays[index];
                          final userId =
                              ref.read(authNotifierProvider).valueOrNull?.id ??
                              '';
                          return _DayEditTile(
                            key: ValueKey(day.id),
                            index: index,
                            day: day,
                            controller: _nameControllers[index],
                            userId: userId,
                            onDelete: () => _removeDay(index),
                            onTemplateSelected: (templateId, templateName) {
                              _updateDayTemplate(
                                index,
                                templateId,
                                templateName,
                              );
                            },
                          );
                        },
                      ),
            ),
            // ADD DAY button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: GestureDetector(
                onTap: _addDay,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Center(
                    child: Text(
                      'ADD DAY +',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEditAppBar(WorkoutRoutine? existing, bool isSaving) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: isSaving ? null : _exitEditMode,
            icon: const Icon(Icons.arrow_back),
            color: AppColors.onSurface,
          ),
          Expanded(
            child: Text(
              'BUILD ROUTINE',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppColors.onSurface,
              ),
            ),
          ),
          if (isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            GestureDetector(
              onTap: () => _saveRoutine(existing),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'SAVE',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleAppBar({required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.onSurface,
          ),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day tile — view mode
// ---------------------------------------------------------------------------
class _DayViewTile extends StatelessWidget {
  final int dayNumber;
  final RoutineDay day;
  final bool isToday;

  const _DayViewTile({
    required this.dayNumber,
    required this.day,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border:
            isToday
                ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                )
                : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Day number badge
          Container(
            width: 36,
            height: 36,
            color: isToday ? AppColors.primary : AppColors.surfaceContainerHigh,
            child: Center(
              child: Text(
                dayNumber.toString().padLeft(2, '0'),
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isToday ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.name.toUpperCase(),
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                _TemplateChip(templateName: day.templateName),
              ],
            ),
          ),
          if (isToday)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'TODAY',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day tile — edit mode
// ---------------------------------------------------------------------------
class _DayEditTile extends ConsumerWidget {
  final int index;
  final RoutineDay day;
  final TextEditingController controller;
  final String userId;
  final VoidCallback onDelete;
  final void Function(String? templateId, String? templateName)
  onTemplateSelected;

  const _DayEditTile({
    super.key,
    required this.index,
    required this.day,
    required this.controller,
    required this.userId,
    required this.onDelete,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surfaceContainerLow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Icon(
                Icons.drag_handle,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          // Day number
          Container(
            width: 32,
            height: 32,
            color: AppColors.surfaceContainerHigh,
            child: Center(
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name field + template chip
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'DAY NAME',
                    hintStyle: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _openTemplatePicker(context, ref),
                  child: _TemplateChip(
                    templateName: day.templateName,
                    isEditable: true,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          // Delete icon
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Remove day',
          ),
        ],
      ),
    );
  }

  void _openTemplatePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder:
          (ctx) => _TemplatePicker(
            userId: userId,
            selectedTemplateId: day.templateId,
            onSelected: onTemplateSelected,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Template chip — shared between view and edit modes
// ---------------------------------------------------------------------------
class _TemplateChip extends StatelessWidget {
  final String? templateName;
  final bool isEditable;

  const _TemplateChip({this.templateName, this.isEditable = false});

  @override
  Widget build(BuildContext context) {
    final isRest = templateName == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isRest
                ? AppColors.surfaceContainerHigh
                : AppColors.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: isRest ? AppColors.outlineVariant : AppColors.primary,
          width: 1,
        ),
      ),
      child: Text(
        isRest
            ? (isEditable ? 'LINK TEMPLATE +' : 'REST DAY')
            : templateName!.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color:
              isRest
                  ? (isEditable
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant)
                  : AppColors.primary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Template picker bottom sheet
// ---------------------------------------------------------------------------
class _TemplatePicker extends ConsumerWidget {
  final String userId;
  final String? selectedTemplateId;
  final void Function(String? templateId, String? templateName) onSelected;

  const _TemplatePicker({
    required this.userId,
    required this.selectedTemplateId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(workoutTemplatesProvider(userId));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text(
                'SELECT TEMPLATE',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            // Divider
            Container(height: 1, color: AppColors.outlineVariant),
            // REST DAY option
            _TemplatePickerRow(
              templateId: null,
              templateName: null,
              exerciseCount: 0,
              isSelected: selectedTemplateId == null,
              onTap: () {
                onSelected(null, null);
                Navigator.pop(context);
              },
            ),
            Container(height: 1, color: AppColors.outlineVariant),
            // Templates list
            Flexible(
              child: templatesAsync.when(
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                error:
                    (e, st) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'FAILED TO LOAD TEMPLATES',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                data:
                    (templates) => ListView.separated(
                      shrinkWrap: true,
                      itemCount: templates.length,
                      separatorBuilder:
                          (_, _i) => Container(
                            height: 1,
                            color: AppColors.outlineVariant,
                          ),
                      itemBuilder: (context, index) {
                        final t = templates[index];
                        return _TemplatePickerRow(
                          templateId: t.id,
                          templateName: t.name,
                          exerciseCount: t.exercises.length,
                          isSelected: selectedTemplateId == t.id,
                          onTap: () {
                            onSelected(t.id, t.name);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplatePickerRow extends StatelessWidget {
  final String? templateId;
  final String? templateName;
  final int exerciseCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplatePickerRow({
    required this.templateId,
    required this.templateName,
    required this.exerciseCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = templateName == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color:
            isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 3,
                height: 32,
                color: AppColors.primary,
                margin: const EdgeInsets.only(right: 12),
              )
            else
              const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRest
                        ? 'REST DAY (NO TEMPLATE)'
                        : templateName!.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color:
                          isRest
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                    ),
                  ),
                  if (!isRest) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$exerciseCount EXERCISE${exerciseCount == 1 ? '' : 'S'}',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared primary button
// ---------------------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proxy decorator for reorderable list drag
// ---------------------------------------------------------------------------
class _ProxyDecorator extends StatelessWidget {
  final Widget child;

  const _ProxyDecorator({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: Colors.black54,
      child: child,
    );
  }
}
