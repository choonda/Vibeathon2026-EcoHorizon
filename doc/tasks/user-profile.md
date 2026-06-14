# Module 1: User Profile & Subsidy Configuration

## Setup & Data Layer
- [x] Add `flutter_riverpod` and `supabase_flutter` dependencies to `pubspec.yaml`.
- [x] Initialize the Supabase project and create the `users` table (`id`, `name`, `fuel_type`, `subsidy_tier`, `total_eco_score`, `petrol_points_balance`).
- [x] Create the `UserModel` Dart data class with `fromJson` and `toJson` methods.
- [x] Create the abstract `ProfileRepository` interface.
- [x] Implement `SupabaseProfileRepo` with methods to fetch and update user records.

## State Management (Riverpod)
- [x] Create `MockProfileRepo` for PoC offline testing.
- [x] Create `ProfileController` (`StateNotifier`) to hold and update the `UserModel` state.
- [x] Create a Riverpod provider to inject the active `ProfileRepository` into the controller.

## Presentation Layer (UI)
- [x] Build the `OnboardingScreen` widget.
- [x] Add a dropdown for Fuel Type selection (RON95, RON97, Diesel).
- [x] Add a dropdown/checkbox for Subsidy Tier selection (e.g., BUDI95).
- [x] Bind the UI submit button to `ProfileController.updateUser()` and navigate to the Dashboard.