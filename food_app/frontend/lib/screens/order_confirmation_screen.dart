import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _checkScale;
  late Animation<double> _checkFade;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _checkScale = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _checkController, curve: Curves.elasticOut));
    _checkFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _checkController, curve: const Interval(0, 0.3)));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.read<OrderProvider>();
    final order = orderProv.lastOrder;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating particles
              ...List.generate(12, (i) => _buildParticle(i)),

              // Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated check mark
                      ScaleTransition(
                        scale: _checkScale,
                        child: FadeTransition(
                          opacity: _checkFade,
                          child: ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: AppTheme.success.withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, 10)),
                                ],
                              ),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Order Confirmed! 🎉',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your order has been placed successfully.\nSit back and relax!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      // Order info
                      if (order != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.glassDecoration(borderRadius: 20, opacity: 0.06),
                          child: Column(
                            children: [
                              _infoRow('Order ID', '#${order['id']}'),
                              const SizedBox(height: 12),
                              _infoRow('Restaurant', order['restaurant_name'] ?? ''),
                              const SizedBox(height: 12),
                              _infoRow('Total', '\$${(order['total'] ?? 0).toStringAsFixed(2)}'),
                              const SizedBox(height: 12),
                              _infoRow('Status', (order['status'] ?? 'confirmed').toString().toUpperCase()),
                              const SizedBox(height: 16),
                              // Pulsing delivery time
                              ScaleTransition(
                                scale: _pulseAnim,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.access_time_rounded, color: AppTheme.primaryOrange, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Estimated: 30-40 min',
                                        style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                          child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/orders'),
                        child: const Text('View Order History', style: TextStyle(color: AppTheme.primaryOrange)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
      ],
    );
  }

  Widget _buildParticle(int index) {
    final rng = math.Random(index);
    final size = 6.0 + rng.nextDouble() * 8;
    final startX = rng.nextDouble() * MediaQuery.of(context).size.width;
    final colors = [AppTheme.primaryOrange, AppTheme.accentYellow, AppTheme.success, const Color(0xFFE040FB)];

    return AnimatedBuilder(
      animation: _particleController,
      builder: (ctx, _) {
        final progress = (_particleController.value + index * 0.08) % 1.0;
        final y = MediaQuery.of(context).size.height * (1 - progress);
        final x = startX + math.sin(progress * 4 * math.pi) * 30;
        final opacity = progress < 0.2 ? progress / 0.2 : progress > 0.8 ? (1 - progress) / 0.2 : 1.0;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
