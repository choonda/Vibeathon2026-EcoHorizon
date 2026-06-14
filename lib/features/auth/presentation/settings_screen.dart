import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

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

    // Initial load
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
        title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: profileState.when(
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glassmorphic settings container
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

                      // Fuel Type Chips
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
                                  const Text(
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
                const SizedBox(height: 40),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (profile != null) {
                        await ref.read(profileControllerProvider.notifier).updateProfile(
                              name: _nameController.text.trim().isEmpty ? 'Eco Driver' : _nameController.text.trim(),
                              fuelType: _selectedFuel,
                              subsidyTier: _hasBudiSubsidy ? 'BUDI95' : null,
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
