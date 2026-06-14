import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../repositories/supabase_profile_repository.dart';
import 'auth_controller.dart';

export '../repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  try {
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session != null) {
      return SupabaseProfileRepository(Supabase.instance.client);
    }
  } catch (_) {
    // Fallback if Supabase is unconfigured or uninitialized
  }
  return MockProfileRepository();
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<UserProfile?>>((ref) {
  return ProfileController(ref.read(profileRepositoryProvider))..loadDemoProfile();
});

class ProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileController(this._repository) : super(const AsyncValue.loading());

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null) {
      state = const AsyncValue.data(null);
      return;
    }
    state = await AsyncValue.guard(_repository.ensureCurrentProfile);
  }

  Future<void> loadDemoProfile() async {
    state = AsyncValue.data(UserProfile.demo());
  }

  void clearProfile() {
    state = const AsyncValue.data(null);
  }

  Future<void> updateFuelType(String fuelType) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(fuelType: fuelType);
    state = AsyncValue.data(updated);
    await _repository.saveProfile(updated);
  }

  Future<void> updateProfile({
    required String name,
    required String fuelType,
    required String? subsidyTier,
    int? petrolPointsBalance,
  }) async {
    final current = state.value ?? UserProfile.demo();
    final updated = current.copyWith(
      name: name,
      fuelType: fuelType,
      subsidyTier: subsidyTier,
      petrolPointsBalance: petrolPointsBalance ?? current.petrolPointsBalance,
    );
    state = AsyncValue.data(updated);
    await _repository.saveProfile(updated);
  }
}
