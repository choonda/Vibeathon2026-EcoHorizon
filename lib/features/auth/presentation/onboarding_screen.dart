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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController(text: 'Eco Driver');
  String _selectedFuel = 'RON95';
  bool _hasBudiSubsidy = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Top Logo & Slogan
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

              // Form Card (Glassmorphic look)
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
                    // Driver Name Input
                    const Text(
                      'Driver Name',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fuel Type Choice Chips
                    const Text(
                      'Fuel Type',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: ['RON95', 'RON97', 'Diesel'].map((fuel) {
                        final isSelected = _selectedFuel == fuel;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFuel = fuel),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: fuel != 'Diesel' ? 8.0 : 0.0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  fuel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.background : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // BUDI Madani Toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Eligible for BUDI Madani?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'BUDI Madani Subsidy',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _hasBudiSubsidy,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _hasBudiSubsidy = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Start Engine Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    elevation: 8,
                  ),
                  onPressed: () async {
                    // Update profile state
                    await ref.read(profileControllerProvider.notifier).updateProfile(
                          name: _nameController.text.trim().isEmpty
                              ? 'Eco Driver'
                              : _nameController.text.trim(),
                          fuelType: _selectedFuel,
                          subsidyTier: _hasBudiSubsidy ? 'BUDI95' : null,
                        );

                    // Navigate to Dashboard
                    ref.read(appNavigationProvider.notifier).navigateTo(AppScreen.dashboard);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Start Engine',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
