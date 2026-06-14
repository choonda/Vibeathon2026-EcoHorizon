class TripRecord {
  const TripRecord({
    required this.id,
    required this.userId,
    required this.distanceKm,
    required this.ecoScore,
    required this.fuelCostRm,
    required this.carbonSavedKg,
    required this.createdAt,
    this.startLocation,
    this.endLocation,
  });

  final String id;
  final String userId;
  final double distanceKm;
  final int ecoScore;
  final double fuelCostRm;
  final double carbonSavedKg;
  final DateTime createdAt;
  final String? startLocation;
  final String? endLocation;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_location': startLocation,
      'end_location': endLocation,
      'distance_km': distanceKm,
      'eco_score': ecoScore,
      'fuel_cost_rm': fuelCostRm,
      'carbon_saved_kg': carbonSavedKg,
      'created_at': createdAt.toIso8601String(),
    };
  }
}