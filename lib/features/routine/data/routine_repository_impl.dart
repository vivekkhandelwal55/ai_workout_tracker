import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/routine_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../shared/models/workout_routine.dart';
import 'routine_firestore_data_source.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  RoutineRepositoryImpl(this._dataSource);

  final RoutineFirestoreDataSource _dataSource;

  @override
  Stream<WorkoutRoutine?> watchRoutine(String userId) {
    // Errors in the stream surface as AsyncError in the provider layer.
    return _dataSource.watchRoutine(userId);
  }

  @override
  Future<(WorkoutRoutine?, Failure?)> getRoutine(String userId) async {
    try {
      final routine = await _dataSource.getRoutine(userId);
      return (routine, null);
    } on FirebaseException catch (e) {
      return (null, FirebaseFailure(e.message ?? 'Failed to fetch routine'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> saveRoutine(WorkoutRoutine routine) async {
    try {
      await _dataSource.saveRoutine(routine);
      return null;
    } on FirebaseException catch (e) {
      return FirebaseFailure(e.message ?? 'Failed to save routine');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> deleteRoutine(String userId) async {
    try {
      await _dataSource.deleteRoutine(userId);
      return null;
    } on FirebaseException catch (e) {
      return FirebaseFailure(e.message ?? 'Failed to delete routine');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
