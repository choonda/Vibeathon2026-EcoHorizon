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

  void navigateTo(AppScreen screen) {
    state = screen;
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
