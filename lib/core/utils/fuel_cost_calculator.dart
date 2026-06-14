double estimateFuelCostRm({
  required double distanceKm,
  required double literPer100Km,
  required double fuelPricePerLiter,
}) {
  final litersUsed = distanceKm * literPer100Km / 100.0;
  return litersUsed * fuelPricePerLiter;
}