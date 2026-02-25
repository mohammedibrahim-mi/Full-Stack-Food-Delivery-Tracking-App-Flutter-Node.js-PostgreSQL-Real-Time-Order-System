import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/restaurant_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _headerAnimController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _headerFade = CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadAllData();
      context.read<CartProvider>().loadCart();
      _headerAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<RestaurantProvider>(
          builder: (ctx, rp, _) {
            if (rp.isLoading && rp.restaurants.isEmpty) {
              return _buildShimmerLoading();
            }
            return RefreshIndicator(
              color: AppTheme.primaryOrange,
              onRefresh: () => rp.loadAllData(),
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _headerSlide,
                      child: FadeTransition(
                        opacity: _headerFade,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hey, Foodie! 👋',
                                        style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'What would you\nlike to eat?',
                                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textWhite, height: 1.2),
                                      ),
                                    ],
                                  ),
                                  
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                    children: [
                                      // Map button
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(context, '/map'),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.08),
                                          child: const Icon(Icons.map_rounded, color: AppTheme.primaryOrange, size: 24),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Cart badge
                                      Consumer<CartProvider>(
                                        builder: (ctx, cart, _) => GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, '/cart'),
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.08),
                                            child: Stack(
                                              children: [
                                                const Center(child: Icon(Icons.shopping_bag_rounded, color: AppTheme.textWhite, size: 24)),
                                                if (cart.itemCount > 0)
                                                  Positioned(
                                                    right: 6,
                                                    top: 6,
                                                    child: Container(
                                                      width: 18,
                                                      height: 18,
                                                      decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                                                      child: Center(
                                                        child: Text('${cart.itemCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(context, '/profile'),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.primaryGradient,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                              // Animated search bar
                              Container(
                                decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.06),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) => rp.setSearchQuery(v),
                                  style: const TextStyle(color: AppTheme.textWhite),
                                  decoration: InputDecoration(
                                    hintText: 'Search restaurants, cuisines...',
                                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textGrey),
                                    suffixIcon: rp.searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close, color: AppTheme.textGrey),
                                            onPressed: () {
                                              _searchController.clear();
                                              rp.setSearchQuery('');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Categories
                  if (rp.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 105,
                              child: AnimationLimiter(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: rp.categories.length,
                                  itemBuilder: (ctx, i) => AnimationConfiguration.staggeredList(
                                    position: i,
                                    duration: const Duration(milliseconds: 400),
                                    child: SlideAnimation(
                                      horizontalOffset: 50,
                                      child: FadeInAnimation(
                                        child: CategoryCard(
                                          category: rp.categories[i],
                                          onTap: () {
                                            Navigator.pushNamed(context, '/restaurants', arguments: rp.categories[i]['id']);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Featured
                  if (rp.featuredRestaurants.isNotEmpty && rp.searchQuery.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Featured 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/restaurants'),
                              child: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260,
                        child: AnimationLimiter(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: rp.featuredRestaurants.length,
                            itemBuilder: (ctx, i) {
                              final r = rp.featuredRestaurants[i];
                              return AnimationConfiguration.staggeredList(
                                position: i,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  horizontalOffset: 80,
                                  child: FadeInAnimation(
                                    child: Container(
                                      width: 260,
                                      margin: const EdgeInsets.only(right: 16),
                                      child: RestaurantCard(
                                        restaurant: r,
                                        onTap: () => Navigator.pushNamed(context, '/restaurant-detail', arguments: r['id']),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],

                  // All / Filtered
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Text(
                        rp.searchQuery.isEmpty ? 'All Restaurants' : 'Results',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final r = rp.filteredRestaurants[i];
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
                        childCount: rp.filteredRestaurants.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(0),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppTheme.shimmerBase,
      highlightColor: AppTheme.shimmerHighlight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 10),
            Container(width: 160, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 24),
            Container(width: double.infinity, height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 24),
            Row(children: List.generate(4, (_) => Expanded(child: Container(height: 90, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))))),
            const SizedBox(height: 24),
            ...List.generate(3, (_) => Container(width: double.infinity, height: 200, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(int current) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: BottomNavigationBar(
        currentIndex: current,
        backgroundColor: Colors.transparent,
        elevation: 0,
        onTap: (i) {
          if (i == current) return;
          switch (i) {
            case 0: Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); break;
            case 1: Navigator.pushNamed(context, '/restaurants'); break;
            case 2: Navigator.pushNamed(context, '/cart'); break;
            case 3: Navigator.pushNamed(context, '/orders'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
        ],
      ),
    );
  }
}
