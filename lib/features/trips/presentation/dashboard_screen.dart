import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_navigation_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../apm/controllers/apm_alert_controller.dart';
import '../../auth/controllers/profile_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final apmState = ref.watch(apmAlertControllerProvider);

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

          // 2. Upper Glassmorphic Panel
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Column(
                children: [
                  // Profile Row (Small, elegant top bar)
                  profileState.when(
                    data: (profile) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.name ?? 'Eco Driver',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                ),
                                Text(
                                  '${profile?.fuelType ?? 'RON95'} | ${profile?.subsidyTier == 'BUDI95' ? 'BUDI MADANI' : 'Standard'}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 1.0),
                          ),
                          child: Text(
                            '🪙 ${profile?.petrolPointsBalance ?? 0} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

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
                          children: [
                            // Month Savings Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Month Saved',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'RM 45.20',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
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
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(color: Colors.white10, height: 1.0),
                            ),
                            // Carbon Saved Section
                            Row(
                              children: [
                                const Icon(Icons.park_rounded, color: AppColors.primary, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                                      children: [
                                        TextSpan(text: 'Total Carbon Saved: '),
                                        TextSpan(
                                          text: '12.5 kg',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                        TextSpan(
                                          text: '\n(Equivalent to planting 1 tree 🌳)',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Sheet Drawer (Search Bar)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  ref.read(appNavigationProvider.notifier).navigateTo(AppScreen.routeComparison);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Where to?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
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
