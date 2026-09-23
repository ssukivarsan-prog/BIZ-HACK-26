import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_router.dart';
import '../../l10n/app_translations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        ref.read(splashReadyProvider.notifier).state = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            const Text(
              'FreshVeg',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: -0.5,
              ),
            )
                .animate(delay: 300.ms)
                .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Fresh from farm to your table'.tr(ref),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 500.ms),
            const SizedBox(height: 60),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                strokeWidth: 2,
              ),
            ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
