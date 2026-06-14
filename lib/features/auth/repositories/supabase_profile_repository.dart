import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  factory SupabaseProfileRepository.fromProvider() {
    return SupabaseProfileRepository(Supabase.instance.client);
  }

  final SupabaseClient _client;

  @override
  Future<UserProfile?> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response =
        await _client.from('users').select().eq('id', userId).maybeSingle();

    if (response == null) return null;

    return UserProfile(
      id: response['id'] as String,
      name: response['name'] as String? ?? 'Driver',
      fuelType: response['fuel_type'] as String? ?? 'RON95',
      subsidyTier: response['subsidy_tier'] as String?,
      petrolPointsBalance:
          (response['petrol_points_balance'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<UserProfile> ensureCurrentProfile() async {
    final existing = await fetchCurrentProfile();
    if (existing != null) {
      return existing;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user available.');
    }

    final fallbackName = user.email?.split('@').first ?? 'Driver';
    final profile = UserProfile(
      id: user.id,
      name: fallbackName,
      fuelType: 'RON95',
      subsidyTier: null,
      petrolPointsBalance: 0,
    );

    await saveProfile(profile);
    return profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _client.from('users').upsert({
      'id': profile.id,
      'name': profile.name,
      'fuel_type': profile.fuelType,
      'subsidy_tier': profile.subsidyTier,
      'petrol_points_balance': profile.petrolPointsBalance,
    });
  }
}
