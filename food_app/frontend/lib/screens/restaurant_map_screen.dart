import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../theme/app_theme.dart';

class RestaurantMapScreen extends StatefulWidget {
  const RestaurantMapScreen({super.key});

  @override
  State<RestaurantMapScreen> createState() => _RestaurantMapScreenState();
}

class _RestaurantMapScreenState extends State<RestaurantMapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedRestaurant;
  late AnimationController _sheetAnimController;
  late Animation<Offset> _sheetSlide;

  // Madurai center
  static const _maduraiCenter = LatLng(9.9252, 78.1198);

  @override
  void initState() {
    super.initState();
    _sheetAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _sheetAnimController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rp = context.read<RestaurantProvider>();
      if (rp.restaurants.isEmpty) rp.loadRestaurants();
    });
  }

  @override
  void dispose() {
    _sheetAnimController.dispose();
    super.dispose();
  }

  void _onMarkerTap(Map<String, dynamic> restaurant) {
    setState(() => _selectedRestaurant = restaurant);
    _sheetAnimController.forward();
    _mapController.move(
      LatLng(
        (restaurant['latitude'] as num).toDouble(),
        (restaurant['longitude'] as num).toDouble(),
      ),
      14.5,
    );
  }

  void _dismissSheet() {
    _sheetAnimController.reverse().then((_) {
      if (mounted) setState(() => _selectedRestaurant = null);
    });
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
          ),
          child: const Text('Restaurants in Madurai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () {
                _mapController.move(_maduraiCenter, 13);
                _dismissSheet();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.deepBlack.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: const Icon(Icons.my_location_rounded, size: 20, color: AppTheme.primaryOrange),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (ctx, rp, _) {
          final restaurants = rp.restaurants;

          return Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _maduraiCenter,
                  initialZoom: 13,
                  onTap: (_, __) => _dismissSheet(),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.foodie.app',
                  ),

                  // Restaurant markers
                  MarkerLayer(
                    markers: restaurants.where((r) {
                      final lat = r['latitude'];
                      final lng = r['longitude'];
                      return lat != null && lng != null && lat != 0 && lng != 0;
                    }).map((r) {
                      final lat = (r['latitude'] as num).toDouble();
                      final lng = (r['longitude'] as num).toDouble();
                      final isSelected = _selectedRestaurant?['id'] == r['id'];

                      return Marker(
                        point: LatLng(lat, lng),
                        width: isSelected ? 60 : 50,
                        height: isSelected ? 60 : 50,
                        child: GestureDetector(
                          onTap: () => _onMarkerTap(r),
                          child: AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppTheme.primaryGradient : null,
                                color: isSelected ? null : AppTheme.deepBlack,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryOrange : Colors.white,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AppTheme.primaryOrange.withValues(alpha: 0.5)
                                        : Colors.black.withValues(alpha: 0.3),
                                    blurRadius: isSelected ? 16 : 8,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getCategoryEmoji(r['cuisine'] ?? ''),
                                  style: TextStyle(fontSize: isSelected ? 22 : 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // User location marker (demo: Madurai center)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _maduraiCenter,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 12)],
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Bottom sheet
              if (_selectedRestaurant != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SlideTransition(
                    position: _sheetSlide,
                    child: _buildRestaurantSheet(_selectedRestaurant!),
                  ),
                ),

              // Legend
              Positioned(
                bottom: _selectedRestaurant != null ? 220 : 20,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _selectedRestaurant == null ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlack.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendItem('🔵', 'You'),
                        const SizedBox(height: 4),
                        _legendItem('🍕', 'Restaurant'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendItem(String icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textWhite)),
      ],
    );
  }

  Widget _buildRestaurantSheet(Map<String, dynamic> r) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
          Row(
            children: [
              // Emoji avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(_getCategoryEmoji(r['cuisine'] ?? ''), style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                    const SizedBox(height: 4),
                    Text(r['cuisine'] ?? '', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppTheme.accentYellow, size: 16),
                    const SizedBox(width: 3),
                    Text('${r['rating'] ?? 4.0}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accentYellow)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Address
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppTheme.primaryOrange, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(r['address'] ?? '', style: TextStyle(fontSize: 12, color: AppTheme.textGrey))),
            ],
          ),
          const SizedBox(height: 8),
          // Info chips
          Row(
            children: [
              _infoChip(Icons.access_time_rounded, r['delivery_time'] ?? '30 min'),
              const SizedBox(width: 8),
              _infoChip(Icons.delivery_dining_rounded, '₹${r['delivery_fee'] ?? 0}'),
              const SizedBox(width: 8),
              _infoChip(Icons.shopping_bag_outlined, 'Min ₹${r['min_order'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/restaurant-detail', arguments: r['id']),
                    icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                    label: const Text('View Menu', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 48,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/delivery-tracking', arguments: r),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.navigation_rounded, color: AppTheme.primaryOrange, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textGrey),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String cuisine) {
    final c = cuisine.toLowerCase();
    if (c.contains('pizza') || c.contains('italian')) return '🍕';
    if (c.contains('burger') || c.contains('american')) return '🍔';
    if (c.contains('japanese') || c.contains('sushi') || c.contains('ramen')) return '🍣';
    if (c.contains('chinese') || c.contains('szechuan')) return '🥡';
    if (c.contains('dessert') || c.contains('bakery')) return '🍰';
    if (c.contains('indian') || c.contains('curry')) return '🍛';
    if (c.contains('mexican') || c.contains('taco')) return '🌮';
    if (c.contains('healthy') || c.contains('salad')) return '🥗';
    return '🍽';
  }
}
