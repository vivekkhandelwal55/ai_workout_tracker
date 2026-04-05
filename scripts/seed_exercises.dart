#!/usr/bin/env dart
// Script to seed the built-in exercise library into Firestore.
//
// Usage:
//   1. Set up a Firebase service account for local development:
//      - Go to Firebase Console → Project Settings → Service Accounts
//      - Generate and download a new private key (JSON)
//      - Set environment variable:
//        export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
//
//   2. Set your Firebase project ID:
//      export FIREBASE_PROJECT_ID="your-project-id"
//
//   3. Run the script:
//      dart run scripts/seed_exercises.dart
//
// This script is idempotent — running it multiple times is safe (it uses set with merge).

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ai_workout_tracker_app/shared/models/exercise.dart';

const _exercises = [
  // CHEST
  Exercise(
    id: 'ex-001',
    name: 'Flat Bench Press',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscleDescription: 'PECTORALIS MAJOR',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'BARBELL',
    tips: [
      'Keep shoulder blades retracted',
      'Bar touches lower chest',
      'Full ROM for chest activation',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-002',
    name: 'Incline Chest Fly',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscleDescription: 'UPPER CHEST',
    type: ExerciseType.isolation,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'DUMBBELL',
    tips: [
      'Slight bend in elbows throughout',
      'Feel stretch at bottom',
      'Squeeze at top',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-003',
    name: 'Chest Dips',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscleDescription: 'UPPER CHEST',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.bodyweightReps,
    equipmentName: 'BODYWEIGHT',
    tips: [
      'Lean forward for chest emphasis',
      'Lower until shoulders are at elbow level',
      'Control descent',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-004',
    name: 'Cable Crossover',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscleDescription: 'INNER CHEST',
    type: ExerciseType.isolation,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'CABLE',
    tips: [
      'Cross hands at bottom for peak contraction',
      'Control the eccentric',
      'Keep chest up',
    ],
    isCustom: false,
  ),
  // BACK
  Exercise(
    id: 'ex-005',
    name: 'Lat Pulldown',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscleDescription: 'LATISSIMUS DORSI',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'CABLE',
    tips: [
      'Lean back slightly',
      'Pull to upper chest not neck',
      'Full stretch at top',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-006',
    name: 'Bent Over Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscleDescription: 'RHOMBOIDS',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'BARBELL',
    tips: [
      'Hinge at hips 45°',
      'Row to lower chest',
      'Keep back flat throughout',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-007',
    name: 'Pull-Ups',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscleDescription: 'LATS & BICEPS',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.bodyweightReps,
    equipmentName: 'BODYWEIGHT',
    tips: [
      'Full dead hang at bottom',
      'Pull elbows to hips',
      'Squeeze lats at top',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-008',
    name: 'Seated Cable Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscleDescription: 'MID BACK',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'CABLE',
    tips: [
      'Sit upright, no swinging',
      'Pull handle to navel',
      'Full stretch between reps',
    ],
    isCustom: false,
  ),
  // LEGS
  Exercise(
    id: 'ex-009',
    name: 'Barbell Back Squat',
    primaryMuscle: MuscleGroup.legs,
    secondaryMuscleDescription: 'QUADRICEPS • GLUTES',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'BARBELL',
    tips: [
      'Break parallel for full glute activation',
      'Keep chest up',
      'Drive knees out over toes',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-010',
    name: 'Romanian Deadlift',
    primaryMuscle: MuscleGroup.legs,
    secondaryMuscleDescription: 'HAMSTRINGS',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'BARBELL',
    tips: [
      'Hinge at hips, bar close to shins',
      'Feel hamstring stretch',
      'Soft bend in knees',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-011',
    name: 'Bulgarian Split Squat',
    primaryMuscle: MuscleGroup.legs,
    secondaryMuscleDescription: 'QUADS • GLUTES',
    type: ExerciseType.isolation,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'DUMBBELL',
    tips: [
      'Rear foot elevated on bench',
      'Front knee tracks over toes',
      'Deep ROM for glute stretch',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-012',
    name: 'Leg Press',
    primaryMuscle: MuscleGroup.legs,
    secondaryMuscleDescription: 'QUADRICEPS',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'MACHINE',
    tips: [
      'Feet shoulder width apart',
      'Lower until 90° knee angle',
      "Don't lock out fully",
    ],
    isCustom: false,
  ),
  // SHOULDERS
  Exercise(
    id: 'ex-013',
    name: 'Overhead Press',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscleDescription: 'ANTERIOR DELTOID',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'BARBELL',
    tips: [
      'Press over crown of head',
      'Keep core tight',
      'Full lockout at top',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-014',
    name: 'Lateral Raises',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscleDescription: 'MEDIAL DELTOID',
    type: ExerciseType.isolation,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'DUMBBELL',
    tips: [
      'Lead with elbows not hands',
      'Slight forward lean',
      'Control descent',
    ],
    isCustom: false,
  ),
  // ARMS
  Exercise(
    id: 'ex-015',
    name: 'Barbell Curl',
    primaryMuscle: MuscleGroup.arms,
    secondaryMuscleDescription: 'BICEPS BRACHII',
    type: ExerciseType.isolation,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'BARBELL',
    tips: [
      'Elbows pinned to sides',
      'Full stretch at bottom',
      'Squeeze at peak',
    ],
    isCustom: false,
  ),
  Exercise(
    id: 'ex-016',
    name: 'Tricep Pushdown',
    primaryMuscle: MuscleGroup.arms,
    secondaryMuscleDescription: 'TRICEPS',
    type: ExerciseType.isolation,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'CABLE',
    tips: [
      'Keep elbows at sides',
      'Full lockout at bottom',
      'Control the negative',
    ],
    isCustom: false,
  ),
  // DEADLIFT
  Exercise(
    id: 'ex-017',
    name: 'Conventional Deadlift',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscleDescription: 'FULL POSTERIOR CHAIN',
    type: ExerciseType.compound,
    trackingUnit: TrackingUnit.weightReps,
    equipmentName: 'BARBELL',
    tips: [
      'Bar over mid-foot',
      'Hips and shoulders rise together',
      'Lock hips and knees simultaneously',
    ],
    isCustom: false,
  ),
  // CORE
  Exercise(
    id: 'ex-018',
    name: 'Weighted Plank',
    primaryMuscle: MuscleGroup.core,
    secondaryMuscleDescription: 'TRANSVERSE ABDOMINIS',
    type: ExerciseType.isolation,
    trackingUnit: TrackingUnit.timeOnly,
    equipmentName: 'BODYWEIGHT',
    tips: [
      'Neutral spine throughout',
      'Squeeze glutes and abs',
      'Breathe steadily',
    ],
    isCustom: false,
  ),
];

Future<void> main() async {
  // Check for service account (recommended for scripts)
  // Or use Application Default Credentials
  print('🚀 Seeding built-in exercises to Firestore...\n');

  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final batch = FirebaseFirestore.instance.batch();
  final exercisesRef = firestore.collection('exercises');

  int count = 0;
  for (final exercise in _exercises) {
    final data = _exerciseToMap(exercise);
    final docRef = exercisesRef.doc(exercise.id);
    batch.set(docRef, data, SetOptions(merge: true));
    count++;
  }

  await batch.commit();
  print('✅ Successfully seeded $count exercises to Firestore.\n');

  // Verify
  final snapshot = await exercisesRef.get();
  print('📊 Verification: exercises collection now has ${snapshot.size} documents.\n');

  if (snapshot.size != _exercises.length) {
    print('⚠️  Warning: Expected ${_exercises.length} exercises but found ${snapshot.size}.');
  } else {
    print('✅ Exercise seeding verified successfully.');
  }

  print('\nDone! ✅');
}

Map<String, dynamic> _exerciseToMap(Exercise exercise) {
  return {
    'id': exercise.id,
    'name': exercise.name,
    'primaryMuscle': exercise.primaryMuscle.name,
    'secondaryMuscleDescription': exercise.secondaryMuscleDescription,
    'type': exercise.type.name,
    'trackingUnit': exercise.trackingUnit.name,
    'equipmentName': exercise.equipmentName,
    'gifUrl': exercise.gifUrl,
    'tips': exercise.tips,
    'isCustom': exercise.isCustom,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
