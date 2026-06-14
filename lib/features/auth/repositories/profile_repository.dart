import '../models/user_profile.dart';

/// Abstract interface for the profile data source.
/// Implementations: [MockProfileRepository], [SupabaseProfileRepository].
abstract class ProfileRepository {
  Future<UserProfile?> fetchCurrentProfile();
  Future<UserProfile> ensureCurrentProfile();
  Future<void> saveProfile(UserProfile profile);
}
