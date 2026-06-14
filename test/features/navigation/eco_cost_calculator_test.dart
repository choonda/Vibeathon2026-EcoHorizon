import 'package:flutter_test/flutter_test.dart';
import 'package:ecohorizon/core/utils/eco_cost_calculator.dart';

void main() {
  group('EcoCostCalculator Tests', () {
    test('RON95 calculations without subsidy', () {
      final result = EcoCostCalculator.calculate(
        distanceKm: 100.0,
        durationMinutes: 60, // 100 km/h average speed
        fuelType: 'RON95',
        subsidyTier: null,
      );

      // RON95 consumption = 7.2 L/100km. At 100 km/h average speed, no speed penalty.
      // Price = RM 3.72
      // Liters used = 7.2 L
      // Cost = 7.2 * 3.72 = RM 26.78
      // Carbon = 7.2 * 2.31 = 16.63 kg
      expect(result.litersUsed, equals(7.2));
      expect(result.fuelCostRm, equals(26.78));
      expect(result.carbonKg, equals(16.63));
    });

    test('RON95 calculations with BUDI95 subsidy', () {
      final result = EcoCostCalculator.calculate(
        distanceKm: 100.0,
        durationMinutes: 60,
        fuelType: 'RON95',
        subsidyTier: 'BUDI95',
      );

      // Price = RM 1.99 (subsidized)
      // Cost = 7.2 * 1.99 = RM 14.33
      expect(result.litersUsed, equals(7.2));
      expect(result.fuelCostRm, equals(14.33));
    });

    test('Diesel calculations with BUDIDIESEL subsidy', () {
      final result = EcoCostCalculator.calculate(
        distanceKm: 100.0,
        durationMinutes: 60,
        fuelType: 'Diesel',
        subsidyTier: 'BUDIDIESEL',
      );

      // Diesel baseline = 6.0 L/100km
      // Price = RM 2.15 (subsidized)
      // Cost = 6.0 * 2.15 = RM 12.90
      // Carbon = 6.0 * 2.68 = 16.08 kg
      expect(result.litersUsed, equals(6.0));
      expect(result.fuelCostRm, equals(12.90));
      expect(result.carbonKg, equals(16.08));
    });

    test('Congestion penalty applied for low speed', () {
      final result = EcoCostCalculator.calculate(
        distanceKm: 10.0,
        durationMinutes: 30, // 20 km/h average speed (< 25)
        fuelType: 'RON95',
        subsidyTier: 'BUDI95',
      );

      // Congestion penalty multiplier = 1.25
      // Consumption = 7.2 * 1.25 = 9.0 L/100km
      // Liters used for 10km = 0.9 L
      // Cost = 0.9 * 1.99 = RM 1.79
      // Carbon = 0.9 * 2.31 = 2.08
      expect(result.litersUsed, equals(0.9));
      expect(result.fuelCostRm, equals(1.79));
      expect(result.carbonKg, equals(2.08));
    });

    test('Eco-friendly route discount applied', () {
      final result = EcoCostCalculator.calculate(
        distanceKm: 100.0,
        durationMinutes: 80, // 75 km/h (no speed penalty)
        fuelType: 'RON95',
        subsidyTier: 'BUDI95',
        isEcoFriendlyRoute: true,
      );

      // Eco route multiplier = 0.9
      // Consumption = 7.2 * 0.9 = 6.48 L/100km
      // Liters used = 6.48 L
      // Cost = 6.48 * 1.99 = RM 12.90
      expect(result.litersUsed, equals(6.48));
      expect(result.fuelCostRm, equals(12.90));
    });

    test('Consumption override parameter is respected', () {
      final result = EcoCostCalculator.calculate(
        distanceKm: 100.0,
        durationMinutes: 80,
        fuelType: 'RON95',
        subsidyTier: 'BUDI95',
        consumptionOverrideLper100km: 9.5,
      );

      // Liters used = 9.5 L
      // Cost = 9.5 * 1.99 = RM 18.91
      expect(result.litersUsed, equals(9.5));
      expect(result.fuelCostRm, equals(18.91));
    });
  });
}
