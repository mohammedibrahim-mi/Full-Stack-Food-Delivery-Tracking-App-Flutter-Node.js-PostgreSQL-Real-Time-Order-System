import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _ringController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)));

    _textFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
    // if (auth.isLoggedIn) {
    //   Navigator.pushReplacementNamed(context, '/home');
    // } else {
    //   Navigator.pushReplacementNamed(context, '/login');
    // }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating food ring
                    AnimatedBuilder(
                      animation: _ringController,
                      builder: (ctx, child) {
                        return Transform.rotate(
                          angle: _ringController.value * 2 * math.pi,
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: Stack(
                              children: [
                                _foodEmoji('🍕', 0),
                                _foodEmoji('🍔', 1),
                                _foodEmoji('🍣', 2),
                                _foodEmoji('🌮', 3),
                                _foodEmoji('🍰', 4),
                                _foodEmoji('🥗', 5),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Logo center
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryOrange.withValues(alpha: 0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: const Column(
                    children: [
                      Text(
                        'Foodie',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textWhite,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Delicious food, delivered fast',
                        style: TextStyle(fontSize: 14, color: AppTheme.textGrey, letterSpacing: 1),
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

  Widget _foodEmoji(String emoji, int index) {
    const double radius = 80;
    final angle = (index * 60) * math.pi / 180;
    return Positioned(
      left: 90 + radius * math.cos(angle) - 14,
      top: 90 + radius * math.sin(angle) - 14,
      child: Transform.rotate(
        angle: -_ringController.value * 2 * math.pi,
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}
