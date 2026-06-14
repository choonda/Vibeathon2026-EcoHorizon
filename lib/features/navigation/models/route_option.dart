import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteOption {
  const RouteOption({
    required this.name,
    required this.distanceKm,
    required this.durationMinutes,
    required this.fuelCostRm,
    required this.carbonKg,
    required this.polylinePoints,
  });

  final String name;
  final double distanceKm;
  final int durationMinutes;
  final double fuelCostRm;
  final double carbonKg;
  final List<LatLng> polylinePoints;

  // UTM Skudai → Seri Alam, Masai, Johor (eco/city route)
  // EcoCostCalculator: 24.3km, 28min → avgSpeed 52.1 km/h → eco factor 0.9
  //   consumption: 7.2 × 0.9 = 6.48 L/100km → 1.57L
  //   RON95 BUDI95 @ RM2.05/L → RM 3.23 | CO₂: 1.57 × 2.31 = 3.63 kg
  factory RouteOption.demoA() {
    return const RouteOption(
      name: 'Eco Route A',
      distanceKm: 24.3,
      durationMinutes: 28,
      fuelCostRm: 3.23, // RON95 subsidised — recalculated per profile on load
      carbonKg: 3.63,
      polylinePoints: [
        LatLng(1.5577, 103.6368), // UTM Skudai
        LatLng(1.5420, 103.6520), // Persiaran Skudai
        LatLng(1.5280, 103.6750), // Skudai heading south
        LatLng(1.5150, 103.7000), // Jalan Kebun Teh
        LatLng(1.5050, 103.7250), // Taman Universiti
        LatLng(1.4980, 103.7480), // Jalan Stulang
        LatLng(1.4930, 103.7700), // JB city outskirts
        LatLng(1.4880, 103.7960), // Jalan Tun Abdul Razak east
        LatLng(1.4840, 103.8200), // Masai corridor
        LatLng(1.4810, 103.8500), // Taman Seri Alam
        LatLng(1.4789, 103.8870), // Seri Alam, Masai
      ],
    );
  }

  // UTM Skudai → Seri Alam, Masai, Johor (fast highway via EDL)
  // EcoCostCalculator: 21.8km, 24min → avgSpeed 54.5 km/h
  //   consumption override: 9.5 L/100km → 2.07L
  //   RON95 BUDI95 @ RM2.05/L → RM 4.25 | CO₂: 2.07 × 2.31 = 4.78 kg
  factory RouteOption.demoB() {
    return const RouteOption(
      name: 'Fast Route B',
      distanceKm: 21.8,
      durationMinutes: 24,
      fuelCostRm: 4.25, // RON95 subsidised — recalculated per profile on load
      carbonKg: 4.78,
      polylinePoints: [
        LatLng(1.5577, 103.6368), // UTM Skudai
        LatLng(1.5500, 103.6620), // Skudai highway entry
        LatLng(1.5350, 103.6900), // SJE expressway
        LatLng(1.5200, 103.7100), // EDL approach
        LatLng(1.5050, 103.7350), // EDL north
        LatLng(1.4950, 103.7600), // EDL mid
        LatLng(1.4870, 103.7900), // EDL east
        LatLng(1.4820, 103.8200), // Masai exit
        LatLng(1.4789, 103.8870), // Seri Alam, Masai
      ],
    );
  }
}
