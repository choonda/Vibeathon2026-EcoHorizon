import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/loyalty_card_notifier.dart';
import '../models/loyalty_card.dart';

/// Displays the user's linked fuel loyalty cards as a scrollable list.
class LoyaltyCardList extends ConsumerWidget {
  const LoyaltyCardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(loyaltyCardProvider);

    if (cards.isEmpty) {
      return const Center(
        child: Text(
          'No linked loyalty cards.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, index) => _LoyaltyCardTile(card: cards[index]),
    );
  }
}

// ── Carrier brand config ───────────────────────────────────────────────────────

class _CarrierStyle {
  const _CarrierStyle({
    required this.icon,
    required this.color,
    required this.bgColor,
  });
  final IconData icon;
  final Color color;
  final Color bgColor;
}

_CarrierStyle _carrierStyle(String carrier) {
  final name = carrier.toLowerCase();
  if (name.contains('petronas')) {
    return _CarrierStyle(
      icon: Icons.local_gas_station_rounded,
      color: const Color(0xFF00B04F), // Petronas green
      bgColor: const Color(0xFF00B04F).withOpacity(0.12),
    );
  } else if (name.contains('shell')) {
    return _CarrierStyle(
      icon: Icons.local_gas_station_rounded,
      color: const Color(0xFFFFCC00), // Shell yellow
      bgColor: const Color(0xFFFFCC00).withOpacity(0.12),
    );
  } else if (name.contains('caltex') || name.contains('chevron')) {
    return _CarrierStyle(
      icon: Icons.local_gas_station_rounded,
      color: const Color(0xFFE8132B), // Caltex red
      bgColor: const Color(0xFFE8132B).withOpacity(0.12),
    );
  }
  return _CarrierStyle(
    icon: Icons.credit_card_rounded,
    color: AppColors.textSecondary,
    bgColor: AppColors.textSecondary.withOpacity(0.1),
  );
}

// ── Card tile ──────────────────────────────────────────────────────────────────

class _LoyaltyCardTile extends StatelessWidget {
  const _LoyaltyCardTile({required this.card});

  final LoyaltyCard card;

  @override
  Widget build(BuildContext context) {
    final isVerified = card.isVerified;
    final brand = _carrierStyle(card.carrier);

    // Locked cards get visual degradation
    Widget tile = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        // Verified: glowing gradient border via two nested containers
        gradient: isVerified
            ? const LinearGradient(
                colors: [Color(0xFF00E5A0), Color(0xFF00B04F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: isVerified
            ? null
            : Border.all(color: AppColors.border, width: 1.5),
        boxShadow: isVerified
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(isVerified ? 1.5 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(isVerified ? 18.5 : 20),
        ),
        child: Row(
          children: [
            // ── Carrier brand logo ─────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: brand.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(brand.icon, color: brand.color, size: 24),
            ),
            const SizedBox(width: 16),

            // ── Card details ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.carrier,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isVerified ? Colors.white : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.cardNumber,
                    style: TextStyle(
                      color: isVerified
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${card.pointsMultiplier}× points multiplier',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isVerified ? brand.color : AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // ── Status badge + action ──────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(
                  label: isVerified ? 'Verified' : 'Locked',
                  backgroundColor: isVerified
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.textSecondary.withOpacity(0.08),
                  textColor: isVerified ? AppColors.primary : AppColors.textSecondary,
                  icon: isVerified ? Icons.verified_rounded : Icons.lock_outline_rounded,
                ),
                if (isVerified) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_gas_station_rounded,
                            size: 12, color: brand.color),
                        const SizedBox(width: 3),
                        Text(
                          'Go Refuel',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: brand.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    // Apply grayscale + opacity for locked cards
    if (!isVerified) {
      tile = Opacity(
        opacity: 0.5,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: tile,
        ),
      );
    }

    return tile;
  }
}

// ── Status badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
