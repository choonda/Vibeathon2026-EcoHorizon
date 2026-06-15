import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_navigation_state.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController(text: 'Eco Driver');
  String _selectedFuel = 'RON95';

  /// null  = not yet answered (only visible when RON95 is selected)
  /// true  = eligible for RON95 subsidy
  /// false = normal rate
  bool? _ron95SubsidyEligible;

  /// null  = not yet answered (only visible when Diesel is selected)
  /// true  = eligible for Diesel subsidy
  /// false = normal rate
  bool? _dieselSubsidyEligible;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onFuelChanged(String fuel) {
    setState(() {
      _selectedFuel = fuel;
      // Reset the eligibility choice when switching fuel types
      if (fuel != 'RON95') _ron95SubsidyEligible = null;
      if (fuel != 'Diesel') _dieselSubsidyEligible = null;
    });
  }

  /// Derive the subsidyTier value to store:
  /// - null  → RON97 / Diesel / user chose normal rate
  /// - 'BUDI95' → eligible for RON95 subsidy
  /// - 'BUDIDIESEL' → eligible for Diesel subsidy
  String? get _computedSubsidyTier {
    if (_selectedFuel == 'RON95' && _ron95SubsidyEligible == true) return 'BUDI95';
    if (_selectedFuel == 'Diesel' && _dieselSubsidyEligible == true) return 'BUDIDIESEL';
    return null; // normal rate
  }

  Future<void> _submit() async {
    await ref.read(profileControllerProvider.notifier).updateProfile(
          name: _nameController.text.trim().isEmpty
              ? 'Eco Driver'
              : _nameController.text.trim(),
          fuelType: _selectedFuel,
          subsidyTier: _computedSubsidyTier,
        );

    // Mark onboarding complete so re-navigation skips this screen
    ref.read(appNavigationProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final showSubsidyQuestion = _selectedFuel == 'RON95';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // ── Logo & Slogan ──────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: AppColors.primary,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'EcoHorizon',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              letterSpacing: -1.5,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Drive Smart. Save More.',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // ── Form Card ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Name
                      const _SectionLabel('Driver Name'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          hintText: 'Your name',
                          hintStyle:
                              const TextStyle(color: AppColors.textSecondary),
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
                      const _SectionLabel('Fuel Type'),
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
                                  const _SectionLabel(
                                      'RON95 Subsidy Eligibility'),
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
                                      // ── Yes — Eligible ──────────────────
                                      Expanded(
                                        child: SubsidyChoiceCard(
                                          icon: Icons.check_circle_rounded,
                                          label: 'Yes, I\'m Eligible',
                                          sublabel: 'Subsidised rate (RM1.99/L)',
                                          isSelected:
                                              _ron95SubsidyEligible == true,
                                          selectedColor: AppColors.primary,
                                          onTap: () => setState(
                                              () => _ron95SubsidyEligible =
                                                  true),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // ── No — Normal Rate ────────────────
                                      Expanded(
                                        child: SubsidyChoiceCard(
                                          icon: Icons.monetization_on_rounded,
                                          label: 'Normal Rate',
                                          sublabel: 'Proceed without subsidy (RM3.72/L)',
                                          isSelected:
                                              _ron95SubsidyEligible == false,
                                          selectedColor: AppColors.warning,
                                          onTap: () => setState(
                                              () => _ron95SubsidyEligible =
                                                  false),
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
                                  const _SectionLabel(
                                      'Diesel Subsidy Eligibility'),
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
                                          onTap: () => setState(
                                              () => _dieselSubsidyEligible =
                                                  true),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SubsidyChoiceCard(
                                          icon: Icons.monetization_on_rounded,
                                          label: 'Normal Rate',
                                          sublabel: 'Proceed without subsidy (RM4.67/L)',
                                          isSelected:
                                              _dieselSubsidyEligible == false,
                                          selectedColor: AppColors.warning,
                                          onTap: () => setState(
                                              () => _dieselSubsidyEligible =
                                                  false),
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
                const SizedBox(height: 48),

                // ── Start Engine Button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      elevation: 8,
                    ),
                    onPressed: _submit,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Start Engine',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable sub-widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// A selectable card for the two-column subsidy eligibility choice.
class SubsidyChoiceCard extends StatelessWidget {
  const SubsidyChoiceCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.12)
              : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox-style indicator at top
            Align(
              alignment: Alignment.topRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Icon(Icons.check_box_rounded,
                        key: const ValueKey(true),
                        color: selectedColor,
                        size: 20)
                    : Icon(Icons.check_box_outline_blank_rounded,
                        key: const ValueKey(false),
                        color: AppColors.textSecondary,
                        size: 20),
              ),
            ),
            const SizedBox(height: 8),
            Icon(icon,
                color: isSelected ? selectedColor : AppColors.textSecondary,
                size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? selectedColor.withOpacity(0.8)
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
