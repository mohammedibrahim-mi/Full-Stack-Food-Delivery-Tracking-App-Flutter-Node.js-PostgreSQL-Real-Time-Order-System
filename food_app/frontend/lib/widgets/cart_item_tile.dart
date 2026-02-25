import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final menuItem = item['menuItem'] ?? {};
    final qty = item['quantity'] ?? 1;
    final price = (menuItem['price'] ?? 0).toDouble();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.06),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: menuItem['image_url'] ?? '',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(width: 72, height: 72, color: AppTheme.darkCard),
              errorWidget: (ctx, url, err) => Container(
                width: 72,
                height: 72,
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
                Text(
                  menuItem['name'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  menuItem['restaurant']?['name'] ?? '',
                  style: TextStyle(fontSize: 11, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${(price * qty).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryOrange),
                    ),
                    // Quantity stepper
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _stepperBtn(Icons.remove_rounded, onDecrease),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                            child: Container(
                              key: ValueKey<int>(qty),
                              width: 32,
                              alignment: Alignment.center,
                              child: Text('$qty', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                            ),
                          ),
                          _stepperBtn(Icons.add_rounded, onIncrease),
                        ],
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

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryOrange, size: 18),
      ),
    );
  }
}
