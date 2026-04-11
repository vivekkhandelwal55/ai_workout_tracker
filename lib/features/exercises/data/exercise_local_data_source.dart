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
      final raw = await rootBundle.loadString('assets/exercises.json');
      final decoded = jsonDecode(raw);
      // exercises.json has a list root; handle both array and {'exercises': [...]} for compat
      List<dynamic> exerciseList;
      if (decoded is List) {
        exerciseList = decoded;
      } else {
        exerciseList = (decoded as Map<String, dynamic>)['exercises'] as List<dynamic>;
      }
      _cache =
          exerciseList
              .map((e) => _parseEntry(e as Map<String, dynamic>))
              .toList();
    }

    var results = _cache!;

    if (filterByMuscle != null) {
      results =
          results.where((e) => e.primaryMuscle == filterByMuscle).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    return results;
  }

  Exercise _parseEntry(Map<String, dynamic> json) {
    // Handle bodyParts - JSON may have 'bodyParts' (list) or 'body_part' (string)
    List<String> bodyParts;
    final bodyPartsList = json['bodyParts'] as List<dynamic>?;
    if (bodyPartsList != null) {
      bodyParts = bodyPartsList.cast<String>();
    } else {
      final bodyPartStr = json['body_part'] as String?;
      bodyParts = bodyPartStr != null ? [bodyPartStr] : [];
    }

    // Handle targetMuscles - JSON may have 'targetMuscles' (list) or 'target' (string)
    List<String> targetMuscles;
    final targetList = json['targetMuscles'] as List<dynamic>?;
    if (targetList != null) {
      targetMuscles = targetList.cast<String>();
    } else {
      final targetStr = json['target'] as String?;
      targetMuscles = targetStr != null ? [targetStr] : [];
    }

    final secondaryMuscles =
        (json['secondaryMuscles'] as List<dynamic>?)?.cast<String>() ?? [];

    // Instructions - JSON may have:
    //   {"en": "...", "tr": "..."}  (Map - take 'en' value as single-string entry)
    //   {"en": ["step1", "step2"]}   (Map - take 'en' list as step list)
    List<String> instructions;
    final instructionsRaw = json['instructions'];
    if (instructionsRaw is List<dynamic>) {
      instructions = instructionsRaw.cast<String>();
    } else if (instructionsRaw is Map<String, dynamic>) {
      final enValue = instructionsRaw['en'];
      if (enValue is List<dynamic>) {
        instructions = enValue.cast<String>();
      } else if (enValue is String) {
        instructions = [enValue];
      } else {
        instructions = [];
      }
    } else {
      instructions = [];
    }

    final rawType = json['type'] as String? ?? '';
    final (exerciseType, trackingUnit) = _mapType(rawType);

    // Map local asset paths: JSON uses 'image' for thumbnail and 'gif_url' for GIF
    final imagePath = json['image'] as String?;
    final gifUrlPath = json['gif_url'] as String?;

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscle:
          bodyParts.isNotEmpty
              ? _mapBodyPart(bodyParts[0])
              : MuscleGroup.fullBody,
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
      gifUrl: gifUrlPath,
      thumbnailUrl: imagePath,
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

  (ExerciseType, TrackingUnit) _mapType(String type) => switch (type
      .toLowerCase()) {
    'weightlifting' ||
    'powerlifting' ||
    'olympic weightlifting' ||
    'strongman' => (ExerciseType.compound, TrackingUnit.weightReps),
    'cardio' => (ExerciseType.cardio, TrackingUnit.distanceTime),
    'stretching' ||
    'plyometrics' ||
    'gymnastics' => (ExerciseType.isolation, TrackingUnit.bodyweightReps),
    _ => (ExerciseType.isolation, TrackingUnit.weightReps),
  };
}
