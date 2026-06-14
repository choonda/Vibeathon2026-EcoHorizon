import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../repositories/supabase_profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // TODO: Requires Supabase API key
  // return SupabaseProfileRepository.fromProvider();
  return MockProfileRepository();
});

// Add a mock repository for now
class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> ensureCurrentProfile() async => UserProfile.demo();
  @override
  Future<UserProfile?> fetchCurrentProfile() async => UserProfile.demo();
  @override
  Future<void> saveProfile(UserProfile profile) async {}
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<UserProfile?>>((ref) {
  return ProfileController(ref.read(profileRepositoryProvider))..loadDemoProfile();
});

class ProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileController(this._repository) : super(const AsyncValue.loading());

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    // TODO: Requires Supabase API key
    loadDemoProfile();
    /*
    SupabaseClient? client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      state = const AsyncValue.data(null);
      return;
    }

    final session = client.auth.currentSession;
    if (session == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = await AsyncValue.guard(_repository.ensureCurrentProfile);
    */
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
