import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authSessionProvider = StreamProvider<Session?>((ref) {
  // TODO: Requires Supabase API key
  return Stream.value(null);
  /*
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    return event.session;
  });
  */
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  // TODO: Requires Supabase API key
  // return AuthController(Supabase.instance.client);
  return AuthController();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  // AuthController(this._client) : super(const AsyncData(null));
  AuthController() : super(const AsyncData(null));

  // final SupabaseClient _client;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    // TODO: Requires Supabase API key
    state = const AsyncData(null);
    /*
    state = await AsyncValue.guard(() async {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    });
    */
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    // TODO: Requires Supabase API key
    state = const AsyncData(null);
    /*
    state = await AsyncValue.guard(() async {
      await _client.auth.signUp(
        email: email,
        password: password,
      );
    });
    */
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    // TODO: Requires Supabase API key
    state = const AsyncData(null);
    /*
    state = await AsyncValue.guard(() async {
      await _client.auth.signOut();
    });
    */
  }
}
