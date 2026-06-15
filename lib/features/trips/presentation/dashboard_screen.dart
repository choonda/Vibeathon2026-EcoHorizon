import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/network/app_navigation_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../apm/controllers/apm_alert_controller.dart';
import '../../auth/controllers/profile_controller.dart';
import '../controllers/trip_history_controller.dart';
import '../controllers/ledger_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final apmState = ref.watch(apmAlertControllerProvider);
    final tripHistoryState = ref.watch(tripHistoryControllerProvider);
    final ledgerState = ref.watch(ledgerControllerProvider);
    final profile = profileState.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Map background slate
      body: Stack(
        children: [
          // 1. Full-screen map background simulation
          Positioned.fill(
            child: CustomPaint(
              painter: _StaticBackgroundMapPainter(),
            ),
          ),

          // 2. Scrollable Dashboard Body
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Row
                    profileState.when(
                      data: (profile) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary.withOpacity(0.12),
                                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.name ?? 'Eco Driver',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${profile?.fuelType ?? 'RON95'} | ${(profile?.subsidyTier == 'SUBSIDISED' || profile?.subsidyTier == 'BUDI95' || profile?.subsidyTier == 'BUDIDIESEL' || profile?.subsidyTier == 'BUDI_DIESEL') ? 'BUDI MADANI' : 'Standard Rate'}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🪙 ', style: TextStyle(fontSize: 14)),
                                Text(
                                  '${profile?.petrolPointsBalance ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'pts',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),

                    // Monthly Savings Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Estimated Fuel Savings (RM)',
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'RM ${ledgerState.totalSavingsRm.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.trending_down_rounded, color: AppColors.primary, size: 28),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Colors.white10, height: 1.0),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.park_rounded, color: AppColors.primary, size: 26),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Total Carbon Saved: ',
                                              style: TextStyle(fontSize: 13, color: Colors.white),
                                            ),
                                            Text(
                                              '${ledgerState.totalCarbonSavedKg.toStringAsFixed(1)} kg',
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ledgerState.impactString,
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fuel Price Updates Card
                    Row(
                      children: [
                        const Text(
                          'Fuel price',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Last updated on 4 Jun 2026',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          _FuelPriceRow(
                            fuelType: 'RON95',
                            badgeColor: const Color(0xFFFFB300),
                            textColor: Colors.black,
                            subsidisedPrice: 'RM 1.99/L',
                            pumpPrice: 'RM 3.72/L',
                            isActive: (profile?.fuelType.toUpperCase() == 'RON95'),
                          ),
                          const SizedBox(height: 8),
                          _FuelPriceRow(
                            fuelType: 'RON97',
                            badgeColor: const Color(0xFF0288D1),
                            textColor: Colors.white,
                            subsidisedPrice: 'N/A',
                            pumpPrice: 'RM 4.35/L',
                            isActive: (profile?.fuelType.toUpperCase() == 'RON97'),
                          ),
                          const SizedBox(height: 8),
                          _FuelPriceRow(
                            fuelType: 'Diesel',
                            badgeColor: const Color(0xFF757575),
                            textColor: Colors.white,
                            subsidisedPrice: 'RM 2.15/L',
                            pumpPrice: 'RM 4.67/L',
                            isActive: (profile?.fuelType.toUpperCase() == 'DIESEL'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Historical Trend Graph Section
                    const Text(
                      'ECO TREND',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Eco Score History',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          tripHistoryState.when(
                            data: (trips) {
                              if (trips.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Text(
                                      'No trip history yet.\nTap below to plan your first eco-trip!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                                    ),
                                  ),
                                );
                              }

                              final chronologicalTrips = trips.reversed.toList();
                              final spots = chronologicalTrips.asMap().entries.map((entry) {
                                final idx = entry.key.toDouble();
                                final score = entry.value.ecoScore.toDouble();
                                return FlSpot(idx, score);
                              }).toList();

                              return SizedBox(
                                height: 140,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (val) => FlLine(
                                        color: Colors.white.withOpacity(0.04),
                                        strokeWidth: 1.0,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget: (value, meta) {
                                            if (value % 25 != 0) return const SizedBox.shrink();
                                            return Text(
                                              '${value.toInt()}',
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          interval: 1.0,
                                          getTitlesWidget: (value, meta) {
                                            final intIdx = value.toInt();
                                            if (intIdx < 0 || intIdx >= chronologicalTrips.length) {
                                              return const SizedBox.shrink();
                                            }
                                            final trip = chronologicalTrips[intIdx];
                                            final dateStr = '${trip.createdAt.day}/${trip.createdAt.month}';
                                            return Text(
                                              dateStr,
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minX: 0,
                                    maxX: (spots.length - 1).toDouble().clamp(1.0, double.infinity),
                                    minY: 0,
                                    maxY: 100,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        color: AppColors.primary,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: AppColors.primary.withOpacity(0.08),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (err, _) => Center(
                              child: Text('Error loading history: $err', style: const TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Driving Analytics Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header Row
                          Row(
                            children: [
                              // Weekly Eco Score progress ring
                              (() {
                                final weeklyScore = profile?.totalEcoScore ?? 85;
                                return SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: 1.0,
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.06)),
                                      ),
                                      CircularProgressIndicator(
                                        value: weeklyScore / 100.0,
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(weeklyScore)),
                                      ),
                                      Text(
                                        '$weeklyScore',
                                        style: TextStyle(
                                          color: _getScoreColor(weeklyScore),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })(),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check out this week\'s drives',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Since Mon, 15 Jun',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white10, height: 1.0),
                          const SizedBox(height: 12),

                          // Analytics Items List
                          const _AnalyticsRow(
                            icon: Icons.speed_rounded,
                            iconColor: Color(0xFFEF4444),
                            title: 'Speeding',
                            count: 2,
                            hasTrendDown: false,
                          ),
                          const SizedBox(height: 12),
                          const _AnalyticsRow(
                            icon: Icons.phonelink_ring_rounded,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Distracted',
                            count: 1,
                            hasTrendDown: true,
                          ),
                          const SizedBox(height: 12),
                          const _AnalyticsRow(
                            icon: Icons.bolt_rounded,
                            iconColor: Color(0xFFD946EF),
                            title: 'Rapid Accel',
                            count: 3,
                            hasTrendDown: false,
                          ),
                          const SizedBox(height: 12),
                          const _AnalyticsRow(
                            icon: Icons.motion_photos_paused_rounded,
                            iconColor: Color(0xFFF59E0B),
                            title: 'Hard Braking',
                            count: 1,
                            hasTrendDown: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Trips List
                    const Text(
                      'RECENT TRIPS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    tripHistoryState.when(
                      data: (trips) {
                        if (trips.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No recent trips found.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: trips.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            final dateStr = '${trip.createdAt.day}/${trip.createdAt.month} ${trip.createdAt.hour}:${trip.createdAt.minute.toString().padLeft(2, "0")}';

                            final fuelType = profile?.fuelType ?? 'RON95';
                            final subsidyTier = profile?.subsidyTier;
                            final pricePerLiter = fuelType.toUpperCase() == 'RON95'
                                ? (subsidyTier == 'BUDI95' || subsidyTier == 'SUBSIDISED' ? 1.99 : 3.72)
                                : (fuelType.toUpperCase() == 'DIESEL' ? 3.35 : 3.47);
                            final litersConsumed = trip.fuelCostRm / pricePerLiter;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  // Score badge progress ring indicator
                                  SizedBox(
                                    width: 42,
                                    height: 42,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 1.0,
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.06)),
                                        ),
                                        CircularProgressIndicator(
                                          value: trip.ecoScore / 100.0,
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(trip.ecoScore)),
                                        ),
                                        Text(
                                          '${trip.ecoScore}',
                                          style: TextStyle(
                                            color: _getScoreColor(trip.ecoScore),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Middle details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trip.endLocation ?? 'Completed Trip',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateStr,
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Metrics values
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${trip.distanceKm.toStringAsFixed(1)} km',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.local_gas_station_rounded, color: Colors.amber, size: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${litersConsumed.toStringAsFixed(2)} L',
                                            style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.park_rounded, color: AppColors.primary, size: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${trip.carbonSavedKg.toStringAsFixed(1)}kg',
                                            style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Centered APM Pop-up warning (Wednesday afternoon simulated price hike)
          if (apmState.valueOrNull?.shouldShowAlert == true &&
              apmState.valueOrNull?.prediction != null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  color: Colors.black54, // Dim background
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.warning, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withOpacity(0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Warning icon with pulse highlight
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 48),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'APM Intelligent Price Alert',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            apmState.valueOrNull!.prediction!.alertMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your virtual tank level is at 35%.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () {
                                    ref.read(apmAlertControllerProvider.notifier).dismissAlert();
                                  },
                                  child: const Text('Dismiss', style: TextStyle(color: AppColors.textSecondary)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.warning,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () {
                                    ref.read(apmAlertControllerProvider.notifier).dismissAlert();
                                    ref.read(appNavigationProvider.notifier).navigateTo(AppScreen.routeComparison);
                                  },
                                  child: const Text('Plan Route', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.primary;
    if (score >= 70) return Colors.amber;
    return Colors.redAccent;
  }
}

// Background map simulation painter
class _StaticBackgroundMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Drawing coordinates grid lines
    const int gridSpacing = 40;
    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    for (double j = 0; j < size.height; j += gridSpacing) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paintGrid);
    }

    // Simulated roads
    final paintRoad = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintMainHighway = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 20.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Road 1: Diagonal Main highway
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.2), paintMainHighway);
    // Road 2: Sub-road crossing
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), paintRoad);
    // Road 3: Secondary sub-road
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.55), paintRoad);

    // Dynamic Station marker (Petronas Skudai warning pulse)
    final waypoint = Offset(size.width * 0.5, size.height * 0.5);
    final paintStation = Paint()
      ..color = AppColors.warning.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(waypoint, 7.0, paintStation);

    final paintPulse = Paint()
      ..color = AppColors.warning.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(waypoint, 18.0, paintPulse);
  }

  @override
  bool shouldRepaint(covariant _StaticBackgroundMapPainter oldDelegate) => false;
}

class _FuelPriceRow extends StatelessWidget {
  const _FuelPriceRow({
    required this.fuelType,
    required this.badgeColor,
    required this.textColor,
    required this.subsidisedPrice,
    required this.pumpPrice,
    required this.isActive,
  });

  final String fuelType;
  final Color badgeColor;
  final Color textColor;
  final String subsidisedPrice;
  final String pumpPrice;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.04) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          // Fuel Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_gas_station_rounded,
                  color: textColor,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  fuelType,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'YOUR FUEL',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          const Spacer(),
          // Subsidised Price Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Subsidised price',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                subsidisedPrice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Vertical Divider
          Container(
            height: 28,
            width: 1.0,
            color: AppColors.border,
          ),
          const SizedBox(width: 24),
          // Pump Price Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Pump Price',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                pumpPrice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  const _AnalyticsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.hasTrendDown,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;
  final bool hasTrendDown;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.02), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                hasTrendDown ? Icons.trending_down_rounded : Icons.arrow_forward_rounded,
                size: 13,
                color: hasTrendDown ? const Color(0xFF10B981) : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
