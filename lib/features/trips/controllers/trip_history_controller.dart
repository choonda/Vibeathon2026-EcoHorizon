import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_record.dart';
import '../repositories/trip_repository.dart';
import '../repositories/supabase_trip_repository.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  // TODO: Requires Supabase API key
  // return SupabaseTripRepository(Supabase.instance.client);
  return MockTripRepository();
});

// Add a mock repository for now
class MockTripRepository implements TripRepository {
  @override
  Future<List<TripRecord>> fetchTrips(String userId) async => [];
  @override
  Future<void> saveTrip(TripRecord record) async {}
}

final tripHistoryControllerProvider =
    StateNotifierProvider<TripHistoryController, AsyncValue<List<TripRecord>>>(
  (ref) {
    return TripHistoryController(ref.read(tripRepositoryProvider));
  },
);

class TripHistoryController
    extends StateNotifier<AsyncValue<List<TripRecord>>> {
  TripHistoryController(this._repository) : super(const AsyncValue.loading());

  final TripRepository _repository;

  Future<void> loadTrips(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchTrips(userId));
  }

  void clearTrips() {
    state = const AsyncValue.data(<TripRecord>[]);
  }

  Future<void> saveTrip(TripRecord record) async {
    await _repository.saveTrip(record);
  }
}
