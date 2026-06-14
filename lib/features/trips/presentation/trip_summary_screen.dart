import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/network/app_navigation_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/profile_controller.dart';
import '../../rewards/controllers/reward_controller.dart';
import '../../telematics/controllers/drive_score_notifier.dart';
import '../controllers/trip_history_controller.dart';
import '../models/trip_record.dart';

class TripSummaryScreen extends ConsumerStatefulWidget {
  const TripSummaryScreen({super.key});

  @override
  ConsumerState<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _DashboardParticle {
  _DashboardParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
  });

  double x;
  double y;
  final double size;
  final Color color;
  final double velocity;
}

class _TripSummaryScreenState extends ConsumerState<TripSummaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  final List<_DashboardParticle> _particles = [];
  final Random _random = Random();
  bool _isLoadingClaim = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Generate random confetti particles
    for (int i = 0; i < 40; i++) {
      _particles.add(
        _DashboardParticle(
          x: _random.nextDouble() * 300 - 150,
          y: _random.nextDouble() * 400 + 100,
          size: _random.nextDouble() * 8 + 4,
          color: _random.nextBool()
              ? AppColors.primary
              : (_random.nextBool() ? Colors.amber : const Color(0xFF00E5FF)),
          velocity: _random.nextDouble() * 3 + 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardState = ref.watch(rewardControllerProvider);
    final driveState = ref.watch(driveScoreNotifierProvider);
    final profileState = ref.watch(profileControllerProvider).value;

    final ecoScore = driveState.score;
    const distanceKm = 12.4;
    const fuelCostRm = 3.92;
    const carbonSavedKg = 1.2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti Particle Celebration Background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _celebrationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      animationValue: _celebrationController.value,
                    ),
                  );
                },
              ),
            ),

            // Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Trophy icon with glowing base
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.primary,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Celebration Title
                  Text(
                    'Earned +${rewardState.rewardPoints} Petrol Points!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trip Completed Successfully',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // fl_chart Double-Axis Chart Panel
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            const Text(
                              'Telematic Analysis',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _LegendDot(color: AppColors.primary, label: 'Speed (km/h)'),
                                const SizedBox(width: 12),
                                _LegendDot(color: AppColors.warning, label: 'Carbon (g/km)'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Double-axis Line Chart (fl_chart)
                        SizedBox(
                          height: 180,
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
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) {
                                      if (value % 20 != 0) return const SizedBox.shrink();
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
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() % 2 != 0) return const SizedBox.shrink();
                                      return Text(
                                        '${value.toInt()}m',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 10,
                              minY: 0,
                              maxY: 100,
                              lineBarsData: [
                                // Speed Line
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 30),
                                    FlSpot(2, 60),
                                    FlSpot(4, 75),
                                    FlSpot(6, 85),
                                    FlSpot(8, 70),
                                    FlSpot(10, 40),
                                  ],
                                  isCurved: true,
                                  color: AppColors.primary,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.primary.withOpacity(0.05),
                                  ),
                                ),
                                // Carbon emission rate line
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 15),
                                    FlSpot(2, 45),
                                    FlSpot(4, 52),
                                    FlSpot(6, 80),
                                    FlSpot(8, 30),
                                    FlSpot(10, 18),
                                  ],
                                  isCurved: true,
                                  color: AppColors.warning,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.warning.withOpacity(0.03),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Idle Savings Card (Bottom Detail)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gentle Driving Result',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Thanks to gentle driving, you avoided RM1.20 of unnecessary idling consumption.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mini Stats List
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'ECO SCORE', value: '$ecoScore'),
                        Container(width: 1.5, height: 30, color: AppColors.border),
                        const _StatItem(label: 'DIST', value: '12.4 km'),
                        Container(width: 1.5, height: 30, color: AppColors.border),
                        const _StatItem(label: 'CO2 SAVED', value: '1.2 kg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Claim points button with Shimmer Loader effect simulator
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _isLoadingClaim
                          ? null
                          : () async {
                              setState(() {
                                _isLoadingClaim = true;
                              });

                              // 1. Simulate 1s loading state ("AI cloud verification lag")
                              await Future.delayed(const Duration(milliseconds: 1000));

                              if (!mounted) return;

                              if (profileState != null) {
                                final finalPoints = profileState.petrolPointsBalance + rewardState.rewardPoints;
                                
                                await ref.read(profileControllerProvider.notifier).updateProfile(
                                      name: profileState.name,
                                      fuelType: profileState.fuelType,
                                      subsidyTier: profileState.subsidyTier,
                                      petrolPointsBalance: finalPoints,
                                    );

                                final record = TripRecord(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  userId: profileState.id,
                                  distanceKm: distanceKm,
                                  ecoScore: ecoScore,
                                  fuelCostRm: fuelCostRm,
                                  carbonSavedKg: carbonSavedKg,
                                  createdAt: DateTime.now(),
                                );
                                await ref.read(tripHistoryControllerProvider.notifier).saveTrip(record);
                              }

                              // 2. Navigate back
                              ref.read(appNavigationProvider.notifier).navigateTo(AppScreen.dashboard);
                            },
                      child: _isLoadingClaim
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Claim Rewards',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.animationValue});

  final List<_DashboardParticle> particles;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.15);

    for (final particle in particles) {
      // Animate coordinates upwards or downwards from emitter
      final double progress = animationValue;
      final double currentY = center.dy + (particle.y * progress) % size.height - 100;
      final double currentX = center.dx + particle.x * sin(progress * pi * particle.velocity);

      if (currentY > 0 && currentY < size.height) {
        final paint = Paint()
          ..color = particle.color.withOpacity(1.0 - (currentY / size.height).clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(currentX, currentY), particle.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
