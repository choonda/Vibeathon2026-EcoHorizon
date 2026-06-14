double estimateCarbonKg({
  required double distanceKm,
  required double emissionFactorKgPerKm,
}) {
  return distanceKm * emissionFactorKgPerKm;
}