# Module 1: User Profile & Subsidy Configuration

## Setup & Data Layer
- [ ] Add `flutter_riverpod` and `supabase_flutter` dependencies to `pubspec.yaml`.
- [ ] Initialize the Supabase project and create the `users` table (`id`, `name`, `fuel_type`, `subsidy_tier`, `total_eco_score`, `petrol_points_balance`).
- [ ] Create the `UserModel` Dart data class with `fromJson` and `toJson` methods.
- [ ] Create the abstract `ProfileRepository` interface.
- [ ] Implement `SupabaseProfileRepo` with methods to fetch and update user records.

## State Management (Riverpod)
- [ ] Create `MockProfileRepo` for PoC offline testing.
- [ ] Create `ProfileController` (`StateNotifier`) to hold and update the `UserModel` state.
- [ ] Create a Riverpod provider to inject the active `ProfileRepository` into the controller.

## Presentation Layer (UI)
- [ ] Build the `OnboardingScreen` widget.
- [ ] Add a dropdown for Fuel Type selection (RON95, RON97, Diesel).
- [ ] Add a dropdown/checkbox for Subsidy Tier selection (e.g., BUDI95).
- [ ] Bind the UI submit button to `ProfileController.updateUser()` and navigate to the Dashboard.