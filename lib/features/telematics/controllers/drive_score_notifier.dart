import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/scoring_rules.dart';
import '../sensors/sensor_repository.dart';

class DriveScoreState {
  const DriveScoreState({
    required this.score,
    required this.isWarning,
    required this.isTripActive,
  });

  factory DriveScoreState.initial() {
    return const DriveScoreState(
      score: ScoringRules.maxScore,
      isWarning: false,
      isTripActive: false,
    );
  }

  final int score;
  final bool isWarning;
  final bool isTripActive;

  DriveScoreState copyWith({int? score, bool? isWarning, bool? isTripActive}) {
    return DriveScoreState(
      score: score ?? this.score,
      isWarning: isWarning ?? this.isWarning,
      isTripActive: isTripActive ?? this.isTripActive,
    );
  }
}

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return MockSensorRepository();
});

final driveScoreNotifierProvider =
    StateNotifierProvider<DriveScoreNotifier, DriveScoreState>((ref) {
  return DriveScoreNotifier(ref.read(sensorRepositoryProvider));
});

class DriveScoreNotifier extends StateNotifier<DriveScoreState> {
  DriveScoreNotifier(this._sensorRepository) : super(DriveScoreState.initial());

  final SensorRepository _sensorRepository;
  StreamSubscription<double>? _subscription;
  Timer? _warningTimer;

  void startTrip() {
    state = state.copyWith(
      score: ScoringRules.maxScore,
      isWarning: false,
      isTripActive: true,
    );

    _subscription?.cancel();
    _subscription = _sensorRepository.gForceStream().listen((gForce) {
      if (!state.isTripActive) {
        return;
      }

      if (gForce.abs() <= ScoringRules.harshEventThresholdG) {
        return;
      }

      final nextScore = (state.score - ScoringRules.harshEventPenalty)
          .clamp(ScoringRules.minScore, ScoringRules.maxScore);

      state = state.copyWith(score: nextScore);
      _triggerWarning();
    });
  }

  void _triggerWarning() {
    state = state.copyWith(isWarning: true);
    _warningTimer?.cancel();
    _warningTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        state = state.copyWith(isWarning: false);
      }
    });
  }

  void clearWarning() {
    _warningTimer?.cancel();
    _warningTimer = null;
    state = state.copyWith(isWarning: false);
  }

  void endTrip() {
    _subscription?.cancel();
    _subscription = null;
    _warningTimer?.cancel();
    _warningTimer = null;
    state = state.copyWith(isTripActive: false, isWarning: false);
  }

  void simulateHarshEvent(double gForce) {
    if (!state.isTripActive) return;
    final penalty = ScoringRules.harshEventPenalty;
    final nextScore = (state.score - penalty).clamp(ScoringRules.minScore, ScoringRules.maxScore);
    state = state.copyWith(score: nextScore);
    _triggerWarning();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }
}