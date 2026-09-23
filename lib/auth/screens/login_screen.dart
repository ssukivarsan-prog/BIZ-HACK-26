import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = await ref.read(authServiceProvider).signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      
      if (user == null) {
        throw 'User data not found. Please create a new account.';
      }
      
      // GoRouter redirect will automatically navigate based on user.role
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Logo
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'FreshVeg',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 48),
              Text('Welcome Back!'.tr(ref), style: AppTextStyles.heading1)
                  .animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Please log in to continue'.tr(ref),
                style: AppTextStyles.subtitle,
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email Address'.tr(ref),
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required'.tr(ref);
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                          return 'Enter a valid email'.tr(ref);
                        }
                        return null;
                      },
                    ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password'.tr(ref),
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                            color: AppTheme.textGrey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required'.tr(ref);
                        return null;
                      },
                    ).animate(delay: 250.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPassword(),
                        child: Text(
                          'Forgot password?'.tr(ref),
                          style: const TextStyle(color: AppTheme.primaryGreen, fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Log In'.tr(ref)),
                    ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account? '.tr(ref), style: AppTextStyles.body),
                        GestureDetector(
                          onTap: () => context.push('/auth/signup'),
                          child: Text(
                            'Sign Up'.tr(ref),
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset Password'.tr(ref), style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Enter your email and we\'ll send a reset link.'.tr(ref),
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email Address'.tr(ref)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(authServiceProvider).resetPassword(ctrl.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reset link sent! Check your email.'.tr(ref))),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: Text('Send Reset Link'.tr(ref)),
            ),
          ],
        ),
      ),
    );
  }
}
