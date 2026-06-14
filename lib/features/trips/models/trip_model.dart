// class TripRecord {
//   const TripRecord({
//     required this.id,
//     required this.userId,
//     required this.distanceKm,
//     required this.ecoScore,
//     required this.fuelCostRm,
//     required this.carbonSavedKg,
//     required this.createdAt,
//   });

//   final String id;
//   final String userId;
//   final double distanceKm;
//   final int ecoScore;
//   final double fuelCostRm;
//   final double carbonSavedKg;
//   final DateTime createdAt;

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'distance_km': distanceKm,
//       'eco_score': ecoScore,
//       'fuel_cost_rm': fuelCostRm,
//       'carbon_saved_kg': carbonSavedKg,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }

class TripModel {
  final String id;
  final String userId;
  final double distanceKm;
  final int ecoScore;
  final double fuelCostRm;
  final double carbonSavedKg;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.distanceKm,
    required this.ecoScore,
    required this.fuelCostRm,
    required this.carbonSavedKg,
    required this.createdAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      ecoScore: json['eco_score'] as int,
      fuelCostRm: (json['fuel_cost_rm'] as num).toDouble(),
      carbonSavedKg: (json['carbon_saved_kg'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

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