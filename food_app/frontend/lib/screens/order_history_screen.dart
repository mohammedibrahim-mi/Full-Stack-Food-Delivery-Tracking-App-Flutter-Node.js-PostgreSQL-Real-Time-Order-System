import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return AppTheme.primaryOrange;
      case 'preparing': return AppTheme.accentYellow;
      case 'on_the_way': return const Color(0xFF2196F3);
      case 'delivered': return AppTheme.success;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.textGrey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmed': return Icons.check_circle_outline_rounded;
      case 'preparing': return Icons.restaurant_rounded;
      case 'on_the_way': return Icons.delivery_dining_rounded;
      case 'delivered': return Icons.done_all_rounded;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.pending_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
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
      body: Consumer<OrderProvider>(
        builder: (ctx, op, _) {
          if (op.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          }

          if (op.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📋', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                  const SizedBox(height: 8),
                  Text('Your order history will appear here', style: TextStyle(color: AppTheme.textGrey)),
                ],
              ),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: op.orders.length,
              itemBuilder: (ctx, i) {
                final order = op.orders[i];
                final status = (order['status'] ?? 'pending').toString();
                final items = order['items'] as List<dynamic>? ?? [];

                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassDecoration(borderRadius: 20, opacity: 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order['id']}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_statusIcon(status), size: 14, color: _statusColor(status)),
                                      const SizedBox(width: 4),
                                      Text(
                                        status.replaceAll('_', ' ').toUpperCase(),
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(status)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order['restaurant_name'] ?? 'Restaurant',
                              style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                            ),
                            const SizedBox(height: 12),
                            // Items
                            ...items.take(3).map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Text('${item['quantity']}x ', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600, fontSize: 13)),
                                  Expanded(child: Text(item['name'] ?? '', style: TextStyle(color: AppTheme.textGrey, fontSize: 13))),
                                  Text('\$${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13)),
                                ],
                              ),
                            )),
                            if (items.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('+${items.length - 3} more items', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                              ),
                            const Divider(color: Colors.white12, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order['created_at']?.toString().substring(0, 10) ?? '',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                                ),
                                Text(
                                  'Total: \$${(order['total'] ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryOrange),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
