# EcoHorizon Implementation Plan

## 1. Background & Motivation
EcoHorizon is an active, eco-conscious navigation ecosystem designed for the VIBEATHON 2026 challenge. The application aims to transition Malaysian drivers from passive fuel consumers to active participants in sustainable mobility. The solution provides real-time navigation, Automatic Pricing Mechanism (APM) forecasting, smartphone sensor-based telematics, and a gamified reward loop, without requiring external OBD-II hardware.

## 2. Scope & Impact
The scope of this implementation covers a 48-hour hackathon timeframe to build a high-fidelity Proof of Concept (PoC) using Flutter for the mobile app and Supabase for the backend. 
Key features include:
*   User Profile & Subsidy Configuration
*   APM Smart Refuel Engine (Mocked Scenario)
*   Cost-Aware Eco-Routing (Google Maps API + Mock Formulas)
*   Telematics & Gamification (Accelerometer/Gyroscope)
*   Post-Trip Dashboard & Carbon Ledger

## 3. Proposed Solution Architecture
*   **Framework:** Flutter (Dart)
*   **State Management:** Riverpod
*   **Architecture Pattern:** Clean Architecture (Presentation, State/Domain, Data layers)
*   **Backend:** Supabase (Users and Trips tables)

### 3.1. Directory Structure (Proposed)
```text
lib/
├── core/
│   ├── theme/
│   ├── utils/
│   └── constants/
├── data/
│   ├── models/
│   ├── repositories/
│   └── mock_data/
├── domain/
│   ├── entities/
│   └── providers/
├── presentation/
│   ├── widgets/
│   └── screens/
│       ├── onboarding/
│       ├── map/
│       └── dashboard/
└── main.dart
```

## 4. Implementation Plan & Workload Distribution (3-Member Team)

To maximize efficiency during the 48-hour hackathon, tasks will be divided among the 3 team members to enable parallel development.

### Phase 1: Foundation & Scaffold (Day 1 - Morning)
*   **Member 1 (Lead/Architecture):** Run `flutter create eco_horizon`. Scaffold the Clean Architecture directories (core, data, domain, presentation). Setup `flutter_riverpod` and `supabase_flutter` dependencies.
*   **Member 2 (Frontend UI):** Set up base theme and constants in the `core` folder. Begin scaffolding the empty shell screens (Onboarding, Map, Dashboard).
*   **Member 3 (Backend/Data):** Initialize the Supabase project online. Create the SQL tables (`users`, `trips`) as defined in the schema and configure the dummy connection keys in the Flutter app.

### Phase 2: User Profile & Mock APM Engine (Day 1 - Afternoon)
*   **Member 1 (Architecture):** Implement the Riverpod state management for User Profile. Create the `MockApmRepo` with the hardcoded Wednesday price hike scenario.
*   **Member 2 (Frontend UI):** Build the interactive Onboarding/Profile screen UI. Create the UI slider for the "Virtual Tank" to test APM push alerts manually.
*   **Member 3 (Backend/Data):** Connect the User Profile state to the Supabase backend (saving/fetching user preferences and subsidy tiers).

### Phase 3: Telematics & Gamification Logic (Day 2 - Morning)
*   **Member 1 (Architecture):** Build the `DriveScoringEngine` deduction algorithm (start at 100, deduct 5 for > 0.3g). Create a mock sensor stream for testing.
*   **Member 2 (Frontend UI):** Build the live drive UI showing the real-time Eco Score, visual warnings for harsh braking, and the mock sensor data visualization.
*   **Member 3 (Backend/Data):** Implement `SensorRepository` listening to `sensors_plus`. Connect the live sensor data stream to Member 1's Scoring Engine.

### Phase 4: Map Integration & Eco-Routing (Day 2 - Afternoon)
*   **Member 1 (Architecture):** Implement the `EcoCostCalculator` math formulas for calculating RM costs and Carbon emissions baselines.
*   **Member 2 (Frontend UI):** Implement the `GoogleMap` widget and UI for selecting routes. Handle the display of cost-aware route alternatives.
*   **Member 3 (Backend/Data):** Set up `GoogleMapsRouteRepo` to fetch live routes (or implement the hardcoded polyline fallback if API keys are delayed).

### Phase 5: Dashboard & Final Integration (Day 2 - Evening/Night)
*   **Member 1 (Architecture):** Ensure all Riverpod providers are communicating correctly. Finalize the Pitch Demo flow ("Hardcoded Storytelling").
*   **Member 2 (Frontend UI):** Build the post-trip summary dashboard utilizing `fl_chart` to display the dual-axis graphs (speed vs. emissions).
*   **Member 3 (Backend/Data):** Implement the `SupabaseTripRepo` to push the final compiled trip data (distance, cost, score, carbon) to the database upon trip completion.

## 5. Verification & Testing
*   **Unit Tests:** Focus on the `EcoCostCalculator` and `DriveScoringEngine` (Riverpod StateNotifiers) to ensure math and point deductions are accurate without UI.
*   **Manual Testing:** The "Virtual Tank" slider will verify APM alerts. Mock sensor data will verify the "Green Right Foot" gamification before actual physical driving tests.

## 6. Risk Mitigation
*   **Missing API Keys:** If Google Maps API keys are delayed, we will fall back to hardcoded polylines and distance values for the pitch demo.
*   **Sensor Noise:** Smartphone sensors can be noisy. The 0.3g threshold may need adjustment during testing to prevent false positives.
