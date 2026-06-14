import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../../rewards/models/loyalty_card.dart';
import '../../rewards/controllers/loyalty_card_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  String _selectedFuel = 'RON95';
  bool _hasBudiSubsidy = true;
  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final loyaltyCards = ref.watch(loyaltyCardProvider);

    profileState.whenData((profile) {
      if (!_isInit && profile != null) {
        _nameController.text = profile.name;
        _selectedFuel = profile.fuelType;
        _hasBudiSubsidy = profile.subsidyTier == 'BUDI95';
        _isInit = true;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: profileState.when(
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 44),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Fuel & Subsidy Profile ─────────────────────────────────
                _SectionCard(
                  title: 'Fuel & Subsidy Profile',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Driver Name',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: AppColors.border, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Fuel Type',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: ['RON95', 'RON97', 'Diesel'].map((fuel) {
                          final isSelected = _selectedFuel == fuel;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedFuel = fuel;
                                if (fuel != 'RON95') {
                                  _hasBudiSubsidy = false;
                                }
                              }),
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: fuel != 'Diesel' ? 8.0 : 0.0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(fuel,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.background
                                            : Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedFuel == 'RON95') ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.border, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Eligible for BUDI Madani?',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    SizedBox(height: 2),
                                    Text('BUDI Madani Subsidy',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _hasBudiSubsidy,
                                activeColor: AppColors.primary,
                                onChanged: (val) =>
                                    setState(() => _hasBudiSubsidy = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Linked Reward Cards ────────────────────────────────────
                _SectionCard(
                  title: 'Linked Reward Cards',
                  trailing: GestureDetector(
                    onTap: () => _showAddCardSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('Add Card',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  child: loyaltyCards.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No reward cards linked yet.\nTap "Add Card" to get started.',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        )
                      : Column(
                          children: loyaltyCards
                              .map((card) => _LinkedCardTile(card: card))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 32),

                // ── Save button ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (profile != null) {
                        await ref
                            .read(profileControllerProvider.notifier)
                            .updateProfile(
                              name: _nameController.text.trim().isEmpty
                                  ? 'Eco Driver'
                                  : _nameController.text.trim(),
                              fuelType: _selectedFuel,
                              subsidyTier:
                                  (_selectedFuel == 'RON95' && _hasBudiSubsidy) ? 'BUDI95' : null,
                              petrolPointsBalance:
                                  profile.petrolPointsBalance,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddCardSheet(
        onAdd: (card) =>
            ref.read(loyaltyCardProvider.notifier).addCard(card),
      ),
    );
  }
}

// ── Reusable section card ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Linked card tile ───────────────────────────────────────────────────────────

class _LinkedCardTile extends ConsumerWidget {
  const _LinkedCardTile({required this.card});
  final LoyaltyCard card;

  static ({Color color, String label}) _brand(String carrier) {
    final n = carrier.toLowerCase();
    if (n.contains('petronas')) {
      return (color: const Color(0xFF00B04F), label: 'PETRONAS\nMesra');
    } else if (n.contains('shell')) {
      return (color: const Color(0xFFFFCC00), label: 'Shell\nBonusLink');
    } else if (n.contains('caltex')) {
      return (color: const Color(0xFFE8132B), label: 'Caltex\nStarCard');
    }
    return (color: AppColors.primary, label: carrier);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = _brand(card.carrier);
    final isVerified = card.isVerified;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // ── The Physical Card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFF16182B), // Dark navy blue background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isVerified ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              boxShadow: isVerified
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Abstract geometric background lines (simulated)
                  Positioned(
                    right: -50,
                    bottom: -50,
                    child: Icon(
                      Icons.radar_rounded,
                      size: 250,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    top: -20,
                    child: Icon(
                      Icons.track_changes_rounded,
                      size: 150,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                  // Card Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo & Carrier Name
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_gas_station_rounded,
                                color: b.color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              b.label.replaceAll('\n', ' '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Large Brand Name
                        Text(
                          b.label.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Card Number
                        const Text(
                          'Card Number',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.cardNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Action buttons ───────────────────────────────────────────────
          Row(
            children: [
              // Edit button
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _showEditSheet(context, ref),
                ),
              ),
              const SizedBox(width: 10),
              // Remove button
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Remove',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ref
                        .read(loyaltyCardProvider.notifier)
                        .removeCard(card.cardNumber);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddCardSheet(
        initialCard: card,
        onAdd: (updated) {
          ref.read(loyaltyCardProvider.notifier).removeCard(card.cardNumber);
          ref.read(loyaltyCardProvider.notifier).addCard(updated);
        },
      ),
    );
  }
}

// ── Add / Edit card bottom sheet ───────────────────────────────────────────────

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet({required this.onAdd, this.initialCard});
  final void Function(LoyaltyCard) onAdd;
  final LoyaltyCard? initialCard;

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  static const _carriers = [
    'Petronas Mesra',
    'Shell BonusLink',
    'Caltex StarCard'
  ];
  late String _carrier;
  late TextEditingController _cardNumCtrl;

  @override
  void initState() {
    super.initState();
    _carrier = widget.initialCard?.carrier ?? _carriers.first;
    _cardNumCtrl =
        TextEditingController(text: widget.initialCard?.cardNumber ?? '');
  }

  @override
  void dispose() {
    _cardNumCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialCard != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(isEdit ? 'Edit Reward Card' : 'Link a Reward Card',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          const Text('Carrier',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _carrier,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: _carriers
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _carrier = v!),
          ),
          const SizedBox(height: 16),

          const Text('Card Number',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _cardNumCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. 6012 1234 5678 9012',
              hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final cardNum = _cardNumCtrl.text.trim();
                if (cardNum.isEmpty) return;
                widget.onAdd(LoyaltyCard(
                  carrier: _carrier,
                  cardNumber: cardNum,
                  status: 'verified',
                  pointsMultiplier:
                      _carrier.contains('Petronas') ? 1.5 : 1.2,
                ));
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Save Changes' : 'Link Card'),
            ),
          ),
        ],
      ),
    );
  }
}
