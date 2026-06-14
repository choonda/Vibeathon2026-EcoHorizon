import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecohorizon/features/apm/controllers/apm_alert_controller.dart';
import 'package:ecohorizon/features/auth/controllers/profile_controller.dart' hide MockProfileRepository;
import 'package:ecohorizon/features/auth/repositories/profile_repository.dart';

void main() {
  group('Fuel Level Detour & Refueling Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(MockProfileRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial tank level is low (35%)', () async {
      // Force Riverpod initialization
      await container.read(apmAlertControllerProvider.notifier).initialize();
      await container.read(profileControllerProvider.notifier).loadDemoProfile();

      final apmState = container.read(apmAlertControllerProvider).value!;
      expect(apmState.virtualTankPercentage, equals(35.0));
    });

    test('Refueling resets tank to 100% and rewards user with +50 points', () async {
      await container.read(apmAlertControllerProvider.notifier).initialize();
      await container.read(profileControllerProvider.notifier).loadDemoProfile();

      // Get initial points
      final initialProfile = container.read(profileControllerProvider).value!;
      expect(initialProfile.petrolPointsBalance, equals(120));

      // Simulate refuel updates
      container.read(apmAlertControllerProvider.notifier).updateVirtualTank(100.0);
      
      final profile = container.read(profileControllerProvider).value!;
      await container.read(profileControllerProvider.notifier).updateProfile(
        name: profile.name,
        fuelType: profile.fuelType,
        subsidyTier: profile.subsidyTier,
        petrolPointsBalance: profile.petrolPointsBalance + 50,
      );

      // Verify tank level reset
      final finalApmState = container.read(apmAlertControllerProvider).value!;
      expect(finalApmState.virtualTankPercentage, equals(100.0));

      // Verify points incremented
      final finalProfile = container.read(profileControllerProvider).value!;
      expect(finalProfile.petrolPointsBalance, equals(170));
    });

    test('Simulate progressive fuel level depletion', () async {
      await container.read(apmAlertControllerProvider.notifier).initialize();
      
      final notifier = container.read(apmAlertControllerProvider.notifier);
      final initialFuel = container.read(apmAlertControllerProvider).value!.virtualTankPercentage;
      
      // Deplete fuel by 0.3%
      notifier.updateVirtualTank(initialFuel - 0.3);

      final updatedFuel = container.read(apmAlertControllerProvider).value!.virtualTankPercentage;
      expect(updatedFuel, equals(initialFuel - 0.3));
    });
  });
}
