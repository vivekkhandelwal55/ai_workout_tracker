import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/workout_template.dart';
import '../../../shared/models/workout_session.dart';

class WorkoutFirestoreDataSource {
  WorkoutFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _templatesCollection(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.workoutTemplates);

  CollectionReference<Map<String, dynamic>> _sessionsCollection(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.workoutSessions);

  // --- Templates ---

  Future<List<WorkoutTemplate>> getTemplates(String userId) async {
    final snapshot = await _templatesCollection(userId).get();
    return snapshot.docs
        .map((doc) => WorkoutTemplate.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveTemplate(String userId, WorkoutTemplate template) async {
    final data = Map<String, dynamic>.from(template.toJson());
    data['exercises'] = template.exercises.map((e) => e.toJson()).toList();
    await _templatesCollection(userId).doc(template.id).set(data);
  }

  Future<void> deleteTemplate(String userId, String templateId) async {
    await _templatesCollection(userId).doc(templateId).delete();
  }

  // --- Sessions ---

  Future<void> saveWorkoutSession(String userId, WorkoutSession session) async {
    final data = Map<String, dynamic>.from(session.toJson());
    data['startTime'] = Timestamp.fromDate(session.startTime);
    if (session.endTime != null) {
      data['endTime'] = Timestamp.fromDate(session.endTime!);
    }
    data['exercises'] = session.exercises.map((ex) {
      final exMap = ex.toJson();
      exMap['sets'] = ex.sets.map((s) => s.toJson()).toList();
      return exMap;
    }).toList();
    await _sessionsCollection(userId).doc(session.id).set(data);
  }

  Future<List<WorkoutSession>> getWorkoutHistory(
    String userId, {
    int limit = 20,
  }) async {
    final snapshot = await _sessionsCollection(userId)
        .orderBy('startTime', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return WorkoutSession(
        id: doc.id,
        userId: userId,
        templateId: data['templateId'] as String?,
        templateName: data['templateName'] as String?,
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : null,
        exercises: (data['exercises'] as List<dynamic>?)
                ?.map((e) => SessionExercise.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        isCompleted: data['isCompleted'] as bool? ?? false,
      );
    }).toList();
  }

  Future<WorkoutSession?> getSession(String userId, String sessionId) async {
    final doc = await _sessionsCollection(userId).doc(sessionId).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    return WorkoutSession(
      id: doc.id,
      userId: userId,
      templateId: data['templateId'] as String?,
      templateName: data['templateName'] as String?,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => SessionExercise.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }
}
