# Module 3: Cost-Aware Eco-Routing

## Setup & Data Layer
- [x] Obtain a Google Maps API Key and configure iOS/Android manifest files.
- [x] Add the `google_maps_flutter` package to `pubspec.yaml`.
- [x] Create the abstract `RouteRepository` interface.
- [x] Implement `GoogleMapsRouteRepo` to fetch polyline coordinates, distance (km), and duration.

## State Management (Riverpod)
- [x] Create the `EcoCostCalculator` pure utility function (Inputs: distance, duration, fuel type -> Outputs: RM cost, kg CO2).
- [x] Create `MapController` (`StateNotifier`) to manage the state of map markers, drawn polylines, and the calculated route metrics.
- [x] Implement logic to process and store data for Route A (Eco) and Route B (Fastest).

## Presentation Layer (UI)
- [x] Build the `NavigationScreen` containing the `GoogleMap` widget.
- [x] Add a search bar widget for destination input.
- [x] Build the `RouteComparisonBottomSheet` widget to display Route A vs. Route B.
- [x] Bind the bottom sheet to display the calculated RM costs and CO2 outputs from the `MapController`.
- [x] Add a "Start Navigation" button that transitions the UI into active drive mode.