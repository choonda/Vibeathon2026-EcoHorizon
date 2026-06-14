// import '../models/trip_record.dart';

// abstract class TripRepository {
//   Future<void> saveTrip(TripRecord record);
//   Future<List<TripRecord>> fetchTrips(String userId);
// }

// class MockTripRepository implements TripRepository {
//   MockTripRepository() {
//     _records.addAll([
//       TripRecord(
//         id: 'trip-1',
//         userId: 'demo-user',
//         distanceKm: 15.4,
//         ecoScore: 92,
//         fuelCostRm: 4.80,
//         carbonSavedKg: 2.1,
//         createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
//       ),
//       TripRecord(
//         id: 'trip-2',
//         userId: 'demo-user',
//         distanceKm: 24.1,
//         ecoScore: 78,
//         fuelCostRm: 8.50,
//         carbonSavedKg: 1.8,
//         createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
//       ),
//       TripRecord(
//         id: 'trip-3',
//         userId: 'demo-user',
//         distanceKm: 8.2,
//         ecoScore: 95,
//         fuelCostRm: 2.10,
//         carbonSavedKg: 1.5,
//         createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
//       ),
//     ]);
//   }

//   final List<TripRecord> _records = [];

//   @override
//   Future<List<TripRecord>> fetchTrips(String userId) async {
//     // Return all trips for demo simplicity, or filter
//     return _records;
//   }

//   @override
//   Future<void> saveTrip(TripRecord record) async {
//     _records.insert(0, record);
//   }
// }

import '../models/trip_model.dart';

abstract class TripRepository {
  Future<void> uploadTrip(TripModel trip);
  Future<List<TripModel>> fetchUserTrips();
}

class MockTripRepository implements TripRepository {
  // Hardcoded mock array for zero-latency hackathon pitch demonstration
  final List<TripModel> _mockTrips = [
    TripModel(
      id: 'trip_001',
      userId: 'user_mock',
      distanceKm: 15.4,
      ecoScore: 88,
      fuelCostRm: 3.45,
      carbonSavedKg: 12.5,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TripModel(
      id: 'trip_002',
      userId: 'user_mock',
      distanceKm: 42.1,
      ecoScore: 92,
      fuelCostRm: 8.90,
      carbonSavedKg: 28.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TripModel(
      id: 'trip_003',
      userId: 'user_mock',
      distanceKm: 8.2,
      ecoScore: 76,
      fuelCostRm: 1.85,
      carbonSavedKg: 4.2,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<void> uploadTrip(TripModel trip) async {
    // Simulating instant upload 
    _mockTrips.insert(0, trip);
  }

  @override
  Future<List<TripModel>> fetchUserTrips() async {
    return _mockTrips;
  }
}