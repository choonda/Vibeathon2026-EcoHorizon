import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_record.dart';
import '../repositories/trip_repository.dart';
import '../repositories/supabase_trip_repository.dart';

import '../../auth/controllers/auth_controller.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  try {
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session != null) {
      return SupabaseTripRepository(Supabase.instance.client);
    }
  } catch (_) {
    // Fallback if Supabase is unconfigured or offline
  }
  return MockTripRepository();
});

final tripHistoryControllerProvider =
    StateNotifierProvider<TripHistoryController, AsyncValue<List<TripRecord>>>(
  (ref) {
    return TripHistoryController(ref.read(tripRepositoryProvider)).._init();
  },
);

class TripHistoryController
    extends StateNotifier<AsyncValue<List<TripRecord>>> {
  TripHistoryController(this._repository) : super(const AsyncValue.loading());

  final TripRepository _repository;

  void _init() {
    loadTrips('demo-user');
  }

  Future<void> loadTrips(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchTrips(userId));
  }

  void clearTrips() {
    state = const AsyncValue.data(<TripRecord>[]);
  }

  Future<void> saveTrip(TripRecord record) async {
    await _repository.saveTrip(record);
    // Reload trips to update listener states
    await loadTrips(record.userId);
  }
}
