import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';

class LedgerState {
  final List<TripModel> trips;
  final int petrolPointsBalance;
  final bool isLoading;

  LedgerState({
    required this.trips,
    required this.petrolPointsBalance,
    this.isLoading = false,
  });

  LedgerState copyWith({
    List<TripModel>? trips,
    int? petrolPointsBalance,
    bool? isLoading,
  }) {
    return LedgerState(
      trips: trips ?? this.trips,
      petrolPointsBalance: petrolPointsBalance ?? this.petrolPointsBalance,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LedgerController extends StateNotifier<LedgerState> {
  final TripRepository repository;

  LedgerController(this.repository) : super(LedgerState(trips: [], petrolPointsBalance: 1250)) {
    loadTrips();
  }

  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true);
    final trips = await repository.fetchUserTrips();
    state = state.copyWith(trips: trips, isLoading: false);
  }

  // Mocks UI update for the pitch demonstration without relying on cloud logic
  Future<void> simulateTripUpload(TripModel newTrip) async {
    await repository.uploadTrip(newTrip);
    
    // Simulate points calculation based on eco-score and distance
    final earnedPoints = (newTrip.ecoScore * (newTrip.distanceKm / 10)).round();
    
    state = state.copyWith(
      trips: [newTrip, ...state.trips],
      petrolPointsBalance: state.petrolPointsBalance + earnedPoints,
    );
  }

  // Impact Translator: 20kg of CO2 saved = 1 tree
  String translateImpact(double totalCarbonSavedKg) {
    final trees = (totalCarbonSavedKg / 20.0).floor();
    if (trees < 1) return "Keep driving eco-friendly to plant your first tree!";
    return "$trees Tree${trees == 1 ? '' : 's'} Planted in Johor Bahru";
  }
  
  double get totalCarbonSaved => state.trips.fold(0.0, (sum, trip) => sum + trip.carbonSavedKg);
}

final tripRepositoryProvider = Provider<TripRepository>((ref) => MockTripRepository());

final ledgerControllerProvider = StateNotifierProvider<LedgerController, LedgerState>((ref) {
  return LedgerController(ref.watch(tripRepositoryProvider));
});