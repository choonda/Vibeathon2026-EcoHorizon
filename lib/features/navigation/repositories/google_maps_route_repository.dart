import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/route_option.dart';
import 'route_repository.dart';
import '../../../core/utils/eco_cost_calculator.dart';

class GoogleMapsRouteRepository implements RouteRepository {
  @override
  Future<List<RouteOption>> fetchRouteOptions({
    required String start,
    required String end,
    String fuelType = 'RON95',
    String? subsidyTier,
  }) async {
    const apiKey = 'AIzaSyAPMWhXDupTZ16jVwhhtrsmZ_DhSDIX4k8';
    // Key is also set in web/index.html for the map tiles renderer

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${Uri.encodeComponent(start)}'
        '&destination=${Uri.encodeComponent(end)}'
        '&alternatives=true'
        '&region=my'
        '&key=$apiKey'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        return _loadFallbackRoutes(fuelType, subsidyTier);
      }

      final data = json.decode(response.body);
      final routesList = data['routes'] as List?;
      if (routesList == null || routesList.isEmpty) {
        return _loadFallbackRoutes(fuelType, subsidyTier);
      }

      List<RouteOption> options = [];
      for (int i = 0; i < routesList.length; i++) {
        final route = routesList[i];
        final leg = (route['legs'] as List?)?.first;
        if (leg == null) continue;

        final distanceMeters = (leg['distance']?['value'] as num?)?.toDouble() ?? 0.0;
        final durationSeconds = (leg['duration']?['value'] as num?)?.toInt() ?? 0;
        final overviewPolyline = route['overview_polyline']?['points'] as String?;

        if (overviewPolyline == null) continue;

        final distanceKm = distanceMeters / 1000.0;
        final durationMinutes = (durationSeconds / 60.0).round();
        
        final isEco = i == 0; // Designate first as Eco Route, second as Fast Route
        final name = isEco ? 'Eco Route A' : 'Fast Route B';

        final ecoCalc = EcoCostCalculator.calculate(
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
          fuelType: fuelType,
          subsidyTier: subsidyTier,
          isEcoFriendlyRoute: isEco,
          consumptionOverrideLper100km: isEco ? null : 9.5,
        );

        final points = _decodePolyline(overviewPolyline);

        options.add(
          RouteOption(
            name: name,
            distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
            durationMinutes: durationMinutes,
            fuelCostRm: ecoCalc.fuelCostRm,
            carbonKg: ecoCalc.carbonKg,
            polylinePoints: points,
          ),
        );
      }

      if (options.isEmpty) {
        return _loadFallbackRoutes(fuelType, subsidyTier);
      }

      if (options.length < 2) {
        final first = options.first;
        final synthesizedDistance = first.distanceKm * 1.15;
        final synthesizedDuration = (first.durationMinutes * 0.85).round();

        final fastCalc = EcoCostCalculator.calculate(
          distanceKm: synthesizedDistance,
          durationMinutes: synthesizedDuration,
          fuelType: fuelType,
          subsidyTier: subsidyTier,
          isEcoFriendlyRoute: false,
          consumptionOverrideLper100km: 9.5,
        );

        final shiftedPoints = first.polylinePoints.map((p) {
          return LatLng(p.latitude + 0.001, p.longitude - 0.001);
        }).toList();

        options.add(
          RouteOption(
            name: 'Fast Route B',
            distanceKm: double.parse(synthesizedDistance.toStringAsFixed(1)),
            durationMinutes: synthesizedDuration,
            fuelCostRm: fastCalc.fuelCostRm,
            carbonKg: fastCalc.carbonKg,
            polylinePoints: shiftedPoints,
          ),
        );
      }

      return options;
    } catch (_) {
      return _loadFallbackRoutes(fuelType, subsidyTier);
    }
  }

  List<RouteOption> _loadFallbackRoutes(String fuelType, String? subsidyTier) {
    // Use the same distances as the demo polyline routes
    final baseEcoRoute = RouteOption.demoA(); // 24.3 km, 34 min
    final baseFastRoute = RouteOption.demoB(); // 21.8 km, 24 min

    // Default to subsidised RON95 if no profile subsidy tier set
    final effectiveTier = (subsidyTier?.isNotEmpty == true) ? subsidyTier : 'BUDI95';

    final ecoCalc = EcoCostCalculator.calculate(
      distanceKm: baseEcoRoute.distanceKm,
      durationMinutes: baseEcoRoute.durationMinutes,
      fuelType: fuelType,
      subsidyTier: effectiveTier,
      isEcoFriendlyRoute: true,
    );

    final fastCalc = EcoCostCalculator.calculate(
      distanceKm: baseFastRoute.distanceKm,
      durationMinutes: baseFastRoute.durationMinutes,
      fuelType: fuelType,
      subsidyTier: effectiveTier,
      isEcoFriendlyRoute: false,
      consumptionOverrideLper100km: 9.5,
    );

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

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}