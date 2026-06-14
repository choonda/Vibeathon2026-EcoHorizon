import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecohorizon/features/telematics/controllers/drive_score_notifier.dart';
import 'package:ecohorizon/features/telematics/sensors/sensor_repository.dart';
import 'package:ecohorizon/core/constants/scoring_rules.dart';

class SimpleMockSensorRepository implements SensorRepository {
  @override
  Stream<double> gForceStream() {
    return const Stream<double>.empty();
  }
}

void main() {
  group('DriveScoreNotifier Tests', () {
    late ProviderContainer container;
    late SimpleMockSensorRepository mockSensorRepository;

    setUp(() {
      mockSensorRepository = SimpleMockSensorRepository();
      container = ProviderContainer(
        overrides: [
          sensorRepositoryProvider.overrideWithValue(mockSensorRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has correct defaults', () {
      final state = container.read(driveScoreNotifierProvider);
      expect(state.score, equals(ScoringRules.maxScore));
      expect(state.isWarning, isFalse);
      expect(state.isTripActive, isFalse);
    });

    test('startTrip sets active state and resets score', () {
      final notifier = container.read(driveScoreNotifierProvider.notifier);
      notifier.startTrip();

      final state = container.read(driveScoreNotifierProvider);
      expect(state.score, equals(ScoringRules.maxScore));
      expect(state.isWarning, isFalse);
      expect(state.isTripActive, isTrue);
    });

    test('simulateHarshEvent deducts points and sets temporary warning', () async {
      final notifier = container.read(driveScoreNotifierProvider.notifier);
      notifier.startTrip();

      // Simulate first harsh event
      notifier.simulateHarshEvent(0.4);

      var state = container.read(driveScoreNotifierProvider);
      expect(state.score, equals(95));
      expect(state.isWarning, isTrue);

      // Wait 1.6 seconds for warning to auto-expire
      await Future.delayed(const Duration(milliseconds: 1600));

      state = container.read(driveScoreNotifierProvider);
      expect(state.isWarning, isFalse);
    });

    test('endTrip clears warning and stops active status', () {
      final notifier = container.read(driveScoreNotifierProvider.notifier);
      notifier.startTrip();

      notifier.simulateHarshEvent(0.4);
      expect(container.read(driveScoreNotifierProvider).isWarning, isTrue);

      notifier.endTrip();
      final state = container.read(driveScoreNotifierProvider);
      expect(state.isTripActive, isFalse);
      expect(state.isWarning, isFalse);
    });
  });
}
