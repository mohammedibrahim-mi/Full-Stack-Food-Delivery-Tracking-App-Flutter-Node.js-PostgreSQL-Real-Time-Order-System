import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/restaurant_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/restaurant_card.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> with SingleTickerProviderStateMixin {
  int? _categoryFilter;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _categoryFilter = args;
        context.read<RestaurantProvider>().loadRestaurants(categoryId: args);
      } else {
        context.read<RestaurantProvider>().loadRestaurants();
      }
      context.read<RestaurantProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: AppTheme.glassDecoration(borderRadius: 12, opacity: 0.08),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RestaurantProvider>(
        builder: (ctx, rp, _) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // Filter chips
                if (rp.categories.isNotEmpty)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rp.categories.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == 0) {
                          return _buildChip('All', _categoryFilter == null, () {
                            setState(() => _categoryFilter = null);
                            rp.loadRestaurants();
                          });
                        }
                        final cat = rp.categories[i - 1];
                        final catId = cat['id'];
                        return _buildChip(
                          '${cat['icon']} ${cat['name']}',
                          _categoryFilter == catId,
                          () {
                            setState(() => _categoryFilter = catId);
                            rp.loadRestaurants(categoryId: catId);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                // Restaurant list
                Expanded(
                  child: rp.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                      : rp.restaurants.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🍽', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 12),
                                  Text('No restaurants found', style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
                                ],
                              ),
                            )
                          : AnimationLimiter(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: rp.restaurants.length,
                                itemBuilder: (ctx, i) {
                                  final r = rp.restaurants[i];
                                  return AnimationConfiguration.staggeredList(
                                    position: i,
                                    duration: const Duration(milliseconds: 400),
                                    child: SlideAnimation(
                                      verticalOffset: 50,
                                      child: FadeInAnimation(
                                        child: RestaurantCard(
                                          restaurant: r,
                                          onTap: () => Navigator.pushNamed(context, '/restaurant-detail', arguments: r['id']),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: onTap,
          child: Chip(
            label: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textGrey,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
            backgroundColor: selected ? AppTheme.primaryOrange : AppTheme.darkCard,
            side: BorderSide(color: selected ? AppTheme.primaryOrange : Colors.white12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
