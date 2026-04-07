import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../shared/models/exercise.dart';

class ExerciseLocalDataSource {
  List<Exercise>? _cache;

  Future<List<Exercise>> getExercises({
    MuscleGroup? filterByMuscle,
    String? searchQuery,
  }) async {
    if (_cache == null) {
      final raw = await rootBundle.loadString('assets/exercises_data.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _cache = (json['exercises'] as List<dynamic>)
          .map((e) => _parseEntry(e as Map<String, dynamic>))
          .toList();
    }

    var results = _cache!;

    if (filterByMuscle != null) {
      results = results.where((e) => e.primaryMuscle == filterByMuscle).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    return results;
  }

  Exercise _parseEntry(Map<String, dynamic> json) {
    final bodyParts = (json['bodyParts'] as List<dynamic>?)?.cast<String>() ?? [];
    final targetMuscles = (json['targetMuscles'] as List<dynamic>?)?.cast<String>() ?? [];
    final secondaryMuscles = (json['secondaryMuscles'] as List<dynamic>?)?.cast<String>() ?? [];
    final instructions = (json['instructions'] as List<dynamic>?)?.cast<String>() ?? [];
    final rawType = json['type'] as String? ?? '';
    final (exerciseType, trackingUnit) = _mapType(rawType);

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscle: bodyParts.isNotEmpty ? _mapBodyPart(bodyParts[0]) : MuscleGroup.fullBody,
      bodyParts: bodyParts,
      targetMuscles: targetMuscles,
      secondaryMuscles: secondaryMuscles,
      equipmentName: json['equipment'] as String?,
      type: exerciseType,
      trackingUnit: trackingUnit,
      mechanic: json['mechanic'] as String?,
      level: json['level'] as String?,
      force: json['force'] as String?,
      instructions: instructions,
      gifUrl: json['gifUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      category: json['category'] as String?,
      isCustom: false,
    );
  }

  MuscleGroup _mapBodyPart(String bodyPart) => switch (bodyPart.toLowerCase()) {
        'core' => MuscleGroup.core,
        'upper legs' || 'lower legs' => MuscleGroup.legs,
        'chest' => MuscleGroup.chest,
        'back' => MuscleGroup.back,
        'shoulders' => MuscleGroup.shoulders,
        'upper arms' || 'lower arms' || 'waist' => MuscleGroup.arms,
        _ => MuscleGroup.fullBody,
      };

  (ExerciseType, TrackingUnit) _mapType(String type) => switch (type.toLowerCase()) {
        'weightlifting' ||
        'powerlifting' ||
        'olympic weightlifting' ||
        'strongman' =>
          (ExerciseType.compound, TrackingUnit.weightReps),
        'cardio' => (ExerciseType.cardio, TrackingUnit.distanceTime),
        'stretching' ||
        'plyometrics' ||
        'gymnastics' =>
          (ExerciseType.isolation, TrackingUnit.bodyweightReps),
        _ => (ExerciseType.isolation, TrackingUnit.weightReps),
      };
}
