import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/workout_repository.dart';
import '../../../shared/models/workout_template.dart';
import '../../../shared/models/workout_session.dart';
import '../../../core/errors/failures.dart';
import 'workout_firestore_data_source.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._dataSource);

  final WorkoutFirestoreDataSource _dataSource;

  @override
  Future<(List<WorkoutTemplate>, Failure?)> getTemplates(String userId) async {
    try {
      final templates = await _dataSource.getTemplates(userId);
      return (templates, null);
    } on FirebaseException catch (e) {
      return (<WorkoutTemplate>[], FirebaseFailure(e.message ?? 'Failed to fetch templates'));
    } catch (e) {
      return (<WorkoutTemplate>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> saveTemplate(String userId, WorkoutTemplate template) async {
    try {
      await _dataSource.saveTemplate(userId, template);
      return null;
    } on FirebaseException catch (e) {
      return FirebaseFailure(e.message ?? 'Failed to save template');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> deleteTemplate(String userId, String templateId) async {
    try {
      await _dataSource.deleteTemplate(userId, templateId);
      return null;
    } on FirebaseException catch (e) {
      return FirebaseFailure(e.message ?? 'Failed to delete template');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> saveWorkoutSession(WorkoutSession session) async {
    try {
      await _dataSource.saveWorkoutSession(session.userId, session);
      return null;
    } on FirebaseException catch (e) {
      return FirebaseFailure(e.message ?? 'Failed to save workout session');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<(List<WorkoutSession>, Failure?)> getWorkoutHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final sessions = await _dataSource.getWorkoutHistory(userId, limit: limit);
      return (sessions, null);
    } on FirebaseException catch (e) {
      return (<WorkoutSession>[], FirebaseFailure(e.message ?? 'Failed to fetch workout history'));
    } catch (e) {
      return (<WorkoutSession>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(WorkoutSession?, Failure?)> getSession(String userId, String sessionId) async {
    try {
      final session = await _dataSource.getSession(userId, sessionId);
      return (session, null);
    } on FirebaseException catch (e) {
      return (null, FirebaseFailure(e.message ?? 'Failed to fetch session'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}
