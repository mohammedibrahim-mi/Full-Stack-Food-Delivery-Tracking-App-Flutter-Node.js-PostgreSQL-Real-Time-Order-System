import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class RestaurantCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;

  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
      
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.darkCard,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'restaurant_${r['id']}',
                      child: CachedNetworkImage(
                        imageUrl: r['image_url'] ?? '',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(
                          height: 160,
                          color: AppTheme.darkCard,
                          child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange, strokeWidth: 2)),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          height: 160,
                          color: AppTheme.darkCard,
                          child: const Icon(Icons.restaurant, color: AppTheme.textGrey, size: 48),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(decoration: const BoxDecoration(gradient: AppTheme.heroGradient)),
                    ),
                    // Featured badge
                    if (r['is_featured'] == true)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Featured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    // Rating badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: AppTheme.glassDecoration(borderRadius: 8, opacity: 0.25),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.accentYellow, size: 16),
                            const SizedBox(width: 3),
                            Text('${r['rating'] ?? 4.0}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                    const SizedBox(height: 4),
                    Text(r['cuisine'] ?? '', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: AppTheme.textGrey, size: 14),
                        const SizedBox(width: 4),
                        Text(r['delivery_time'] ?? '30 min', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                        const SizedBox(width: 16),
                        Icon(Icons.delivery_dining_rounded, color: AppTheme.textGrey, size: 14),
                        const SizedBox(width: 4),
                        Text('\$${r['delivery_fee'] ?? 0}', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                        const SizedBox(width: 16),
                        Text('Min \$${r['min_order'] ?? 0}', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
