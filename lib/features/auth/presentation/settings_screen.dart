import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  String _selectedFuel = 'RON95';

  /// null  = not yet chosen / non-RON95 fuel
  /// true  = eligible for RON95 subsidy
  /// false = normal rate
  bool? _ron95SubsidyEligible;

  /// null  = not yet chosen / non-Diesel fuel
  /// true  = eligible for Diesel subsidy (rate of 2.15)
  /// false = normal rate (rate of 3.35)
  bool? _dieselSubsidyEligible;

  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onFuelChanged(String fuel) {
    setState(() {
      _selectedFuel = fuel;
      if (fuel != 'RON95') _ron95SubsidyEligible = null;
      if (fuel != 'Diesel') _dieselSubsidyEligible = null;
    });
  }

  String? get _computedSubsidyTier {
    if (_selectedFuel == 'RON95' && _ron95SubsidyEligible == true) return 'BUDI95';
    if (_selectedFuel == 'Diesel' && _dieselSubsidyEligible == true) return 'BUDIDIESEL';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    // Initial load — populate fields from current profile state
    profileState.whenData((profile) {
      if (!_isInit && profile != null) {
        _nameController.text = profile.name;
        _selectedFuel = profile.fuelType;
        // Restore eligibility choice from saved subsidyTier
        if (profile.fuelType == 'RON95') {
          _ron95SubsidyEligible =
              (profile.subsidyTier == 'BUDI95' || profile.subsidyTier == 'SUBSIDISED') ? true : false;
        } else if (profile.fuelType == 'Diesel') {
          _dieselSubsidyEligible =
              (profile.subsidyTier == 'BUDIDIESEL' || profile.subsidyTier == 'BUDI_DIESEL') ? true : false;
        }
        _isInit = true;
      }
    });

    final showSubsidyQuestion = _selectedFuel == 'RON95';

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
                // ── Settings Card ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Name
                      const Text(
                        'DRIVER NAME',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
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
                      const SizedBox(height: 24),

                      // Fuel Type
                      const Text(
                        'FUEL TYPE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['RON95', 'RON97', 'Diesel'].map((fuel) {
                          final isSelected = _selectedFuel == fuel;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _onFuelChanged(fuel),
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
                                  child: Text(
                                    fuel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColors.background
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // ── RON95 Subsidy Eligibility (conditional) ──────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: showSubsidyQuestion
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  const Text(
                                    'RON95 SUBSIDY ELIGIBILITY',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Are you eligible for the RON95 government subsidy?',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SubsidyChoiceCard(
                                          icon: Icons.check_circle_rounded,
                                          label: 'Yes, I\'m Eligible',
                                          sublabel: 'Subsidised rate',
                                          isSelected:
                                              _ron95SubsidyEligible == true,
                                          selectedColor: AppColors.primary,
                                          onTap: () => setState(() =>
                                              _ron95SubsidyEligible = true),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SubsidyChoiceCard(
                                          icon:
                                              Icons.monetization_on_rounded,
                                          label: 'Normal Rate',
                                          sublabel:
                                              'Proceed without subsidy',
                                          isSelected:
                                              _ron95SubsidyEligible == false,
                                          selectedColor: AppColors.warning,
                                          onTap: () => setState(() =>
                                              _ron95SubsidyEligible = false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      // ── Diesel Subsidy Eligibility (conditional) ──────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _selectedFuel == 'Diesel'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  const Text(
                                    'DIESEL SUBSIDY ELIGIBILITY',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Are you eligible for the Diesel government subsidy?',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SubsidyChoiceCard(
                                          icon: Icons.check_circle_rounded,
                                          label: 'Yes, I\'m Eligible',
                                          sublabel: 'Subsidised rate (RM2.15/L)',
                                          isSelected:
                                              _dieselSubsidyEligible == true,
                                          selectedColor: AppColors.primary,
                                          onTap: () => setState(() =>
                                              _dieselSubsidyEligible = true),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SubsidyChoiceCard(
                                          icon:
                                              Icons.monetization_on_rounded,
                                          label: 'Normal Rate',
                                          sublabel:
                                              'Proceed without subsidy (RM3.35/L)',
                                          isSelected:
                                              _dieselSubsidyEligible == false,
                                          selectedColor: AppColors.warning,
                                          onTap: () => setState(() =>
                                              _dieselSubsidyEligible = false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ── Save Button ────────────────────────────────────────────
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
                              subsidyTier: _computedSubsidyTier,
                              petrolPointsBalance: profile.petrolPointsBalance,
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
}
