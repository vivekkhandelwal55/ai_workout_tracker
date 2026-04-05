import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/auth_repository_impl.dart';
import '../../data/firebase_auth_data_source.dart';
import '../../data/user_profile_data_source.dart';
import '../../../../shared/models/user_profile.dart';

part 'auth_providers.g.dart';

@riverpod
FirebaseAuthRepositoryImpl authRepository(Ref ref) {
  return FirebaseAuthRepositoryImpl(
    FirebaseAuthDataSource(
      firebase_auth.FirebaseAuth.instance,
      GoogleSignIn(),
    ),
    UserProfileDataSource(FirebaseFirestore.instance),
  );
}

@riverpod
Stream<UserProfile?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserProfile?> build() async {
    return ref.watch(authStateProvider).valueOrNull;
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final (user, failure) = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(email, password);
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
      return;
    }
    state = AsyncData(user);
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    state = const AsyncLoading();
    final (user, failure) = await ref
        .read(authRepositoryProvider)
        .signUpWithEmail(email, password, displayName: displayName);
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
      return;
    }
    state = AsyncData(user);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final (user, failure) =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
      return;
    }
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncLoading();
    final failure =
        await ref.read(authRepositoryProvider).updateUserProfile(profile);
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
      return;
    }
    state = AsyncData(profile);
  }
}
