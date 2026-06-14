import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/apm_alert.dart';
import '../models/apm_prediction.dart';
import 'apm_repository.dart';

/// Fetches the active APM alert for the user's fuel type from Supabase.
class SupabaseApmRepository implements ApmRepository {
  SupabaseApmRepository(this._client, {required this.fuelType});

  final SupabaseClient _client;
  final String fuelType;

  @override
  Future<ApmPrediction> fetchLatestPrediction() async {
    final rows = await _client
        .from('apm_alerts')
        .select()
        .eq('fuel_type', fuelType)
        .eq('is_active', true)
        .order('id', ascending: false)
        .limit(1);

    if (rows.isEmpty) {
      // Fallback to demo data if no active alert exists for this fuel type
      return ApmPrediction.demo();
    }

    final alert = ApmAlert.fromJson(rows.first as Map<String, dynamic>);
    return ApmPrediction(
      predictedIncreaseRm: alert.predictedIncreaseRm,
      alertMessage: alert.alertMessage,
      targetDate: DateTime.now().add(const Duration(days: 2)),
      isIncrease: alert.isIncrease,
    );
  }
}
