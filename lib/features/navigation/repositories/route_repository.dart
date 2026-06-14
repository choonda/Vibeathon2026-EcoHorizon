import '../models/route_option.dart';
import '../../../core/utils/eco_cost_calculator.dart';

abstract class RouteRepository {
  Future<List<RouteOption>> fetchRouteOptions({
    required String start,
    required String end,
    String fuelType = 'RON95',
    String? subsidyTier,
  });
}

class MockRouteRepository implements RouteRepository {
  @override
  Future<List<RouteOption>> fetchRouteOptions({
    required String start,
    required String end,
    String fuelType = 'RON95',
    String? subsidyTier,
  }) async {
    // Dynamically calculate metrics for demo routes using EcoCostCalculator
    final ecoCalc = EcoCostCalculator.calculate(
      distanceKm: 12.4,
      durationMinutes: 24,
      fuelType: fuelType,
      subsidyTier: subsidyTier,
      isEcoFriendlyRoute: true,
    );

    final fastCalc = EcoCostCalculator.calculate(
      distanceKm: 11.2,
      durationMinutes: 18,
      fuelType: fuelType,
      subsidyTier: subsidyTier,
      isEcoFriendlyRoute: false,
    );

    final baseEcoRoute = RouteOption.demoA();
    final baseFastRoute = RouteOption.demoB();

    return [
      RouteOption(
        name: baseEcoRoute.name,
        distanceKm: baseEcoRoute.distanceKm,
        durationMinutes: baseEcoRoute.durationMinutes,
        fuelCostRm: ecoCalc.fuelCostRm,
        carbonKg: ecoCalc.carbonKg,
        polylinePoints: baseEcoRoute.polylinePoints,
      ),
      RouteOption(
        name: baseFastRoute.name,
        distanceKm: baseFastRoute.distanceKm,
        durationMinutes: baseFastRoute.durationMinutes,
        fuelCostRm: fastCalc.fuelCostRm,
        carbonKg: fastCalc.carbonKg,
        polylinePoints: baseFastRoute.polylinePoints,
      ),
    ];
  }
}