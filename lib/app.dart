import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/app_navigation_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/settings_screen.dart';
import 'features/navigation/presentation/navigation_screen.dart';
import 'features/rewards/presentation/rewards_screen.dart';
import 'features/trips/presentation/dashboard_screen.dart';
import 'features/trips/presentation/trip_summary_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/controllers/profile_controller.dart';
import 'features/auth/widgets/sign_in_page.dart';
import 'features/trips/controllers/trip_history_controller.dart';

class EcoHorizonApp extends ConsumerStatefulWidget {
  const EcoHorizonApp({super.key});

  @override
  ConsumerState<EcoHorizonApp> createState() => _EcoHorizonAppState();
}

class _EcoHorizonAppState extends ConsumerState<EcoHorizonApp> {
  @override
  Widget build(BuildContext context) {
    final authSession = ref.watch(authSessionProvider);

    ref.listen<AsyncValue<Session?>>(authSessionProvider, (previous, next) {
      final session = next.valueOrNull;
      if (session == null) {
        ref.read(profileControllerProvider.notifier).clearProfile();
        ref.read(tripHistoryControllerProvider.notifier).clearTrips();
        return;
      }

      ref.read(profileControllerProvider.notifier).loadProfile();
      ref
          .read(tripHistoryControllerProvider.notifier)
          .loadTrips(session.user.id);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoHorizon',
      theme: AppTheme.dark(),
      home: authSession.when(
        data: (session) {
          // TODO: Requires Supabase API key - Bypassing sign in for now
          return const MainRouterScreen();
          /*
          if (session == null) {
            return const SignInPage();
          }

          return const MainRouterScreen();
          */
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Scaffold(
          body: Center(child: Text('Auth error: $error')),
        ),
      ),
    );
  }
}

class MainRouterScreen extends ConsumerWidget {
  const MainRouterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScreen = ref.watch(appNavigationProvider);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: switch (activeScreen) {
          AppScreen.onboarding => const OnboardingScreen(key: ValueKey('onboarding')),
          AppScreen.activeDrive => const NavigationScreen(key: ValueKey('navigation_drive')),
          AppScreen.tripSummary => const TripSummaryScreen(key: ValueKey('trip_summary')),
          _ => const MainTabNavigator(key: ValueKey('main_tabs')),
        },
      ),
    );
  }
}

class MainTabNavigator extends ConsumerWidget {
  const MainTabNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(appTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: switch (activeTab) {
          AppTab.dashboard => 0,
          AppTab.map => 1,
          AppTab.rewards => 2,
          AppTab.settings => 3,
        },
        children: const [
          DashboardScreen(),
          NavigationScreen(),
          RewardsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isSelected: activeTab == AppTab.dashboard,
                onTap: () {
                  ref.read(appTabProvider.notifier).setTab(AppTab.dashboard);
                  ref.read(appNavigationProvider.notifier).navigateTo(AppScreen.dashboard);
                },
              ),
              _NavBarItem(
                icon: Icons.map_rounded,
                label: 'Map',
                isSelected: activeTab == AppTab.map,
                onTap: () {
                  ref.read(appTabProvider.notifier).setTab(AppTab.map);
                  ref.read(appNavigationProvider.notifier).navigateTo(AppScreen.routeComparison);
                },
              ),
              _NavBarItem(
                icon: Icons.emoji_events_rounded,
                label: 'Rewards',
                isSelected: activeTab == AppTab.rewards,
                onTap: () {
                  ref.read(appTabProvider.notifier).setTab(AppTab.rewards);
                },
              ),
              _NavBarItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: activeTab == AppTab.settings,
                onTap: () {
                  ref.read(appTabProvider.notifier).setTab(AppTab.settings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
