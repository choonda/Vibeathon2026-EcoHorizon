import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/route_option.dart';
import '../repositories/route_repository.dart';
import '../repositories/google_maps_route_repository.dart';
import '../../auth/controllers/profile_controller.dart';

class MapNavigationState {
  final AsyncValue<List<RouteOption>> routesState;
  final RouteOption? selectedRoute;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  const MapNavigationState({
    required this.routesState,
    this.selectedRoute,
    required this.markers,
    required this.polylines,
  });

  factory MapNavigationState.initial() {
    return const MapNavigationState(
      routesState: AsyncValue.loading(),
      selectedRoute: null,
      markers: {},
      polylines: {},
    );
  }

  MapNavigationState copyWith({
    AsyncValue<List<RouteOption>>? routesState,
    RouteOption? selectedRoute,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
  }) {
    return MapNavigationState(
      routesState: routesState ?? this.routesState,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
    );
  }
}

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return GoogleMapsRouteRepository();
});

final mapControllerProvider =
    StateNotifierProvider<MapController, MapNavigationState>((ref) {
  return MapController(ref)..loadDemoRoutes();
});

class MapController extends StateNotifier<MapNavigationState> {
  MapController(this._ref) : super(MapNavigationState.initial());

  final Ref _ref;

  RouteRepository get _repository => _ref.read(routeRepositoryProvider);

  Future<void> loadRoutes({required String start, required String end}) async {
    state = state.copyWith(routesState: const AsyncValue.loading());
    
    final userProfile = _ref.read(profileControllerProvider).value;
    final fuelType = userProfile?.fuelType ?? 'RON95';
    final subsidyTier = userProfile?.subsidyTier;

    try {
      final routes = await _repository.fetchRouteOptions(
        start: start,
        end: end,
        fuelType: fuelType,
        subsidyTier: subsidyTier,
      );
      _updateMapData(routes);
    } catch (e, stack) {
      state = state.copyWith(routesState: AsyncValue.error(e, stack));
    }
  }

  Future<void> loadDemoRoutes() async {
    state = state.copyWith(routesState: const AsyncValue.loading());
    
    final userProfile = _ref.read(profileControllerProvider).value;
    final fuelType = userProfile?.fuelType ?? 'RON95';
    final subsidyTier = userProfile?.subsidyTier;

    try {
      final routes = await _repository.fetchRouteOptions(
        start: 'UTM Skudai',
        end: 'Mid Valley Southkey',
        fuelType: fuelType,
        subsidyTier: subsidyTier,
      );
      _updateMapData(routes);
    } catch (e, stack) {
      state = state.copyWith(routesState: AsyncValue.error(e, stack));
    }
  }

  void selectRoute(RouteOption route) {
    final currentRoutes = state.routesState.value ?? [];
    state = state.copyWith(
      selectedRoute: route,
      polylines: _buildPolylines(currentRoutes, route),
      markers: _buildMarkers(route),
    );
  }

  void _updateMapData(List<RouteOption> routes) {
    if (routes.isEmpty) {
      state = state.copyWith(
        routesState: AsyncValue.data(routes),
        selectedRoute: null,
        markers: {},
        polylines: {},
      );
      return;
    }

    final selected = routes.first;
    state = state.copyWith(
      routesState: AsyncValue.data(routes),
      selectedRoute: selected,
      markers: _buildMarkers(selected),
      polylines: _buildPolylines(routes, selected),
    );
  }

  Set<Marker> _buildMarkers(RouteOption selected) {
    if (selected.polylinePoints.isEmpty) return {};

    return {
      Marker(
        markerId: const MarkerId('start'),
        position: selected.polylinePoints.first,
        infoWindow: const InfoWindow(title: 'Start Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: selected.polylinePoints.last,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ),
    };
  }

  Set<Polyline> _buildPolylines(List<RouteOption> routes, RouteOption selected) {
    Set<Polyline> polylines = {};
    for (final route in routes) {
      final isSelected = route.name == selected.name;
      final isEco = route.name.toLowerCase().contains('eco');

      final Color color = isEco
          ? (isSelected ? const Color(0xFF10B981) : const Color(0xFF10B981).withOpacity(0.35))
          : (isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B).withOpacity(0.35));

      polylines.add(
        Polyline(
          polylineId: PolylineId(route.name),
          points: route.polylinePoints,
          color: color,
          width: isSelected ? 8 : 4,
          zIndex: isSelected ? 1 : 0,
        ),
      );
    }
    return polylines;
  }
}