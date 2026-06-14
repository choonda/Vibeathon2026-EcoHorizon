# EcoHorizon: Autonomous Vibe Coding Master Prompt

## 1. Objective
Act as the **EcoHorizon Main Agent**. Your goal is to autonomously implement and test the entire EcoHorizon ecosystem as defined in the project documentation. You must orchestrate the development process by delegating specific module implementations to sub-agents, tracking progress, and ensuring 100% test coverage for business logic.

**No human intervention is required.** Persist until the project is complete and verified.

## 2. Technical Context
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (Providers/StateNotifiers)
- **Architecture:** Clean Architecture (Core, Data, Domain, Presentation)
- **Backend:** Supabase (Auth, PostgreSQL)
- **External APIs:** Google Maps Directions API, native device sensors (`sensors_plus`)
- **Testing:** Unit tests for all Controllers/Repositories and Widget tests for core UI.

## 3. Project Roadmap (References)
- **Vision & Scope:** [doc/Proposal.md](../Proposal.md)
- **Detailed Design:** [doc/Detailed-design.md](../Detailed-design.md)
- **Detailed Task Lists:** 
    - [User Profile](tasks/user-profile.md)
    - [APM Engine](tasks/apm-engine.md)
    - [Eco-Routing](tasks/eco-routing.md)
    - [Telematics](tasks/telematics.md)
    - [Dashboard](tasks/dashboard.md)
- **Task Tracking:** [doc/tasks/progress.md](tasks/progress.md)

## 4. Main Agent Workflow
1.  **Initialization:**
    - Initialize the Flutter project: `flutter create --org com.vibeathon eco_horizon`.
    - Add dependencies: `flutter_riverpod`, `supabase_flutter`, `google_maps_flutter`, `sensors_plus`, `fl_chart`.
    - Scaffold the folder structure defined in `Detailed-design.md`.

2.  **Autonomous Delegation:**
    For each module listed in `doc/tasks/progress.md`, invoke a specialized sub-agent with the following mandate:
    - **Implementation Details:** Strictly follow the granular steps in the corresponding `doc/tasks/<module>.md` file.
    - **Key Components:**
        - **User Profile:** Supabase `users` table, `OnboardingScreen` with Fuel Type and Subsidy dropdowns.
        - **APM Engine:** `ApmAlertModal` with "Add to Route" waypoint logic, and hardcoded Thursday hike (+RM0.08).
        - **Eco-Routing:** `NavigationScreen` with Google Maps, search bar, and `RouteComparisonBottomSheet` comparing RM costs and CO2.
        - **Telematics:** `DriveScoringEngine` with 0.3g deductive logic, `ActiveDriveOverlay` with a red flashing warning for harsh events.
        - **Dashboard:** `TripSummaryScreen`, `CarbonLedgerDashboard` with `fl_chart` historical trends, and "Tree Planting" impact translation.
    - **Testing:** Write unit tests for all `StateNotifiers` and Repositories.
    - **Tracking:** Update the module's task file and the master `progress.md` upon success.

3.  **Modules to Implement:**
    - **User Profile:** Onboarding, subsidy tiers, and Supabase sync.
    - **APM Engine:** Price hike predictions, "Virtual Tank" slider, and alert triggers.
    - **Eco-Routing:** Google Maps integration, comparative routing, and the `EcoCostCalculator`.
    - **Telematics:** `DriveScoringEngine` using accelerometer data and live score UI.
    - **Dashboard:** Post-trip analytics, carbon ledger, and `fl_chart` integration.

4.  **Integration & Final Validation:**
    - Ensure all Riverpod providers are correctly wired.
    - Verify the "End-to-End" flow: Onboarding -> Map Selection -> Live Drive -> Summary Dashboard.
    - Run the final test suite.

## 5. Implementation Rules
- **Surgical Edits:** Use the `replace` tool for precise code modifications.
- **Clean Code:** Adhere strictly to the repository pattern and dependency injection.
- **Mock First:** Always provide Mock implementations for Repositories to ensure the "Vibe Coding" flow is never blocked by missing API keys or backend connectivity.
- **No Filler:** Focus on functional, visually appealing, and tested code.

## 6. Termination Criteria
The task is complete only when:
1. All checklists in `doc/tasks/*.md` are marked as complete.
2. The `doc/tasks/progress.md` shows 100% completion.
3. All unit and widget tests pass.
4. The final Flutter application builds and runs the core "Storytelling" flow.

**Begin Phase 1: Foundation & Scaffold.**
