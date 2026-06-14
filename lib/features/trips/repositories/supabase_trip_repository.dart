import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_record.dart';
import 'trip_repository.dart';

class SupabaseTripRepository implements TripRepository {
  SupabaseTripRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<TripRecord>> fetchTrips(String userId) async {
    // TODO: Requires Supabase API key
    return [];
    /*
    final rows = await _client.from('trips').select().eq('user_id', userId);
    return rows
        .map<TripRecord>(
          (row) => TripRecord(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            distanceKm: (row['distance_km'] as num).toDouble(),
            ecoScore: (row['eco_score'] as num).toInt(),
            fuelCostRm: (row['fuel_cost_rm'] as num).toDouble(),
            carbonSavedKg: (row['carbon_saved_kg'] as num).toDouble(),
            createdAt: DateTime.parse(row['created_at'] as String),
          ),
        )
        .toList();
    */
  }

  @override
  Future<void> saveTrip(TripRecord record) async {
    // TODO: Requires Supabase API key
    /*
    await _client.from('trips').insert(record.toJson());
    */
  }
}