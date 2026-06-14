# Module 4: Telematics & Gamification

## Setup & Data Layer
- [ ] Add the `sensors_plus` package to `pubspec.yaml`.
- [ ] Create the `SensorRepository` to listen to native device accelerometer and gyroscope streams.

## State Management (Riverpod)
- [ ] Create the `DriveScoringEngine` (`StateNotifier` initialized at 100 points).
- [ ] Implement the Deductive Algorithm: Subscribe to `SensorRepository` and deduct 5 points when absolute acceleration spikes above 0.3g.
- [ ] Implement a hard floor limit preventing the score from dropping below 0.
- [ ] Expose an `isHarshDriving` boolean state that triggers true momentarily upon a spike.

## Presentation Layer (UI)
- [ ] Build the `ActiveDriveOverlay` widget to sit on top of the Google Map.
- [ ] Add a dynamic text widget displaying the real-time "Eco Score".
- [ ] Add a dynamic text widget displaying the "Anticipated Reward Points".
- [ ] Build a red visual flashing warning effect that listens to the `isHarshDriving` state.
- [ ] Add an "End Trip" button that halts the sensor stream and passes the final score to Module 5.