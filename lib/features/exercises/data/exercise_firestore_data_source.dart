import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/exercise.dart';

class ExerciseFirestoreDataSource {
  ExerciseFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _exercisesCollection =>
      _firestore.collection(FirestoreCollections.exercises);

  CollectionReference<Map<String, dynamic>> _userExercisesCollection(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.customExercises);

  Future<List<Exercise>> getExercises({
    MuscleGroup? filterByMuscle,
    String? searchQuery,
    String? userId,
  }) async {
    Query<Map<String, dynamic>> query = _exercisesCollection;

    if (filterByMuscle != null) {
      query = query.where('primaryMuscle', isEqualTo: filterByMuscle.name);
    }

    final snapshot = await query.get();

    var exercises = snapshot.docs.map((doc) {
      return Exercise(
        id: doc.id,
        name: doc.data()['name'] as String? ?? '',
        primaryMuscle: _parseMuscleGroup(doc.data()['primaryMuscle']),
        secondaryMuscleDescription: doc.data()['secondaryMuscleDescription'] as String?,
        type: _parseExerciseType(doc.data()['type']),
        trackingUnit: _parseTrackingUnit(doc.data()['trackingUnit']),
        equipmentName: doc.data()['equipmentName'] as String?,
        gifUrl: doc.data()['gifUrl'] as String?,
        tips: (doc.data()['tips'] as List<dynamic>?)?.cast<String>() ?? [],
        isCustom: doc.data()['isCustom'] as bool? ?? false,
      );
    }).toList();

    // Fetch user's custom exercises if userId is provided
    if (userId != null) {
      final customSnapshot = await _userExercisesCollection(userId).get();
      final customExercises = customSnapshot.docs.map((doc) {
        return Exercise(
          id: doc.id,
          name: doc.data()['name'] as String? ?? '',
          primaryMuscle: _parseMuscleGroup(doc.data()['primaryMuscle']),
          secondaryMuscleDescription: doc.data()['secondaryMuscleDescription'] as String?,
          type: _parseExerciseType(doc.data()['type']),
          trackingUnit: _parseTrackingUnit(doc.data()['trackingUnit']),
          equipmentName: doc.data()['equipmentName'] as String?,
          gifUrl: doc.data()['gifUrl'] as String?,
          tips: (doc.data()['tips'] as List<dynamic>?)?.cast<String>() ?? [],
          isCustom: doc.data()['isCustom'] as bool? ?? true,
        );
      }).toList();
      exercises.addAll(customExercises);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      exercises = exercises.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    return exercises;
  }

  Future<void> createCustomExercise(String userId, Exercise exercise) async {
    await _userExercisesCollection(userId)
        .doc(exercise.id)
        .set(Map<String, dynamic>.from(exercise.toJson()));
  }

  MuscleGroup _parseMuscleGroup(dynamic value) {
    if (value is String) {
      return MuscleGroup.values.byName(value);
    }
    return MuscleGroup.fullBody;
  }

  ExerciseType _parseExerciseType(dynamic value) {
    if (value is String) {
      return ExerciseType.values.byName(value);
    }
    return ExerciseType.compound;
  }

  TrackingUnit _parseTrackingUnit(dynamic value) {
    if (value is String) {
      return TrackingUnit.values.byName(value);
    }
    return TrackingUnit.weightReps;
  }
}
