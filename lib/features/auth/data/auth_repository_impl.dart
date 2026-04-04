import 'dart:async';

import '../domain/auth_repository.dart';
import '../../../shared/models/user_profile.dart';
import '../../../core/errors/failures.dart';

class StubAuthRepository implements AuthRepository {
  final _controller = StreamController<String?>.broadcast();
  String? _userId;

  @override
  Stream<String?> get authStateChanges => _controller.stream;

  @override
  String? get currentUserId => _userId;

  @override
  Future<(UserProfile?, Failure?)> signInWithEmail(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _userId = 'stub-user-001';
    _controller.add(_userId);
    return (
      UserProfile(
        id: 'stub-user-001',
        name: 'Alex Mercer',
        age: 24,
        weight: 82,
        height: 185,
        primaryGoal: FitnessGoal.hypertrophy,
      ),
      null,
    );
  }

  @override
  Future<(UserProfile?, Failure?)> signUpWithEmail(
    String email,
    String password,
  ) async {
    return signInWithEmail(email, password);
  }

  @override
  Future<Failure?> signOut() async {
    _userId = null;
    _controller.add(null);
    return null;
  }
}
