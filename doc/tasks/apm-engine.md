# Module 2: APM Smart Refuel Engine

## Setup & Data Layer
- [ ] Create the `ApmPredictionModel` Dart data class (`predicted_increase_rm`, `alert_message`, `target_date`).
- [ ] Create the abstract `ApmRepository` interface.
- [ ] Implement `MockApmRepo` returning a hardcoded simulated price hike (e.g., +RM0.08 on Thursday).

## State Management (Riverpod)
- [ ] Create `ApmAlertController` (`StateNotifier`).
- [ ] Implement a method inside the controller to evaluate the current device `DateTime` and virtual tank capacity against the `MockApmRepo` data.
- [ ] Expose a boolean state `shouldShowAlert` to trigger the UI.

## Presentation Layer (UI)
- [ ] Build the `ApmAlertModal` widget (a high-impact pop-up card).
- [ ] Design the modal to display the predicted hike amount and the exact Ringgit (RM) savings recommendation.
- [ ] Bind the modal to listen to `ApmAlertController`.
- [ ] Add an "Add to Route" button that closes the modal and passes a waypoint to the map screen.