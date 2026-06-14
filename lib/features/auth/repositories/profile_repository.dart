import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> fetchCurrentProfile();
  Future<UserProfile> ensureCurrentProfile();
  Future<void> saveProfile(UserProfile profile);
}

class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> fetchCurrentProfile() async => UserProfile.demo();

  @override
  Future<UserProfile> ensureCurrentProfile() async => UserProfile.demo();

  @override
  Future<void> saveProfile(UserProfile profile) async {}
}
