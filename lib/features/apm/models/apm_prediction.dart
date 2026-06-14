class ApmPrediction {
  const ApmPrediction({
    required this.predictedIncreaseRm,
    required this.alertMessage,
    required this.targetDate,
    required this.isIncrease,
  });

  final double predictedIncreaseRm;
  final String alertMessage;
  final DateTime targetDate;
  final bool isIncrease;

  factory ApmPrediction.demo() {
    return ApmPrediction(
      predictedIncreaseRm: 0.08,
      alertMessage: 'APM predicts a price hike of RM0.08/L tomorrow. Plan a refuel soon!',
      targetDate: DateTime.now().add(const Duration(days: 2)), // Simulated upcoming Thursday
      isIncrease: true,
    );
  }
}
