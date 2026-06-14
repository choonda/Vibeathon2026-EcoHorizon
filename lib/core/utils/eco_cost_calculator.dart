class EcoCostCalculationResult {
  final double fuelCostRm;
  final double carbonKg;
  final double litersUsed;

  const EcoCostCalculationResult({
    required this.fuelCostRm,
    required this.carbonKg,
    required this.litersUsed,
  });
}

class EcoCostCalculator {
  static EcoCostCalculationResult calculate({
    required double distanceKm,
    required int durationMinutes,
    required String fuelType,
    String? subsidyTier,
    bool isEcoFriendlyRoute = false,
  }) {
    // Baseline consumption (L/100km)
    double baseLtrPer100Km = switch (fuelType.toUpperCase()) {
      'DIESEL' => 6.0,
      'RON97' => 7.8,
      'RON95' => 7.2,
      _ => 7.2,
    };

    // Adjust based on average speed (traffic idling vs smooth highway cruising)
    if (durationMinutes > 0) {
      final avgSpeed = distanceKm / (durationMinutes / 60.0);
      if (avgSpeed < 25.0) {
        // Congestion penalty (low speed stop-and-go)
        baseLtrPer100Km *= 1.25;
      } else if (avgSpeed > 100.0) {
        // High drag penalty (high speed wind resistance)
        baseLtrPer100Km *= 1.1;
      } else if (isEcoFriendlyRoute) {
        // Eco route traffic pattern optimization
        baseLtrPer100Km *= 0.9;
      }
    }

    // Fuel price (RM per liter)
    final pricePerLiter = switch (fuelType.toUpperCase()) {
      'RON95' => (subsidyTier == 'BUDI95') ? 2.05 : 3.10,
      'RON97' => 3.47,
      'DIESEL' => (subsidyTier == 'BUDIDIESEL' || subsidyTier == 'BUDI_DIESEL') ? 2.15 : 3.35,
      _ => 2.05,
    };

    final litersUsed = (distanceKm * baseLtrPer100Km) / 100.0;
    final cost = litersUsed * pricePerLiter;

    // Emission Factor (kg CO2 per liter)
    final emissionFactor = switch (fuelType.toUpperCase()) {
      'DIESEL' => 2.68,
      _ => 2.31, // Gasoline
    };
    final carbon = litersUsed * emissionFactor;

    return EcoCostCalculationResult(
      fuelCostRm: double.parse(cost.toStringAsFixed(2)),
      carbonKg: double.parse(carbon.toStringAsFixed(2)),
      litersUsed: double.parse(litersUsed.toStringAsFixed(2)),
    );
  }
}
