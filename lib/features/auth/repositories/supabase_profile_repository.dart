import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  factory SupabaseProfileRepository.fromProvider() {
    // TODO: Requires Supabase API key
    throw UnimplementedError('Supabase is not initialized');
    // return SupabaseProfileRepository(Supabase.instance.client);
  }

  final SupabaseClient _client;

  @override
  Future<UserProfile?> fetchCurrentProfile() async {
    // TODO: Requires Supabase API key
    return null;
    /*
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response =
        await _client.from('users').select().eq('id', userId).maybeSingle();

    if (response == null) return null;

    return UserProfile.fromJson(response as Map<String, dynamic>);
    */
  }

  @override
  Future<UserProfile> ensureCurrentProfile() async {
    // TODO: Requires Supabase API key
    return UserProfile.demo();
    /*
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
      totalEcoScore: 0,
    );

    await saveProfile(profile);
    return profile;
    */
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    // TODO: Requires Supabase API key
    // Uses UserProfile.toJson() which maps field names to Supabase column names.
    /*
    await _client.from('users').upsert(profile.toJson());
    */
  }
}
