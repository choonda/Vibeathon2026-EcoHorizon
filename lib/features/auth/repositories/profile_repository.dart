import '../models/user_profile.dart';

/// Abstract interface for the profile data source.
/// Implementations: [MockProfileRepository], [SupabaseProfileRepository].
abstract class ProfileRepository {
  Future<UserProfile?> fetchCurrentProfile();
  Future<UserProfile> ensureCurrentProfile();
  Future<void> saveProfile(UserProfile profile);
}

class MockProfileRepository implements ProfileRepository {
  UserProfile? _stored;

  @override
  Future<UserProfile?> fetchCurrentProfile() async {
    return _stored ?? UserProfile.demo();
  }

  @override
  Future<UserProfile> ensureCurrentProfile() async {
    return _stored ?? UserProfile.demo();
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _stored = profile;
  }
}
