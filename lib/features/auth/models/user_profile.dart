class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.fuelType,
    required this.petrolPointsBalance,
    this.subsidyTier,
  });

  final String id;
  final String name;
  final String fuelType;
  final String? subsidyTier;
  final int petrolPointsBalance;

  factory UserProfile.demo() {
    return const UserProfile(
      id: 'demo-user',
      name: 'Eco Driver',
      fuelType: 'RON95',
      subsidyTier: 'BUDI95',
      petrolPointsBalance: 120,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? fuelType,
    String? subsidyTier,
    int? petrolPointsBalance,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      fuelType: fuelType ?? this.fuelType,
      subsidyTier: subsidyTier ?? this.subsidyTier,
      petrolPointsBalance: petrolPointsBalance ?? this.petrolPointsBalance,
    );
  }
}