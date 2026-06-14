# Project Proposal: EcoHorizon

## 1. Executive Summary
**EcoHorizon** is an active, eco-conscious navigation ecosystem designed for the VIBEATHON 2026 challenge. It transitions drivers from passive fuel consumers to active participants in sustainable mobility. By combining real-time navigation, Automatic Pricing Mechanism (APM) forecasting, smartphone sensor-based telematics, and a gamified reward loop, EcoHorizon empowers Malaysian drivers to minimize fuel costs, optimize refuelling strategies, and tangibly reduce their carbon footprint without requiring external OBD-II hardware.

---

## 2. Problem Statement
The transportation sector is a major contributor to Malaysia's carbon emissions, yet individual drivers lack the tools to manage their environmental and financial impact efficiently. This stems from four key challenges:
1.  **Limited APM Strategy:** Drivers lack proactive awareness of the weekly Automatic Pricing Mechanism (APM) revisions, often missing critical windows to refuel before fuel price hikes.
2.  **Fragmented Route Planning:** Standard navigation systems prioritize time (ETA) over fuel efficiency, blinding users to the hidden financial and environmental costs of severe traffic, idling, and suboptimal route selection.
3.  **Invisible Fuel Consumption:** The absence of accessible telematics means drivers cannot link specific habits (e.g., harsh braking, aggressive acceleration) directly to their weekly petrol expenses.
4.  **Abstract Environmental Metrics:** Carbon emissions ($CO_2$ grams) are difficult to quantify on a personal level, resulting in low public motivation to adopt sustainable driving habits over the long term.

---

## 3. Target Audience
* **Primary:** Malaysian petrol vehicle owners and daily commuters looking to reduce transportation expenses amidst rising costs.
* **Secondary:** University students and young professionals who are tech-savvy, budget-conscious, and responsive to gamified, competitive digital ecosystems.

---

## 4. Proposed Solution: Core Features & Workflow
EcoHorizon operates on a closed-loop user journey, leveraging behavioral psychology and real-time data to foster sustainable habits:

### 4.1. Personalized Vehicle & Subsidy Profiling
* Users configure their vehicle's fuel type (Petrol RON95, RON97, Diesel) and link their national subsidy tier (e.g., BUDI Madani). 
* The system uses this profile as the baseline multiplier for all subsequent cost and emission calculations.

### 4.2. APM Smart Refuel Engine
* A predictive alert system that intercepts the user before their commute. If an APM price hike is forecasted for the upcoming Thursday and the user's virtual tank is low, the app pushes an actionable alert (e.g., *"Refuel at Petronas Skudai tonight to save RM12.50 this week"*).

### 4.3. Cost-Aware Eco-Routing
* When a user searches for a destination (e.g., commuting from UTM to Mid Valley Southkey), the map interface presents route alternatives compared by **Estimated Petrol Cost (RM)**, **Carbon Emission (kg)**, and **Potential Reward Points**, rather than just time and distance.

### 4.4. Telematics & Gamification (The "Green Right Foot")
* During navigation, the app utilizes native smartphone sensors (accelerometer/gyroscope) to monitor driving stability. 
* Harsh braking or aggressive acceleration dynamically reduces the user's live "Eco Score." Smooth driving and adherence to green routes fill up a visual reward pool, ultimately awarding "Petrol Points."

### 4.5. Post-Trip Dashboard & Concrete Carbon Ledger
* Upon arrival, users receive a trip diagnosis highlighting specific financial losses due to idling or aggressive driving.
* The carbon ledger translates abstract emissions into relatable, localized metrics (e.g., *"You saved 15kg of $CO_2$ this month, equivalent to planting a tree in Johor Bahru"*).

---

## 5. Technical Architecture
The system is designed for high performance and rapid iteration over a 2-day development cycle.

### 5.1. Frontend: Flutter
* **Framework:** Flutter (Dart) for cross-platform (iOS/Android) mobile deployment.
* **Key Packages:** * `Maps_flutter`: For rendering the map and cost-aware polylines.
    * `sensors_plus`: To access device accelerometer and gyroscope for the telematics engine.
    * `fl_chart`: For rendering the post-trip speed and emission rate dual-axis graphs.

### 5.2. Backend & Database: Supabase
* **Framework:** Supabase (PostgreSQL) acting as the Backend-as-a-Service (BaaS).
* **Features Leveraged:** Instant API generation, authentication (if required), and real-time database subscriptions to push live APM updates to the app.
* **Mock Data Strategy:** While Supabase will store user profiles, vehicle configurations, and trip histories, live external financial APIs will be substituted with hardcoded chronological arrays (Mock Data) to ensure a flawless, zero-latency pitch demonstration.

### 5.3. Proposed Database Schema (Supabase)
To support the MVP, the PostgreSQL database will feature three core tables:
1.  **`users`**: `id`, `name`, `fuel_type`, `subsidy_tier`, `total_eco_score`, `petrol_points_balance`.
2.  **`trips`**: `id`, `user_id`, `start_location`, `end_location`, `distance_km`, `eco_score`, `fuel_cost_rm`, `carbon_saved_kg`, `created_at`.
3.  **`apm_alerts`**: `id`, `fuel_type`, `predicted_increase_rm`, `alert_message`, `is_active`.

---

## 6. Execution Plan & Timeline
The 3-member team will execute this project over a strict 48-hour hackathon timeline:

* **Day 1: Foundation & Architecture**
    * Set up the Flutter project repository and establish the Supabase project connection.
    * Design and implement the UI/UX for the Onboarding, Dashboard, and Map Interface.
    * Configure the database schema and build the data models in Dart.
* **Day 2: Logic Integration & Pitch Polish**
    * Implement the smartphone sensor fusion logic (telematics) and the mock timer system for live route simulation.
    * Connect the frontend to Supabase to log completed trips and update the user's `petrol_points_balance`.
    * Finalize the Pitch Deck, rehearse the "Hardcoded Storytelling" demo workflow, and ensure seamless transitions between app states.