import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile_repository_impl.dart';
import '../../domain/profile_repository.dart';
import '../../../../shared/models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final userProfileProvider =
    FutureProvider.family<UserProfile?, String>((ref, userId) async {
      final (profile, _) =
          await ref.watch(profileRepositoryProvider).getProfile(userId);
      return profile;
    });

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _repo;

  ProfileNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    final (profile, failure) = await _repo.getProfile(userId);
    if (failure != null) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else {
      state = AsyncValue.data(profile);
    }
  }

  Future<bool> saveProfile(UserProfile profile) async {
    final failure = await _repo.saveProfile(profile);
    if (failure != null) return false;
    state = AsyncValue.data(profile);
    return true;
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      return ProfileNotifier(ref.watch(profileRepositoryProvider));
    });
