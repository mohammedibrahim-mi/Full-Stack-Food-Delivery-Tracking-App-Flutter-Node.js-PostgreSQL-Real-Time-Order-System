import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
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
        title: const Text('Profile'),
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
      body: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          final user = auth.user;
          return SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animated avatar
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (ctx, value, child) => Transform.scale(scale: value, child: child),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryOrange.withValues(alpha: 0.4), blurRadius: 30),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (user?['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?['name'] ?? 'User',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
                    ),
                    const SizedBox(height: 4),
                    Text(user?['email'] ?? '', style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
                    const SizedBox(height: 32),

                    // Settings cards
                    _settingsTile(Icons.person_outline_rounded, 'Edit Profile', 'Name, email, phone'),
                    _settingsTile(Icons.location_on_outlined, 'Addresses', 'Manage delivery addresses'),
                    _settingsTile(Icons.payment_rounded, 'Payment Methods', 'Cards, wallets'),
                    _settingsTile(Icons.notifications_outlined, 'Notifications', 'Push, email preferences'),
                    _settingsTile(Icons.help_outline_rounded, 'Help & Support', 'FAQ, contact us'),
                    _settingsTile(Icons.info_outline_rounded, 'About', 'App version 2.0.0'),
                    const SizedBox(height: 20),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          await auth.logout();
                          if (context.mounted) {
                            nav.pushNamedAndRemoveUntil('/login', (_) => false);
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                        label: const Text('Logout', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.06),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryOrange, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
