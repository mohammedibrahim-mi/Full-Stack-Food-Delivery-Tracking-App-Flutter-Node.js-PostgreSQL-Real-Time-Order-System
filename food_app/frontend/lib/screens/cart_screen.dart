import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: AppTheme.glassDecoration(borderRadius: 12, opacity: 0.08),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (ctx, cart, _) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.darkCard,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Clear Cart?', style: TextStyle(color: AppTheme.textWhite)),
                      content: const Text('Remove all items from your cart?', style: TextStyle(color: AppTheme.textGrey)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Clear', style: TextStyle(color: AppTheme.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<CartProvider>().clearCart();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          }

          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                  const SizedBox(height: 8),
                  Text('Browse restaurants to add items', style: TextStyle(color: AppTheme.textGrey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/restaurants'),
                    child: const Text('Browse Restaurants'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    return Dismissible(
                      key: Key('cart_${item['id']}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_rounded, color: AppTheme.error, size: 28),
                      ),
                      onDismissed: (_) => cart.removeItem(item['id']),
                      child: CartItemTile(
                        item: item,
                        onIncrease: () => cart.updateItemQuantity(item['id'], item['quantity'] + 1),
                        onDecrease: () => cart.updateItemQuantity(item['id'], item['quantity'] - 1),
                      ),
                    );
                  },
                ),
              ),

              // Order summary
              SlideTransition(
                position: _bottomSlide,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 20),
                      _summaryRow('Subtotal', '\$${cart.total.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _summaryRow('Delivery Fee', '\$2.99'),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 8),
                      _summaryRow('Total', '\$${(cart.total + 2.99).toStringAsFixed(2)}', bold: true),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Consumer<OrderProvider>(
                          builder: (ctx, orderProv, _) => ElevatedButton(
                            onPressed: orderProv.isLoading
                                ? null
                                : () async {
                                    final nav = Navigator.of(context);
                                    final success = await orderProv.placeOrder(deliveryAddress: '123 Foodie Street');
                                    if (success && context.mounted) {
                                      cart.clearCart();
                                      nav.pushNamed('/order-confirmation');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: orderProv.isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: bold ? 18 : 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: bold ? AppTheme.textWhite : AppTheme.textGrey,
        )),
        Text(value, style: TextStyle(
          fontSize: bold ? 20 : 14,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          color: bold ? AppTheme.primaryOrange : AppTheme.textWhite,
        )),
      ],
    );
  }
}
