import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Demo positions
  static const _userLocation = LatLng(9.9252, 78.1198); // Madurai center — user location
  LatLng _driverLocation = const LatLng(0, 0);
  LatLng _restaurantLocation = const LatLng(0, 0);
  String _restaurantName = '';

  // Route simulation
  final List<LatLng> _routePoints = [];
  int _currentRouteIndex = 0;
  Timer? _movementTimer;
  String _currentStatus = 'preparing';
  int _statusIndex = 0;
  final List<Map<String, dynamic>> _statusSteps = [
    {'status': 'confirmed', 'label': 'Order Confirmed', 'icon': Icons.check_circle_rounded, 'color': AppTheme.primaryOrange},
    {'status': 'preparing', 'label': 'Preparing your food', 'icon': Icons.restaurant_rounded, 'color': AppTheme.accentYellow},
    {'status': 'picked_up', 'label': 'Driver picked up order', 'icon': Icons.delivery_dining_rounded, 'color': const Color(0xFF2196F3)},
    {'status': 'on_the_way', 'label': 'On the way to you', 'icon': Icons.navigation_rounded, 'color': const Color(0xFF9C27B0)},
    {'status': 'nearby', 'label': 'Driver is nearby!', 'icon': Icons.near_me_rounded, 'color': AppTheme.success},
    {'status': 'delivered', 'label': 'Delivered! 🎉', 'icon': Icons.done_all_rounded, 'color': AppTheme.success},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        final lat = (args['latitude'] as num?)?.toDouble() ?? 9.9195;
        final lng = (args['longitude'] as num?)?.toDouble() ?? 78.1193;
        _restaurantLocation = LatLng(lat, lng);
        _restaurantName = args['name'] ?? 'Restaurant';
        _driverLocation = _restaurantLocation;
        _buildRoute();
        setState(() {});
        _startSimulation();
      }
    });
  }

  void _buildRoute() {
    // Generate intermediate points between restaurant and user for smooth animation
    const steps = 60;
    final latDiff = _userLocation.latitude - _restaurantLocation.latitude;
    final lngDiff = _userLocation.longitude - _restaurantLocation.longitude;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      // Add slight curve to make it look like a real road
      final curveFactor = math.sin(t * math.pi) * 0.003;
      _routePoints.add(LatLng(
        _restaurantLocation.latitude + latDiff * t + curveFactor,
        _restaurantLocation.longitude + lngDiff * t - curveFactor * 0.5,
      ));
    }
  }

  void _startSimulation() {
    // Phase 1: Wait at restaurant (preparing)
    _statusIndex = 1;
    _currentStatus = 'preparing';

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _statusIndex = 2;
        _currentStatus = 'picked_up';
      });

      // Phase 2: Start moving
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _statusIndex = 3;
          _currentStatus = 'on_the_way';
        });
        _startMoving();
      });
    });
  }

  void _startMoving() {
    _movementTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentRouteIndex < _routePoints.length - 1) {
        _currentRouteIndex++;
        setState(() {
          _driverLocation = _routePoints[_currentRouteIndex];
        });

        // Update status based on progress
        final progress = _currentRouteIndex / _routePoints.length;
        if (progress > 0.75 && _statusIndex < 4) {
          setState(() {
            _statusIndex = 4;
            _currentStatus = 'nearby';
          });
        }

        // Pan map to follow driver
        _mapController.move(_driverLocation, 15);
      } else {
        timer.cancel();
        setState(() {
          _statusIndex = 5;
          _currentStatus = 'delivered';
        });
      }
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.deepBlack.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.deepBlack.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Delivery Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _restaurantLocation.latitude == 0 ? _userLocation : _restaurantLocation,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.foodie.app',
              ),

              // Route path
              if (_routePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: AppTheme.primaryOrange.withValues(alpha: 0.4),
                    ),
                    // Traveled path
                    if (_currentRouteIndex > 0)
                      Polyline(
                        points: _routePoints.sublist(0, _currentRouteIndex + 1),
                        strokeWidth: 4,
                        color: AppTheme.primaryOrange,
                      ),
                  ],
                ),

              // Markers
              MarkerLayer(
                markers: [
                  // Restaurant marker
                  if (_restaurantLocation.latitude != 0)
                    Marker(
                      point: _restaurantLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.deepBlack,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryOrange, width: 2),
                          boxShadow: [BoxShadow(color: AppTheme.primaryOrange.withValues(alpha: 0.3), blurRadius: 10)],
                        ),
                        child: const Center(child: Text('🍽', style: TextStyle(fontSize: 22))),
                      ),
                    ),

                  // User (destination) marker
                  Marker(
                    point: _userLocation,
                    width: 50,
                    height: 50,
                    child: ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 16)],
                        ),
                        child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),

                  // Driver marker
                  if (_driverLocation.latitude != 0 && _currentStatus != 'preparing' && _currentStatus != 'confirmed')
                    Marker(
                      point: _driverLocation,
                      width: 55,
                      height: 55,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 300),
                        builder: (ctx, value, child) => Transform.scale(scale: value, child: child),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [BoxShadow(color: AppTheme.primaryOrange.withValues(alpha: 0.5), blurRadius: 16)],
                          ),
                          child: const Center(child: Text('🏍', style: TextStyle(fontSize: 24))),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Status panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),

                  // Restaurant name
                  Row(
                    children: [
                      const Text('🍽', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _restaurantName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
                        ),
                      ),
                      // ETA
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, color: AppTheme.primaryOrange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _getETA(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryOrange),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress steps
                  ..._statusSteps.asMap().entries.map((entry) {
                    final i = entry.key;
                    final step = entry.value;
                    final isActive = i <= _statusIndex;
                    final isCurrent = i == _statusIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          // Step indicator
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isCurrent ? 36 : 28,
                                height: isCurrent ? 36 : 28,
                                decoration: BoxDecoration(
                                  color: isActive ? (step['color'] as Color).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive ? step['color'] as Color : Colors.white12,
                                    width: isCurrent ? 2.5 : 1.5,
                                  ),
                                ),
                                child: Icon(
                                  step['icon'] as IconData,
                                  color: isActive ? step['color'] as Color : Colors.white24,
                                  size: isCurrent ? 18 : 14,
                                ),
                              ),
                              if (i < _statusSteps.length - 1)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 2,
                                  height: 12,
                                  color: isActive ? step['color'] as Color : Colors.white12,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isCurrent ? 14 : 12,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                                color: isActive ? AppTheme.textWhite : AppTheme.textGrey,
                              ),
                              child: Text(step['label'] as String),
                            ),
                          ),
                          if (isActive)
                            Icon(Icons.check_rounded, color: step['color'] as Color, size: 16),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getETA() {
    if (_currentStatus == 'delivered') return 'Delivered!';
    if (_currentStatus == 'nearby') return '~2 min';
    if (_currentStatus == 'on_the_way') {
      final remaining = _routePoints.length - _currentRouteIndex;
      final mins = (remaining * 0.4 / 60 * 20).toInt().clamp(2, 30);
      return '~$mins min';
    }
    if (_currentStatus == 'picked_up') return '~12 min';
    return '~15 min';
  }
}
