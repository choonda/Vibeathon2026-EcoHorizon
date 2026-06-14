import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecohorizon/features/navigation/controllers/map_controller.dart';
import 'package:ecohorizon/features/navigation/models/route_option.dart';
import 'package:ecohorizon/features/auth/controllers/profile_controller.dart';

void main() {
  group('MapController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override the profile provider to return a demo profile immediately
          profileControllerProvider.overrideWith((ref) {
            final controller = ProfileController(MockProfileRepository());
            controller.loadDemoProfile();
            return controller;
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state handles loading demo routes', () async {
      // The mapControllerProvider runs loadDemoRoutes on creation
      final mapState = container.read(mapControllerProvider);

      // Verify initial loading state while future resolves
      expect(mapState.routesState, isA<AsyncLoading>());

      // Wait for the async task to complete
      await container.read(mapControllerProvider.notifier).loadDemoRoutes();
      
      final updatedState = container.read(mapControllerProvider);
      expect(updatedState.routesState, isA<AsyncData<List<RouteOption>>>());

      final routes = updatedState.routesState.value!;
      expect(routes.length, equals(2));
      expect(routes[0].name, equals('Eco Route A'));
      expect(routes[1].name, equals('Fast Route B'));

      // First route should be selected by default
      expect(updatedState.selectedRoute, equals(routes[0]));

      // Markers should be set for start and destination
      expect(updatedState.markers.length, equals(2));

      // Polylines should be generated for both routes
      expect(updatedState.polylines.length, equals(2));
    });

    test('selecting route updates selectedRoute and highlights polyline', () async {
      await container.read(mapControllerProvider.notifier).loadDemoRoutes();

      final notifier = container.read(mapControllerProvider.notifier);
      final initialRoutes = container.read(mapControllerProvider).routesState.value!;

      // Select Fast Route B
      notifier.selectRoute(initialRoutes[1]);

      final updatedState = container.read(mapControllerProvider);
      expect(updatedState.selectedRoute, equals(initialRoutes[1]));

      // Polylines should still be 2, but the one for Fast Route B should be highlighted (width 8)
      final fastPolyline = updatedState.polylines.firstWhere(
        (p) => p.polylineId.value == 'Fast Route B',
      );
      expect(fastPolyline.width, equals(8));

      final ecoPolyline = updatedState.polylines.firstWhere(
        (p) => p.polylineId.value == 'Eco Route A',
      );
      expect(ecoPolyline.width, equals(4));
    });
  });
}
