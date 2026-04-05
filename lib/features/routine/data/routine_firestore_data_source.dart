import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/workout_routine.dart';

class RoutineFirestoreDataSource {
  RoutineFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _routineDoc(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.routine)
          .doc(RoutineDocFields.documentId);

  // ---------------------------------------------------------------------------
  // Read helpers
  // ---------------------------------------------------------------------------

  WorkoutRoutine _fromFirestoreData(Map<String, dynamic> data, String userId) {
    return WorkoutRoutine(
      id: RoutineDocFields.documentId,
      userId: userId,
      startDate: (data[RoutineDocFields.startDate] as Timestamp).toDate(),
      createdAt: data[RoutineDocFields.createdAt] != null
          ? (data[RoutineDocFields.createdAt] as Timestamp).toDate()
          : null,
      updatedAt: data[RoutineDocFields.updatedAt] != null
          ? (data[RoutineDocFields.updatedAt] as Timestamp).toDate()
          : null,
      days: (data[RoutineDocFields.days] as List<dynamic>? ?? [])
          .map(
            (e) => RoutineDay.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Write helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _toFirestoreData(WorkoutRoutine routine) {
    return <String, dynamic>{
      RoutineDocFields.userId: routine.userId,
      RoutineDocFields.startDate: Timestamp.fromDate(routine.startDate),
      RoutineDocFields.createdAt: routine.createdAt != null
          ? Timestamp.fromDate(routine.createdAt!)
          : FieldValue.serverTimestamp(),
      RoutineDocFields.updatedAt: FieldValue.serverTimestamp(),
      RoutineDocFields.days: routine.days.map((d) => d.toJson()).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  Stream<WorkoutRoutine?> watchRoutine(String userId) {
    return _routineDoc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return _fromFirestoreData(snap.data()!, userId);
    });
  }

  Future<WorkoutRoutine?> getRoutine(String userId) async {
    final snap = await _routineDoc(userId).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestoreData(snap.data()!, userId);
  }

  Future<void> saveRoutine(WorkoutRoutine routine) async {
    await _routineDoc(routine.userId).set(_toFirestoreData(routine));
  }

  Future<void> deleteRoutine(String userId) async {
    await _routineDoc(userId).delete();
  }
}
