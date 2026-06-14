import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/apm_prediction.dart';
import '../repositories/apm_repository.dart';

class ApmAlertState {
  const ApmAlertState({
    required this.shouldShowAlert,
    this.prediction,
    required this.virtualTankPercentage,
  });

  final bool shouldShowAlert;
  final ApmPrediction? prediction;
  final double virtualTankPercentage;

  ApmAlertState copyWith({
    bool? shouldShowAlert,
    ApmPrediction? prediction,
    double? virtualTankPercentage,
  }) {
    return ApmAlertState(
      shouldShowAlert: shouldShowAlert ?? this.shouldShowAlert,
      prediction: prediction ?? this.prediction,
      virtualTankPercentage: virtualTankPercentage ?? this.virtualTankPercentage,
    );
  }
}

final apmRepositoryProvider = Provider<ApmRepository>((ref) {
  return MockApmRepository();
});

final apmAlertControllerProvider =
    StateNotifierProvider<ApmAlertController, AsyncValue<ApmAlertState>>((ref) {
  return ApmAlertController(ref.read(apmRepositoryProvider))..initialize();
});

class ApmAlertController extends StateNotifier<AsyncValue<ApmAlertState>> {
  ApmAlertController(this._repository) : super(const AsyncValue.loading());

  final ApmRepository _repository;

  Future<void> initialize() async {
    try {
      final prediction = await _repository.fetchLatestPrediction();
      // Start with a simulated 35% virtual tank, which triggers the warning
      state = AsyncValue.data(ApmAlertState(
        shouldShowAlert: prediction.isIncrease, // Show if price is going up and tank is low
        prediction: prediction,
        virtualTankPercentage: 35.0, 
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateVirtualTank(double percentage) {
    final current = state.value;
    if (current == null) return;

    final isLow = percentage < 40.0;
    final isPriceHike = current.prediction?.isIncrease ?? false;

    state = AsyncValue.data(current.copyWith(
      virtualTankPercentage: percentage,
      shouldShowAlert: isLow && isPriceHike,
    ));
  }

  void dismissAlert() {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(shouldShowAlert: false));
  }
}
