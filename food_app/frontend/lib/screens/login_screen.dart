import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'john@gmail.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController();
  bool _isLogin = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    String? error;
    if (_isLogin) {
      error = await auth.login(_emailController.text.trim(), _passwordController.text);
    } else {
      error = await auth.register(
          _nameController.text.trim(), _emailController.text.trim(), _passwordController.text);
    }
    if (mounted) {
      if (error == null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryOrange.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 24),
                      Text('Foodie', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textWhite)),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? 'Welcome back! Sign in to continue' : 'Create your account',
                        style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                      ),
                      const SizedBox(height: 40),

                      // Form
                      if (!_isLogin) ...[
                        _buildField(_nameController, 'Full Name', Icons.person_outline_rounded),
                        const SizedBox(height: 16),
                      ],
                      _buildField(_emailController, 'Email', Icons.email_outlined),
                      const SizedBox(height: 16),
                      _buildField(_passwordController, 'Password', Icons.lock_outline_rounded, obscure: true),
                      const SizedBox(height: 32),

                      // Submit Button
                      Consumer<AuthProvider>(
                        builder: (ctx, auth, _) => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(_isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Toggle
                      GestureDetector(
                        onTap: () => setState(() => _isLogin = !_isLogin),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
                            children: [
                              TextSpan(text: _isLogin ? "Don't have an account? " : 'Already have an account? '),
                              TextSpan(
                                text: _isLogin ? 'Sign Up' : 'Sign In',
                                style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return Container(
      decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.06),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: AppTheme.textWhite),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.textGrey, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
