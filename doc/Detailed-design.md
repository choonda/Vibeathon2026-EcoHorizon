# Detailed Design Document: EcoHorizon

## 1. System Architecture Overview
EcoHorizon utilizes a clean architecture approach to ensure high modularity, rapid scalability, and independent testability for the 2-day hackathon timeline. 
*   **Presentation Layer:** Flutter UI components and widgets.
*   **State Management Layer:** Riverpod (Providers and StateNotifiers) handling all core business logic and state transformations.
*   **Data Layer (Repository Pattern):** Abstract classes defining data operations, allowing seamless swapping between live APIs (Google Maps), Backend services (Supabase), and mocked PoC data.

## 2. Core Architectural Patterns
*   **Riverpod State Management:** Selected for compile-time safety and deep decoupling of business logic from the UI tree. This allows individual controllers to be unit-tested without rendering widgets.
*   **Repository Pattern:** Every feature module interacts with its data strictly through a repository interface (e.g., `IRouteRepository`). The UI remains completely agnostic of the data's origin.

---

## 3. Module Breakdown & Detailed Design

### Module 1: User Profile & Subsidy Configuration
*   **Objective:** Manage the user's vehicle fuel type, applicable subsidy tier, and persistent gamification points balance.
*   **Components:**
    *   `ProfileRepository`: Abstract interface for user database interactions.
    *   `SupabaseProfileRepo`: Concrete implementation interacting directly with the Supabase `users` table.
    *   `ProfileController`: A Riverpod `StateNotifier` that fetches and holds the current user state (`fuel_type`, `points_balance`).
*   **Testability:** `ProfileController` can be tested independently by injecting a `MockProfileRepo` that returns a predefined user object.

### Module 2: APM Smart Refuel Engine
*   **Objective:** Predict fuel price hikes and trigger actionable pre-trip push alerts based on the user's virtual tank status.
*   **Components:**
    *   `ApmRepository`: Abstract interface for fetching APM pricing predictions.
    *   `MockApmRepo`: Concrete implementation returning hardcoded prediction thresholds (e.g., +RM0.08 on Thursday) to guarantee a flawless PoC demonstration.
    *   `ApmAlertController`: Evaluates the current device local time and virtual tank capacity against data from the `ApmRepository` to trigger modal pop-ups.
*   **Testability:** Inject custom `DateTime` objects into the `ApmAlertController` to programmatically verify if the notification triggers correctly on a simulated "Wednesday evening".

### Module 3: Cost-Aware Eco-Routing
*   **Objective:** Fetch accurate navigation routes and calculate estimated fuel costs (RM) and carbon emissions (kg) utilizing user profile data.
*   **Components:**
    *   `RouteRepository`: Abstract interface for fetching polyline and route metrics.
    *   `GoogleMapsRouteRepo`: Calls the live **Google Maps Directions API** to retrieve actual distance (km) and estimated traffic time.
    *   `EcoCostCalculator`: A pure utility function that processes distance, time, and `fuel_type` to output precise Ringgit (RM) costs and Carbon (kg) estimates.
    *   `MapController`: Manages the state of the drawn polylines on the Flutter `GoogleMap` widget and stores the calculated costs for comparative display (Route A vs. Route B).
*   **Testability:** The `EcoCostCalculator` can be fully unit-tested with various extreme inputs (distance/time) to ensure the mathematical formulas for fuel consumption never crash.

### Module 4: Telematics & Gamification (The "Green Right Foot")
*   **Objective:** Monitor real-time driving stability using native device sensors to calculate a dynamic Eco Score.
*   **Components:**
    *   `SensorRepository`: Listens to `sensors_plus` streams (accelerometer/gyroscope).
    *   `DriveScoringEngine`: A Riverpod controller that subscribes to the `SensorRepository`. 
    *   **Scoring Algorithm (Deductive System):**
        *   Trip initialization sets the state to **100 Points**.
        *   Listen for instantaneous acceleration (G-force).
        *   If the absolute acceleration exceeds $0.3g$ (threshold for harsh braking/acceleration), deduct exactly 5 points and trigger a UI warning flag.
        *   The hard floor limit for the score is 0 points.
*   **Testability:** Feed a mock stream of double values (representing random G-force spikes) into the `DriveScoringEngine` and assert that the score decrements accurately per the defined thresholds.

### Module 5: Post-Trip Dashboard & Carbon Ledger
*   **Objective:** Compile final trip data, push it to Supabase, and translate abstract metrics into gamified, concrete environmental impacts.
*   **Components:**
    *   `TripRepository`: Abstract interface for logging completed trips.
    *   `SupabaseTripRepo`: Pushes the final JSON payload (distance, cost, eco_score, carbon_saved) directly to the Supabase `trips` table.
    *   `LedgerController`: Listens for a successful trip completion status, triggers the update of the user's total points, and maps the saved carbon (kg) to concrete visual strings (e.g., "1 Tree Planted").
*   **Testability:** Verify that the `LedgerController` correctly translates varying amounts of $CO_2$ (e.g., 15kg) into the exact defined strings without requiring a UI render or an active database connection.

---

## 4. Supabase Database Schema Implementation
To support the live data layer during the pitch, the following schema will be initialized in PostgreSQL via Supabase:

*   **Table: `users`**
    *   `id` (UUID, Primary Key)
    *   `name` (String)
    *   `fuel_type` (String, e.g., 'RON95', 'RON97', 'Diesel')
    *   `subsidy_tier` (String, nullable, e.g., 'BUDI95')
    *   `total_eco_score` (Integer, default 0)
    *   `petrol_points_balance` (Integer, default 0)

*   **Table: `trips`**
    *   `id` (UUID, Primary Key)
    *   `user_id` (UUID, Foreign Key -> `users.id`)
    *   `distance_km` (Float)
    *   `eco_score` (Integer)
    *   `fuel_cost_rm` (Float)
    *   `carbon_saved_kg` (Float)
    *   `created_at` (Timestamp, default now())