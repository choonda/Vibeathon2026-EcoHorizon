import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/profile_controller.dart';
import '../models/reward_item.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  static const List<RewardItem> demoRewards = [
    RewardItem(title: 'Petronas RM10 Petrol Voucher', points: 100),
    RewardItem(title: 'Shell RM20 Fuel Voucher', points: 180),
    RewardItem(title: 'Petronas RM30 Petrol Voucher', points: 260),
    RewardItem(title: 'Caltex RM50 Fuel Voucher', points: 400),
    RewardItem(title: 'EcoHorizon Green Driver T-Shirt', points: 500),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Petrol Rewards Store', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: profileState.when(
          data: (profile) {
            final points = profile?.petrolPointsBalance ?? 0;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Points balance banner
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF00E5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVAILABLE BALANCE',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'My Petrol Points',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$points pts',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Claim Vouchers & Merchandises',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rewards list
                  Expanded(
                    child: ListView.builder(
                      itemCount: demoRewards.length,
                      itemBuilder: (context, index) {
                        final item = demoRewards[index];
                        final canClaim = points >= item.points;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.confirmation_num_rounded, color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Requires ${item.points} points',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canClaim ? AppColors.primary : AppColors.secondary,
                                  foregroundColor: canClaim ? AppColors.background : AppColors.textSecondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                onPressed: canClaim
                                    ? () async {
                                        // Deduct points
                                        final newPoints = points - item.points;
                                        await ref
                                            .read(profileControllerProvider.notifier)
                                            .updateProfile(
                                              name: profile?.name ?? 'Eco Driver',
                                              fuelType: profile?.fuelType ?? 'RON95',
                                              subsidyTier: profile?.subsidyTier,
                                              petrolPointsBalance: newPoints,
                                            );
                                        
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Successfully claimed ${item.title}!'),
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text(canClaim ? 'CLAIM' : 'LOCKED'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
