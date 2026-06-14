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

  factory RouteOption.demoA() {
    return const RouteOption(
      name: 'Eco Route A',
      distanceKm: 12.4,
      durationMinutes: 24,
      fuelCostRm: 3.92,
      carbonKg: 1.84,
      polylinePoints: [
        LatLng(1.5621, 103.6420),
        LatLng(1.5580, 103.6550),
        LatLng(1.5490, 103.6620),
        LatLng(1.5420, 103.6700),
        LatLng(1.5350, 103.6820),
        LatLng(1.5300, 103.6950),
        LatLng(1.5240, 103.7100),
        LatLng(1.5180, 103.7250),
        LatLng(1.5120, 103.7400),
        LatLng(1.5080, 103.7550),
        LatLng(1.5030, 103.7680),
        LatLng(1.5008, 103.7772),
      ],
    );
  }

  factory RouteOption.demoB() {
    return const RouteOption(
      name: 'Fast Route B',
      distanceKm: 11.2,
      durationMinutes: 18,
      fuelCostRm: 4.31,
      carbonKg: 2.12,
      polylinePoints: [
        LatLng(1.5621, 103.6420),
        LatLng(1.5450, 103.6480),
        LatLng(1.5380, 103.6520),
        LatLng(1.5300, 103.6600),
        LatLng(1.5220, 103.6750),
        LatLng(1.5150, 103.7000),
        LatLng(1.5080, 103.7250),
        LatLng(1.5040, 103.7480),
        LatLng(1.5008, 103.7772),
      ],
    );
  }
}