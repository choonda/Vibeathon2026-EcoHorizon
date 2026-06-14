import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_model.dart';
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
  Future<void> uploadTrip(TripModel trip) async {}

  @override
  Future<List<TripModel>> fetchUserTrips() async => [];
}

final tripHistoryControllerProvider =
    StateNotifierProvider<TripHistoryController, AsyncValue<List<TripModel>>>(
  (ref) {
    return TripHistoryController(ref.read(tripRepositoryProvider));
  },
);

class TripHistoryController
    extends StateNotifier<AsyncValue<List<TripModel>>> {
  TripHistoryController(this._repository) : super(const AsyncValue.loading());

  final TripRepository _repository;

  Future<void> loadTrips(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchUserTrips());
  }

  void clearTrips() {
    state = const AsyncValue.data(<TripModel>[]);
  }

  Future<void> saveTrip(TripModel trip) async {
    await _repository.uploadTrip(trip);
  }

  Future<void> uploadTrip(TripModel trip) async {
    await _repository.uploadTrip(trip);
  }
}
