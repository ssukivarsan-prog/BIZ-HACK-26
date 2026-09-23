import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../l10n/app_translations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_done') ?? false);
  }

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go(AppConstants.routeLogin);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardPage(
        icon: Icons.eco_rounded,
        iconColor: AppTheme.primaryGreen,
        title: 'Fresh Every Day'.tr(ref),
        subtitle: 'Get farm-fresh vegetables delivered straight to your doorstep, harvested the same morning.'.tr(ref),
      ),
      _OnboardPage(
        icon: Icons.shopping_cart_rounded,
        iconColor: AppTheme.accentOrange,
        title: 'Order in Seconds'.tr(ref),
        subtitle: "Browse today's stock, pick your quantities, and place an order in just a few taps.".tr(ref),
      ),
      _OnboardPage(
        icon: Icons.local_shipping_rounded,
        iconColor: const Color(0xFF1565C0),
        title: 'Track in Real Time'.tr(ref),
        subtitle: 'Watch your order move from confirmed → packed → on its way, every step of the journey.'.tr(ref),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip'.tr(ref),
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: pages.length,
                itemBuilder: (ctx, i) => pages[i],
              ),
            ),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? AppTheme.primaryGreen : AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_page < pages.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finish();
                  }
                },
                child: Text(_page < pages.length - 1 ? 'Next'.tr(ref) : 'Get Started'.tr(ref)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: iconColor),
          )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 40),
          Text(
            title,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }
}
