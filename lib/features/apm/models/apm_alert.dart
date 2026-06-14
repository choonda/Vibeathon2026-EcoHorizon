/// Represents a single row from the Supabase `apm_alerts` table.
class ApmAlert {
  const ApmAlert({
    required this.id,
    required this.fuelType,
    required this.predictedIncreaseRm,
    required this.alertMessage,
    required this.isActive,
  });

  final String id;
  final String fuelType;
  final double predictedIncreaseRm;
  final String alertMessage;
  final bool isActive;

  factory ApmAlert.fromJson(Map<String, dynamic> json) {
    return ApmAlert(
      id: json['id'] as String,
      fuelType: json['fuel_type'] as String,
      predictedIncreaseRm:
          (json['predicted_increase_rm'] as num?)?.toDouble() ?? 0.0,
      alertMessage: json['alert_message'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  /// Convert to the existing ApmPrediction model used by the controller.
  bool get isIncrease => predictedIncreaseRm > 0;
}
