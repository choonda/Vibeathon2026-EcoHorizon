import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/trip_record.dart';
import 'trip_history_controller.dart';

class LedgerState {
  const LedgerState({
    required this.totalDistanceKm,
    required this.totalSavingsRm,
    required this.totalCarbonSavedKg,
    required this.impactString,
  });

  factory LedgerState.empty() {
    return const LedgerState(
      totalDistanceKm: 0.0,
      totalSavingsRm: 0.0,
      totalCarbonSavedKg: 0.0,
      impactString: 'No carbon saved yet. Start driving to make an impact!',
    );
  }

  final double totalDistanceKm;
  final double totalSavingsRm;
  final double totalCarbonSavedKg;
  final String impactString;

  LedgerState copyWith({
    double? totalDistanceKm,
    double? totalSavingsRm,
    double? totalCarbonSavedKg,
    String? impactString,
  }) {
    return LedgerState(
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalSavingsRm: totalSavingsRm ?? this.totalSavingsRm,
      totalCarbonSavedKg: totalCarbonSavedKg ?? this.totalCarbonSavedKg,
      impactString: impactString ?? this.impactString,
    );
  }
}

class LedgerController extends StateNotifier<LedgerState> {
  LedgerController(this.ref) : super(LedgerState.empty()) {
    // Listen to trip history changes to recalculate aggregate ledger state
    ref.listen<AsyncValue<List<TripRecord>>>(
      tripHistoryControllerProvider,
      (previous, next) {
        final trips = next.valueOrNull;
        if (trips != null) {
          _recalculate(trips);
        }
      },
      fireImmediately: true,
    );
  }

  final Ref ref;

  void _recalculate(List<TripRecord> trips) {
    if (trips.isEmpty) {
      state = LedgerState.empty();
      return;
    }

    double totalDist = 0.0;
    double totalSavings = 0.0;
    double totalCarbon = 0.0;

    for (final trip in trips) {
      totalDist += trip.distanceKm;
      // We assume fuel savings represent ~15% savings compared to standard route/drive
      totalSavings += trip.fuelCostRm * 0.15;
      totalCarbon += trip.carbonSavedKg;
    }

    final impact = translateCarbonToImpact(totalCarbon);

    state = LedgerState(
      totalDistanceKm: totalDist,
      totalSavingsRm: totalSavings,
      totalCarbonSavedKg: totalCarbon,
      impactString: impact,
    );
  }

  /// Maps saved carbon values (kg CO2) into concrete UI strings
  static String translateCarbonToImpact(double kgCo2) {
    if (kgCo2 <= 0) {
      return 'Start driving green to see your impact!';
    }
    if (kgCo2 < 5.0) {
      final percentage = (kgCo2 / 5.0 * 100).toStringAsFixed(0);
      return 'Equivalent to $percentage% of a tree planted in Skudai, Johor 🌳';
    } else {
      final trees = (kgCo2 / 5.0).toStringAsFixed(1);
      return 'Equivalent to planting $trees trees in Johor Bahru 🌳';
    }
  }
}

final ledgerControllerProvider =
    StateNotifierProvider<LedgerController, LedgerState>((ref) {
  return LedgerController(ref);
});
