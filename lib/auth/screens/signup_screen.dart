import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = await ref.read(authServiceProvider).signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _selectedRole,
      );
      if (!mounted) return;
      // GoRouter redirect will automatically navigate based on user role
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account'.tr(ref), style: AppTextStyles.heading1)
                  .animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Join us to buy or sell fresh veggies'.tr(ref),
                style: AppTextStyles.subtitle,
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 32),
              // Role selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _RoleTab(
                      label: 'Customer'.tr(ref),
                      icon: Icons.person_outline,
                      isSelected: _selectedRole == UserRole.customer,
                      onTap: () => setState(() => _selectedRole = UserRole.customer),
                    ),
                    _RoleTab(
                      label: 'Vendor'.tr(ref),
                      icon: Icons.storefront_outlined,
                      isSelected: _selectedRole == UserRole.vendor,
                      onTap: () => setState(() => _selectedRole = UserRole.vendor),
                    ),
                  ],
                ),
              ).animate(delay: 150.ms).fadeIn(),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Full Name'.tr(ref),
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Name is required'.tr(ref) : null,
                    ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 14),
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
                    ).animate(delay: 250.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Phone Number'.tr(ref),
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Phone is required'.tr(ref);
                        if (v.length < 10) return 'Enter a valid phone number'.tr(ref);
                        return null;
                      },
                    ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signup(),
                      decoration: InputDecoration(
                        labelText: 'Password (min. 6 characters)'.tr(ref),
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
                        if (v.length < 6) return 'Minimum 6 characters'.tr(ref);
                        return null;
                      },
                    ).animate(delay: 350.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Create Account'.tr(ref)),
                    ).animate(delay: 400.ms).fadeIn(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? '.tr(ref), style: AppTextStyles.body),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Log in here'.tr(ref),
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ).animate(delay: 450.ms).fadeIn(),
                    const SizedBox(height: 32),
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

class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
