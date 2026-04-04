import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../../../../shared/models/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return StubAuthRepository();
});

final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Auth notifier state
class AuthState {
  final bool isLoading;
  final String? error;
  final UserProfile? user;

  const AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, UserProfile? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final (user, failure) = await _repo.signInWithEmail(email, password);
    if (failure != null) {
      state = state.copyWith(isLoading: false, error: failure.message);
      return false;
    }
    state = state.copyWith(isLoading: false, user: user);
    return true;
  }

  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final (user, failure) = await _repo.signUpWithEmail(email, password);
    if (failure != null) {
      state = state.copyWith(isLoading: false, error: failure.message);
      return false;
    }
    state = state.copyWith(isLoading: false, user: user);
    return true;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });
