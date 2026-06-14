class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.fuelType,
    required this.petrolPointsBalance,
    required this.totalEcoScore,
    this.subsidyTier,
  });

  final String id;
  final String name;
  final String fuelType;
  final String? subsidyTier;
  final int petrolPointsBalance;
  final int totalEcoScore;

  factory UserProfile.demo() {
    return const UserProfile(
      id: 'demo-user',
      name: 'Eco Driver',
      fuelType: 'RON95',
      subsidyTier: 'B40',
      petrolPointsBalance: 120,
      totalEcoScore: 85,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Driver',
      fuelType: json['fuel_type'] as String? ?? 'RON95',
      subsidyTier: json['subsidy_tier'] as String?,
      petrolPointsBalance:
          (json['petrol_points_balance'] as num?)?.toInt() ?? 0,
      totalEcoScore: (json['total_eco_score'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fuel_type': fuelType,
      'subsidy_tier': subsidyTier,
      'petrol_points_balance': petrolPointsBalance,
      'total_eco_score': totalEcoScore,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? fuelType,
    String? subsidyTier,
    int? petrolPointsBalance,
    int? totalEcoScore,
    bool clearSubsidyTier = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      fuelType: fuelType ?? this.fuelType,
      subsidyTier: clearSubsidyTier ? null : (subsidyTier ?? this.subsidyTier),
      petrolPointsBalance: petrolPointsBalance ?? this.petrolPointsBalance,
      totalEcoScore: totalEcoScore ?? this.totalEcoScore,
    );
  }
}