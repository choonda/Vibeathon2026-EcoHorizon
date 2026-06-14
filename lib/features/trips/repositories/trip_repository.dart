import '../models/trip_record.dart';

abstract class TripRepository {
  Future<void> saveTrip(TripRecord record);
  Future<List<TripRecord>> fetchTrips(String userId);
}

class MockTripRepository implements TripRepository {
  MockTripRepository() {
    _records.addAll([
      TripRecord(
        id: 'trip-1',
        userId: 'demo-user',
        distanceKm: 15.4,
        ecoScore: 92,
        fuelCostRm: 4.80,
        carbonSavedKg: 2.1,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      TripRecord(
        id: 'trip-2',
        userId: 'demo-user',
        distanceKm: 24.1,
        ecoScore: 78,
        fuelCostRm: 8.50,
        carbonSavedKg: 1.8,
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      ),
      TripRecord(
        id: 'trip-3',
        userId: 'demo-user',
        distanceKm: 8.2,
        ecoScore: 95,
        fuelCostRm: 2.10,
        carbonSavedKg: 1.5,
        createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      ),
    ]);
  }

  final List<TripRecord> _records = [];

  @override
  Future<List<TripRecord>> fetchTrips(String userId) async {
    // Return all trips for demo simplicity, or filter
    return _records;
  }

  @override
  Future<void> saveTrip(TripRecord record) async {
    _records.insert(0, record);
  }
}