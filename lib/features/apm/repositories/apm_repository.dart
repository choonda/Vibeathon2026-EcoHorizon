import '../models/apm_prediction.dart';

abstract class ApmRepository {
  Future<ApmPrediction> fetchLatestPrediction();
}

class MockApmRepository implements ApmRepository {
  @override
  Future<ApmPrediction> fetchLatestPrediction() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    return ApmPrediction.demo();
  }
}
