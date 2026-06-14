import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_model.dart';
import 'trip_repository.dart';

class SupabaseTripRepository implements TripRepository {
  SupabaseTripRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<TripModel>> fetchUserTrips() async {
    // TODO: Requires Supabase API key
    return [];
    /*
    final rows = await _client.from('trips').select().eq('user_id', _client.auth.currentUser?.id);
    return rows
        .map<TripModel>(
          (row) => TripModel.fromJson(row as Map<String, dynamic>),
        )
        .toList();
    */
  }

  @override
  Future<void> uploadTrip(TripModel trip) async {
    // TODO: Requires Supabase API key
    /*
    await _client.from('trips').insert(trip.toJson());
    */
  }
}