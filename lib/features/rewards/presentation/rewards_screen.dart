import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/profile_controller.dart';
import '../models/reward_item.dart';
import '../widgets/loyalty_card_list.dart';

// ── Filter tab state ───────────────────────────────────────────────────────────

final _filterProvider = StateProvider<String>((ref) => 'All');

// ── Main screen ────────────────────────────────────────────────────────────────

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  static const List<RewardItem> demoRewards = [
    RewardItem(title: 'Petronas RM10 Petrol Voucher', points: 100),
    RewardItem(title: 'Shell RM20 Fuel Voucher', points: 180),
    RewardItem(title: 'Petronas RM30 Petrol Voucher', points: 260),
    RewardItem(title: 'Caltex RM50 Fuel Voucher', points: 400),
    RewardItem(title: 'EcoHorizon Green Driver T-Shirt', points: 500),
  ];

  static const List<String> _filters = ['All', 'Petronas', 'Shell', 'Caltex'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final activeFilter = ref.watch(_filterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Petrol Rewards Store',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: profileState.when(
          data: (profile) {
            final points = profile?.petrolPointsBalance ?? 0;

            // Filter vouchers based on selected tab
            final filtered = activeFilter == 'All'
                ? demoRewards
                : demoRewards
                    .where((r) =>
                        r.title.toLowerCase().contains(activeFilter.toLowerCase()))
                    .toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Points balance banner with count-up + earnings CTA ──
                      _PointsBanner(points: points),
                      const SizedBox(height: 28),

                      // ── Loyalty Cards ──────────────────────────────────────
                      const Text(
                        'My Loyalty Cards',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const LoyaltyCardList(),
                      const SizedBox(height: 28),

                      // ── Filter bar ─────────────────────────────────────────
                      const Text(
                        'Claim Vouchers & Merchandises',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FilterBar(filters: _filters, active: activeFilter),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),

                // ── Voucher list with progress bars ────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filtered[index];
                        final canClaim = points >= item.points;
                        final progress = (points / item.points).clamp(0.0, 1.0);
                        final remaining = (item.points - points).clamp(0, item.points);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: canClaim
                                  ? AppColors.primary.withOpacity(0.3)
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.confirmation_num_rounded,
                                        color: AppColors.primary,
                                        size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          canClaim
                                              ? 'Ready to claim!'
                                              : 'Need $remaining more pts',
                                          style: TextStyle(
                                            color: canClaim
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: canClaim
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canClaim
                                          ? AppColors.primary
                                          : AppColors.secondary,
                                      foregroundColor: canClaim
                                          ? AppColors.background
                                          : AppColors.textSecondary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: canClaim
                                        ? () async {
                                            final newPoints =
                                                points - item.points;
                                            await ref
                                                .read(profileControllerProvider
                                                    .notifier)
                                                .updateProfile(
                                                  name: profile?.name ??
                                                      'Eco Driver',
                                                  fuelType:
                                                      profile?.fuelType ??
                                                          'RON95',
                                                  subsidyTier:
                                                      profile?.subsidyTier,
                                                  petrolPointsBalance:
                                                      newPoints,
                                                );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Claimed ${item.title}! 🎉'),
                                                backgroundColor:
                                                    AppColors.primary,
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Text(canClaim ? 'CLAIM' : 'LOCKED'),
                                  ),
                                ],
                              ),

                              // ── Progress bar ───────────────────────────────
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 5,
                                  backgroundColor:
                                      AppColors.border.withOpacity(0.4),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    canClaim
                                        ? AppColors.primary
                                        : AppColors.primary.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$points / ${item.points} pts',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: canClaim
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

// ── Points banner with count-up animation + earnings CTA ──────────────────────

class _PointsBanner extends StatefulWidget {
  const _PointsBanner({required this.points});
  final int points;

  @override
  State<_PointsBanner> createState() => _PointsBannerState();
}

class _PointsBannerState extends State<_PointsBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _countAnim;
  bool _showEarnings = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _countAnim = IntTween(begin: 0, end: widget.points).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_PointsBanner old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      _countAnim = IntTween(begin: old.points, end: widget.points)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AVAILABLE BALANCE',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'My Petrol Points',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Earnings detail CTA
                  GestureDetector(
                    onTap: () => setState(() => _showEarnings = !_showEarnings),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded,
                            size: 13, color: Colors.black54),
                        const SizedBox(width: 3),
                        Text(
                          _showEarnings
                              ? 'Hide earnings'
                              : 'View today\'s earnings',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Count-up animation
              AnimatedBuilder(
                animation: _countAnim,
                builder: (_, __) => Text(
                  '${_countAnim.value} pts',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Collapsible earnings breakdown ─────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showEarnings
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: _EarningsPanel(),
        ),
      ],
    );
  }
}

// ── Earnings breakdown panel ───────────────────────────────────────────────────

class _EarningsPanel extends StatelessWidget {
  const _EarningsPanel();

  static const _items = [
    ('🛣️ Eco Route Taken', '+12 pts'),
    ('🌿 Smooth Driving Bonus', '+8 pts'),
    ('⛽ Petronas Mesra 1.5× Multiplier', '+3 pts'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Eco Earnings",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ..._items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.$1,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    Text(e.$2,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        )),
                  ],
                ),
              )),
          const Divider(color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Total Today',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('+23 pts',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ─────────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filters, required this.active});

  final List<String> filters;
  final String active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = filters[index];
          final isActive = label == active;
          return GestureDetector(
            onTap: () =>
                ref.read(_filterProvider.notifier).state = label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? AppColors.background
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
