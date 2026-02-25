import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class MenuItemCard extends StatefulWidget {
  final Map<String, dynamic> menuItem;
  final VoidCallback onAddToCart;

  const MenuItemCard({super.key, required this.menuItem, required this.onAddToCart});

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleAddToCart() {
    _bounceController.forward().then((_) => _bounceController.reverse());
    widget.onAddToCart();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.menuItem;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.06),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: item['image_url'] ?? '',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(width: 90, height: 90, color: AppTheme.darkCard),
              errorWidget: (ctx, url, err) => Container(
                width: 90,
                height: 90,
                color: AppTheme.darkCard,
                child: const Icon(Icons.fastfood_rounded, color: AppTheme.textGrey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] ?? '',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textWhite),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item['is_popular'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] ?? '',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGrey, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${(item['price'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryOrange),
                    ),
                    // Animated add button
                    ScaleTransition(
                      scale: _bounceAnim,
                      child: GestureDetector(
                        onTap: _handleAddToCart,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primaryOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
