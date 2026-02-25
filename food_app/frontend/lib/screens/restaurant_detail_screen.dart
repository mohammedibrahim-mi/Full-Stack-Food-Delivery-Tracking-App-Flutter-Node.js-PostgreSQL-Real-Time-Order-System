import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/restaurant_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/menu_item_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      if (id != null) {
        context.read<RestaurantProvider>().loadRestaurantDetail(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantProvider>(
        builder: (ctx, rp, _) {
          if (rp.isLoading || rp.selectedRestaurant == null) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          }

          final r = rp.selectedRestaurant!;
          final menuItems = rp.menuItems;

          return CustomScrollView(
            slivers: [
              // Hero image with SliverAppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.deepBlack,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: AppTheme.glassDecoration(borderRadius: 12, opacity: 0.2),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'restaurant_${r['id']}',
                        child: CachedNetworkImage(
                          imageUrl: r['image_url'] ?? '',
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(color: AppTheme.darkCard),
                          errorWidget: (ctx, url, err) => Container(
                            color: AppTheme.darkCard,
                            child: const Icon(Icons.restaurant, color: AppTheme.textGrey, size: 60),
                          ),
                        ),
                      ),
                      Container(decoration: const BoxDecoration(gradient: AppTheme.heroGradient)),
                    ],
                  ),
                ),
              ),

              // Restaurant info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name'] ?? '',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r['cuisine'] ?? '',
                        style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                      ),
                      const SizedBox(height: 16),
                      // Info row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoItem(Icons.star_rounded, '${r['rating'] ?? 4.0}', 'Rating', AppTheme.accentYellow),
                            _divider(),
                            _infoItem(Icons.access_time_rounded, r['delivery_time'] ?? '30 min', 'Delivery', AppTheme.primaryOrange),
                            _divider(),
                            _infoItem(Icons.delivery_dining_rounded, '\$${r['delivery_fee'] ?? 0}', 'Fee', AppTheme.success),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              // Menu items
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final item = menuItems[i];
                      return AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: MenuItemCard(
                              menuItem: item,
                              onAddToCart: () {
                                context.read<CartProvider>().addItem(item['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item['name']} added to cart!'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: menuItems.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      // Floating cart button
      floatingActionButton: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.itemCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            backgroundColor: AppTheme.primaryOrange,
            icon: const Icon(Icons.shopping_bag_rounded),
            label: Text('Cart (${cart.itemCount})', style: const TextStyle(fontWeight: FontWeight.w600)),
          );
        },
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.white12);
  }
}
