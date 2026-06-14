import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
// ignore: unused_import
import '../repositories/supabase_profile_repository.dart'; // TODO: activate once Supabase credentials are available

// ---------------------------------------------------------------------------
// Mock Repository — stateful in-memory persistence for offline/PoC testing
// ---------------------------------------------------------------------------

/// A mock [ProfileRepository] that keeps the last saved profile in memory.
/// On first fetch, it falls back to [UserProfile.demo()].
class MockProfileRepository implements ProfileRepository {
  UserProfile? _stored;

  @override
  Future<UserProfile?> fetchCurrentProfile() async => _stored ?? UserProfile.demo();

  @override
  Future<UserProfile> ensureCurrentProfile() async => _stored ?? UserProfile.demo();

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _stored = profile;
  }
}

// ---------------------------------------------------------------------------
// Provider wiring
// ---------------------------------------------------------------------------

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // TODO: Swap to SupabaseProfileRepository.fromProvider() once credentials exist.
  return MockProfileRepository();
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<UserProfile?>>((ref) {
  return ProfileController(ref.read(profileRepositoryProvider))..loadDemoProfile();
});

// ---------------------------------------------------------------------------
// ProfileController
// ---------------------------------------------------------------------------

class ProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileController(this._repository) : super(const AsyncValue.loading());

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    // TODO: Requires Supabase API key — using demo profile for now.
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
    final saved = await _repository.fetchCurrentProfile();
    state = AsyncValue.data(saved ?? UserProfile.demo());
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

  /// Updates the full user profile. Persists via the active [ProfileRepository].
  Future<void> updateProfile({
    required String name,
    required String fuelType,
    String? subsidyTier,
    int? petrolPointsBalance,
    int? totalEcoScore,
  }) async {
    final current = state.value ?? UserProfile.demo();
    final updated = current.copyWith(
      name: name,
      fuelType: fuelType,
      subsidyTier: subsidyTier,
      clearSubsidyTier: subsidyTier == null,
      petrolPointsBalance: petrolPointsBalance ?? current.petrolPointsBalance,
      totalEcoScore: totalEcoScore ?? current.totalEcoScore,
    );
    state = AsyncValue.data(updated);
    await _repository.saveProfile(updated);
  }

  /// Alias for [updateProfile] — satisfies the task spec naming convention.
  Future<void> updateUser({
    required String name,
    required String fuelType,
    String? subsidyTier,
    int? petrolPointsBalance,
    int? totalEcoScore,
  }) =>
      updateProfile(
        name: name,
        fuelType: fuelType,
        subsidyTier: subsidyTier,
        petrolPointsBalance: petrolPointsBalance,
        totalEcoScore: totalEcoScore,
      );

  /// Increments the totalEcoScore by [points] and persists the change.
  Future<void> addEcoScore(int points) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(totalEcoScore: current.totalEcoScore + points);
    state = AsyncValue.data(updated);
    await _repository.saveProfile(updated);
  }
}
