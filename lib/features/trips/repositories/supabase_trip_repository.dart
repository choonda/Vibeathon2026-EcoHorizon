import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_record.dart';
import 'trip_repository.dart';

class SupabaseTripRepository implements TripRepository {
  SupabaseTripRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<TripRecord>> fetchTrips(String userId) async {
    final rows = await _client
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
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
  }

  @override
  Future<void> saveTrip(TripRecord record) async {
    // Exclude 'id' and 'created_at' so Supabase generates them server-side
    await _client.from('trips').insert({
      'user_id': record.userId,
      'start_location': record.startLocation,
      'end_location': record.endLocation,
      'distance_km': record.distanceKm,
      'eco_score': record.ecoScore,
      'fuel_cost_rm': record.fuelCostRm,
      'carbon_saved_kg': record.carbonSavedKg,
    });
  }
}