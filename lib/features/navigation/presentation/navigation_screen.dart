import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/network/app_navigation_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../telematics/controllers/drive_score_notifier.dart';
import '../../rewards/controllers/reward_controller.dart';
import '../../apm/controllers/apm_alert_controller.dart';
import '../../auth/controllers/profile_controller.dart';
import '../controllers/map_controller.dart';
import '../models/route_option.dart';

enum MapState { comparison, driving }

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  MapState _mapState = MapState.comparison;
  double _tripProgress = 0.0;
  Timer? _tripTimer;
  double _currentSpeed = 72.0;
  Timer? _speedTimer;
  bool _flashRedBorder = false;
  bool _isLoadingRoutes = true;
  bool _blinkOn = true;
  BitmapDescriptor? _carIcon;
  bool _showingPetrolStation = false;
  bool _refueledSuccess = false;
  bool _lowFuelAlertShown = false; // prevents repeated auto-alerts per trip

  GoogleMapController? _googleMapController;
  late TextEditingController _searchController;

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#0f172a"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#94a3b8"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#0f172a"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#334155"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#1e293b"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#334155"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#020617"}]
  }
]
  ''';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'Seri Alam, Masai, Johor');
    _initCarIcon();
    // Simulate "Cloud AI calculation" loading lag
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
        });
        _fitCurrentRouteBounds();
      }
    });
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    _speedTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initCarIcon() async {
    try {
      final icon = await _createBlueDotIcon();
      if (mounted) {
        setState(() {
          _carIcon = icon;
        });
      }
    } catch (e) {
      // Fallback
    }
  }

  Future<BitmapDescriptor> _createBlueDotIcon() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);
    const double size = 32.0;
    const double center = size / 2;

    // Draw outer glow circle (soft transparent blue)
    canvas.drawCircle(
      const Offset(center, center),
      14.0,
      ui.Paint()
        ..color = const Color(0x332196F3) // ~20% opacity blue
        ..style = ui.PaintingStyle.fill,
    );
    
    // Draw white border ring
    canvas.drawCircle(
      const Offset(center, center),
      7.5,
      ui.Paint()
        ..color = const Color(0xFFFFFFFF) // Crisp white border
        ..style = ui.PaintingStyle.fill,
    );

    // Draw solid blue inner dot
    canvas.drawCircle(
      const Offset(center, center),
      5.5,
      ui.Paint()
        ..color = const Color(0xFF2196F3) // Solid blue
        ..style = ui.PaintingStyle.fill,
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    }
    
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    controller.setMapStyle(_darkMapStyle);
    // Try to fit bounds immediately; if routes aren't ready yet the
    // ref.listen on mapControllerProvider will handle it once they arrive.
    _fitCurrentRouteBounds();
    // Fallback: retry after a short delay in case routes load quickly but
    // the controller wasn't ready in time.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fitCurrentRouteBounds();
    });
  }

  void _fitCurrentRouteBounds() {
    final mapState = ref.read(mapControllerProvider);
    final selected = mapState.selectedRoute;
    if (selected != null) {
      _fitRouteBounds(selected.polylinePoints);
    }
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty || _googleMapController == null) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final p in points) {
      if (minLat == null || p.latitude < minLat) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng) maxLng = p.longitude;
    }

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.005, minLng - 0.005),
            northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
          ),
          50,
        ),
      );
    }
  }

  LatLng? _getCarPosition(List<LatLng> points, double progress) {
    if (points.isEmpty) return null;
    int index = (progress * (points.length - 1)).floor();
    if (index >= points.length - 1) return points.last;

    final p1 = points[index];
    final p2 = points[index + 1];
    final segmentProgress = (progress * (points.length - 1)) - index;
    final lat = p1.latitude + (p2.latitude - p1.latitude) * segmentProgress;
    final lng = p1.longitude + (p2.longitude - p1.longitude) * segmentProgress;
    return LatLng(lat, lng);
  }

  void _startDrivingSimulation() {
    final mapState = ref.read(mapControllerProvider);
    final selectedRoute = mapState.selectedRoute ?? RouteOption.demoA();

    setState(() {
      _mapState = MapState.driving;
      _tripProgress = 0.0;
      _currentSpeed = 72.0;
      _blinkOn = true;
      _lowFuelAlertShown = false; // reset alert guard for new trip
    });

    ref.read(driveScoreNotifierProvider.notifier).startTrip();

    // Progress simulation
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        _tripProgress += 0.02;
        if (_tripProgress >= 1.0) {
          _tripProgress = 1.0;
          _tripTimer?.cancel();
          _speedTimer?.cancel();
          _currentSpeed = 0.0;
        }
      });

      // Decrease fuel level progressively (0.3% per tick)
      final apmAlertState = ref.read(apmAlertControllerProvider).valueOrNull;
      if (apmAlertState != null) {
        final currentFuel = (apmAlertState.virtualTankPercentage - 0.3).clamp(0.0, 100.0);
        ref.read(apmAlertControllerProvider.notifier).updateVirtualTank(currentFuel);
      }

      // Animate camera to follow the car
      final carPos = _getCarPosition(selectedRoute.polylinePoints, _tripProgress);
      if (carPos != null && _googleMapController != null) {
        _googleMapController!.animateCamera(CameraUpdate.newLatLng(carPos));
      }
    });

    // Speed fluctuation timer
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _currentSpeed = 70.0 + (15.0 * (DateTime.now().second % 4) / 3.0);
      });
    });
  }

  void _triggerHarshEvent(double gForce, String type) {
    ref.read(driveScoreNotifierProvider.notifier).simulateHarshEvent(gForce);
    
    // Haptic feedback
    HapticFeedback.vibrate();
  }

  void _showPetrolStationDetour({bool isAutoAlert = false}) {
    if (isAutoAlert) {
      // Brief vibration + red banner then open dialog after 2s
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 160, left: 16, right: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.local_gas_station, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('⚠️ Fuel Low — Below 20%!',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Nearest station found — Petronas Masai',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      // Show the detour card after the snackbar has been visible briefly
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_showingPetrolStation) {
          setState(() => _showingPetrolStation = true);
          _googleMapController?.animateCamera(
            CameraUpdate.newLatLngZoom(const LatLng(1.4820, 103.8050), 14.5),
          );
        }
      });
    } else {
      // Manual tap — open immediately
      setState(() => _showingPetrolStation = true);
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(1.4820, 103.8050), 14.5),
      );
    }
  }

  void _cancelDetour() {
    setState(() {
      _showingPetrolStation = false;
    });
    _fitCurrentRouteBounds();
  }

  void _refuelVehicle() {
    // 1. Reset virtual tank to 100%
    ref.read(apmAlertControllerProvider.notifier).updateVirtualTank(100.0);

    // 2. Increment points balance by 50 points
    final profile = ref.read(profileControllerProvider).value;
    if (profile != null) {
      ref.read(profileControllerProvider.notifier).updateProfile(
            name: profile.name,
            fuelType: profile.fuelType,
            subsidyTier: profile.subsidyTier,
            petrolPointsBalance: profile.petrolPointsBalance + 50,
          );
    }

    setState(() {
      _showingPetrolStation = false;
      _refueledSuccess = true;
      _lowFuelAlertShown = true; // don't re-alert after refuel
    });

    // Animate back to original route bounds
    _fitCurrentRouteBounds();

    // Show a success banner for 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _refueledSuccess = false;
        });
      }
    });
  }

  void _endDriving() {
    _tripTimer?.cancel();
    _speedTimer?.cancel();

    final driveState = ref.read(driveScoreNotifierProvider);
    ref.read(driveScoreNotifierProvider.notifier).endTrip();

    int stars = 3;
    if (driveState.score < 70) {
      stars = 1;
    } else if (driveState.score < 90) {
      stars = 2;
    }

    final mapState = ref.read(mapControllerProvider);
    final selectedRoute = mapState.selectedRoute ?? RouteOption.demoA();
    final double defaultCarbon = RouteOption.demoB().carbonKg;
    final double savedCarbon = (defaultCarbon - selectedRoute.carbonKg).clamp(0.0, 5.0);

    // Settle points
    ref.read(rewardControllerProvider.notifier).settleReward(
          starRating: stars,
          ecoScore: driveState.score,
          carbonSavedKg: savedCarbon,
        );

    ref.read(appNavigationProvider.notifier).navigateTo(AppScreen.tripSummary);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DriveScoreState>(driveScoreNotifierProvider, (previous, next) {
      if (next.isWarning && !(previous?.isWarning ?? false)) {
        setState(() {
          _flashRedBorder = true;
        });
      } else if (!next.isWarning && (previous?.isWarning ?? false)) {
        setState(() {
          _flashRedBorder = false;
        });
      }
    });

    // Auto-fit camera whenever routes finish loading
    ref.listen<MapNavigationState>(mapControllerProvider, (previous, next) {
      final prevLoaded = previous?.routesState.value?.isNotEmpty ?? false;
      final nextLoaded = next.routesState.value?.isNotEmpty ?? false;
      if (!prevLoaded && nextLoaded && _googleMapController != null) {
        final selected = next.selectedRoute;
        if (selected != null) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _fitRouteBounds(selected.polylinePoints);
          });
        }
      }
    });

    // Reload route costs whenever the user changes fuel type or subsidy tier
    ref.listen<AsyncValue<dynamic>>(profileControllerProvider, (previous, next) {
      final prevProfile = previous?.valueOrNull;
      final nextProfile = next.valueOrNull;
      if (nextProfile == null) return;
      final fuelChanged = prevProfile?.fuelType != nextProfile.fuelType;
      final tierChanged = prevProfile?.subsidyTier != nextProfile.subsidyTier;
      if ((fuelChanged || tierChanged) && _mapState == MapState.comparison) {
        ref.read(mapControllerProvider.notifier).reloadWithProfile(
          nextProfile.fuelType,
          nextProfile.subsidyTier,
        );
      }
    });

    // ── Auto low-fuel alert at 20% ──────────────────────────────────────────
    ref.listen<AsyncValue<ApmAlertState>>(apmAlertControllerProvider, (previous, next) {
      final prevFuel = previous?.valueOrNull?.virtualTankPercentage ?? 100.0;
      final nextFuel = next.valueOrNull?.virtualTankPercentage;
      if (nextFuel == null) return;

      // Fire once when fuel crosses below 20% during an active drive
      final crossedThreshold = prevFuel >= 20.0 && nextFuel < 20.0;
      if (crossedThreshold && _mapState == MapState.driving && !_lowFuelAlertShown && !_showingPetrolStation) {
        _lowFuelAlertShown = true;
        _showPetrolStationDetour(isAutoAlert: true);
      }
    });

    final mapState = ref.watch(mapControllerProvider);
    final routeState = mapState.routesState;
    final selectedRoute = mapState.selectedRoute ?? RouteOption.demoA();
    final driveState = ref.watch(driveScoreNotifierProvider);

    // Build the set of markers dynamically adding the car marker during navigation
    final Set<Marker> displayMarkers = Set.from(mapState.markers);
    final Set<Circle> displayCircles = {};
    if (_mapState == MapState.driving && selectedRoute.polylinePoints.isNotEmpty) {
      final carPos = _getCarPosition(selectedRoute.polylinePoints, _tripProgress);
      if (carPos != null) {
        displayMarkers.add(
          Marker(
            markerId: const MarkerId('car'),
            position: carPos,
            icon: _carIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            alpha: 1.0,
            infoWindow: const InfoWindow(title: 'Simulated Vehicle'),
            zIndex: 3,
          ),
        );
      }
    }

    if (_showingPetrolStation) {
      displayMarkers.add(
        Marker(
          markerId: const MarkerId('petrol_station'),
          position: const LatLng(1.4820, 103.8050), // Petronas near Masai on the route
          infoWindow: const InfoWindow(
            title: 'Petronas Masai',
            snippet: 'Eco Partner - +50 Pts Cashpack',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          zIndex: 4,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Google Map canvas background
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(1.5183, 103.7619), // Midpoint: UTM Skudai ↔ Seri Alam, Masai
                zoom: 11.5,
              ),
              markers: displayMarkers,
              circles: displayCircles,
              polylines: mapState.polylines,
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
            ),
          ),

          // 3. Search Bar for Destination Input
          if (!_isLoadingRoutes && _mapState == MapState.comparison)
            Positioned(
              top: 24,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Enter destination...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              setState(() {
                                _isLoadingRoutes = true;
                              });
                              ref.read(mapControllerProvider.notifier).loadRoutes(
                                start: 'Universiti Teknologi Malaysia, Skudai, Johor',
                                end: val.trim(),
                              ).then((_) {
                                if (mounted) {
                                  setState(() {
                                    _isLoadingRoutes = false;
                                  });
                                  _fitCurrentRouteBounds();
                                }
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                        onPressed: () {
                          final val = _searchController.text;
                          if (val.trim().isNotEmpty) {
                            setState(() {
                              _isLoadingRoutes = true;
                            });
                            ref.read(mapControllerProvider.notifier).loadRoutes(
                              start: 'Universiti Teknologi Malaysia, Skudai, Johor',
                              end: val.trim(),
                            ).then((_) {
                              if (mounted) {
                                setState(() {
                                  _isLoadingRoutes = false;
                                });
                                _fitCurrentRouteBounds();
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Loading Shimmer Overlay for AI Cloud computing simulation
          if (_isLoadingRoutes)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 4.0,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cloud AI Routing...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Generating optimal fuel-saving pathways',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Content widgets depending on comparison / active driving
          if (!_isLoadingRoutes && _mapState == MapState.comparison) ...[
            // Route selection Bottom Sheet Overlay
            Positioned(
              bottom: 95,
              left: 20,
              right: 20,
              child: SafeArea(
                bottom: false,
                child: routeState.when(
                  data: (routes) {
                    if (routes.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            'No routes found. Please check destination name.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: routes.map((route) {
                            final isSelected = selectedRoute.name == route.name;
                            final isEco = route.name.toLowerCase().contains('eco');
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  ref.read(mapControllerProvider.notifier).selectRoute(route);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: route == routes.first ? 6 : 0,
                                    left: route == routes.last ? 6 : 0,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isEco
                                            ? Color.alphaBlend(AppColors.primary.withOpacity(0.08), AppColors.surface)
                                            : Color.alphaBlend(Colors.white.withOpacity(0.05), AppColors.surface))
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isSelected
                                          ? (isEco ? AppColors.primary : Colors.white)
                                          : AppColors.border,
                                      width: isSelected ? 2.0 : 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            route.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected && isEco ? AppColors.primary : Colors.white,
                                            ),
                                          ),
                                          if (isEco)
                                            const Icon(Icons.eco_rounded, color: AppColors.primary, size: 16),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'RM ${route.fuelCostRm.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${route.distanceKm.toStringAsFixed(1)} km | ${route.durationMinutes} mins',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${route.carbonKg.toStringAsFixed(2)} kg CO₂',
                                        style: TextStyle(
                                          color: isEco ? AppColors.primary : AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: isEco ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startDrivingSimulation,
                            child: const Text('Start Eco Navigation'),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('Error loading routes: $err', style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
            ),
          ],

          if (!_isLoadingRoutes && _mapState == MapState.driving) ...[
            // Top Right Gamified Panel: Circular Progress Wrapping Eco Score
            Positioned(
              top: 120,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: driveState.score / 100.0,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            driveState.isWarning
                                ? AppColors.warning
                                : driveState.score >= 90
                                    ? AppColors.primary
                                    : Colors.amber,
                          ),
                          strokeWidth: 6.0,
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            'ECO',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${driveState.score}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: driveState.isWarning
                                  ? AppColors.warning
                                  : driveState.score >= 90
                                      ? AppColors.primary
                                      : Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom HUD panel
            Positioned(
              bottom: 95,
              left: 20,
              right: 20,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('SPEED', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _currentSpeed.toStringAsFixed(0),
                                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                                height: 1.0,
                                                color: Colors.white,
                                                letterSpacing: -1.0,
                                              ),
                                        ),
                                        const TextSpan(
                                          text: ' km/h',
                                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('FUEL COST', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'RM ',
                                          style: TextStyle(fontSize: 16, color: AppColors.primary.withOpacity(0.7), fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: (selectedRoute.fuelCostRm * _tripProgress).toStringAsFixed(2),
                                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                                color: Colors.white,
                                                height: 1.0,
                                                letterSpacing: -1.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('UTM Skudai, Johor', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(
                                    '${(_tripProgress * 100).toStringAsFixed(0)}% Complete',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                  Text(_searchController.text.isNotEmpty ? _searchController.text : 'Destination', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _tripProgress,
                                  backgroundColor: AppColors.secondary,
                                  color: AppColors.primary,
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.background,
                              ),
                              onPressed: _endDriving,
                              child: const Text('Complete Commute & Settle Rewards'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            'SIMULATE TELEMATICS:',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            icon: const Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 16),
                            label: const Text('HARSH ACCEL', style: TextStyle(color: AppColors.warning, fontSize: 11)),
                            onPressed: () => _triggerHarshEvent(0.38, 'Harsh Acceleration'),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            icon: const Icon(Icons.vibration_rounded, color: AppColors.warning, size: 16),
                            label: const Text('HARSH BRAKE', style: TextStyle(color: AppColors.warning, fontSize: 11)),
                            onPressed: () => _triggerHarshEvent(0.42, 'Harsh Braking'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Flashing Red Alert Halo Overlay during Harsh Event (0.5s duration)
          if (_flashRedBorder)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _flashRedBorder ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.95),
                      width: 10.0,
                    ),
                  ),
                ),
              ),
            ),

          // Alert Overlay Text
          if (driveState.isWarning)
            Positioned(
              top: 214,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'HARSH EVENT DETECTED! -5 SCORE',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 6. Fuel Level Indicator Overlay
          Positioned(
            top: _mapState == MapState.driving ? 120 : 100,
            left: 20,
            child: SafeArea(
              child: Consumer(
                builder: (context, ref, child) {
                  final apmState = ref.watch(apmAlertControllerProvider);
                  final fuelPercentage = apmState.valueOrNull?.virtualTankPercentage ?? 100.0;
                  final isLow = fuelPercentage < 40.0;
                  final Color fuelColor = fuelPercentage < 20.0
                      ? Colors.red
                      : (isLow ? Colors.amber : AppColors.primary);

                  return GestureDetector(
                    onTap: () {
                      if (isLow) {
                        _showPetrolStationDetour();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Fuel level is healthy: ${fuelPercentage.toStringAsFixed(0)}%'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLow ? Colors.amber.withOpacity(0.8) : AppColors.border,
                          width: isLow ? 2.0 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isLow ? Colors.amber.withOpacity(0.15) : Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_gas_station_rounded,
                            color: fuelColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'FUEL LEVEL',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${fuelPercentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: fuelColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (isLow) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 7. Detour Dialog Overlay
          if (_showingPetrolStation)
            Positioned(
              bottom: 95,
              left: 20,
              right: 20,
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_gas_station_rounded, color: Colors.amber, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Low Fuel Alert',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Petronas Masai is 1.5km away.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Would you like to detour and refuel now? You will earn +50 Petrol Points for using this partner station.',
                        style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _cancelDetour,
                              child: const Text('No, Skip'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _refuelVehicle,
                              child: const Text('Reroute & Refuel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 8. Refueled Success Banner Overlay
          if (_refueledSuccess)
            Positioned(
              top: 24,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Refueled Successfully!',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+50 Petrol Points added to balance.',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
