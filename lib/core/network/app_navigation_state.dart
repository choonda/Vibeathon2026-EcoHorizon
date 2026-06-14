import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen {
  onboarding,
  dashboard,
  routeComparison,
  activeDrive,
  tripSummary,
}

class AppNavigationNotifier extends StateNotifier<AppScreen> {
  AppNavigationNotifier() : super(AppScreen.onboarding);

  /// Whether the user has already completed the onboarding flow at least once
  /// during this app session. Used to skip onboarding on subsequent navigations.
  bool hasCompletedOnboarding = false;

  void navigateTo(AppScreen screen) {
    state = screen;
  }

  /// Marks onboarding as complete and navigates to [AppScreen.dashboard].
  void completeOnboarding() {
    hasCompletedOnboarding = true;
    state = AppScreen.dashboard;
  }

  /// Returns to dashboard, skipping onboarding if it has already been completed.
  void navigateHome() {
    if (hasCompletedOnboarding) {
      state = AppScreen.dashboard;
    } else {
      state = AppScreen.onboarding;
    }
  }
}

final appNavigationProvider =
    StateNotifierProvider<AppNavigationNotifier, AppScreen>((ref) {
  return AppNavigationNotifier();
});

enum AppTab {
  dashboard,
  map,
  rewards,
  settings,
}

class AppTabNotifier extends StateNotifier<AppTab> {
  AppTabNotifier() : super(AppTab.dashboard);

  void setTab(AppTab tab) {
    state = tab;
  }
}

final appTabProvider = StateNotifierProvider<AppTabNotifier, AppTab>((ref) {
  return AppTabNotifier();
});
