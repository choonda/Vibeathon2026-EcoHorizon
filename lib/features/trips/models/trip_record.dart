class TripRecord {
  const TripRecord({
    required this.id,
    required this.userId,
    required this.distanceKm,
    required this.ecoScore,
    required this.fuelCostRm,
    required this.carbonSavedKg,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final double distanceKm;
  final int ecoScore;
  final double fuelCostRm;
  final double carbonSavedKg;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'distance_km': distanceKm,
      'eco_score': ecoScore,
      'fuel_cost_rm': fuelCostRm,
      'carbon_saved_kg': carbonSavedKg,
      'created_at': createdAt.toIso8601String(),
    };
  }
}