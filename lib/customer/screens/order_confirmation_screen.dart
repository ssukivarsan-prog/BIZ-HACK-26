// ─── Order Confirmation Screen ────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: AppTheme.primaryGreen,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 28),
              Text(
                'Order Placed!'.tr(ref),
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 12),
              Text(
                '${'Your order #'.tr(ref)}${orderId.substring(0, 8).toUpperCase()}${' has been placed successfully.'.tr(ref)}',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ).animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.push('/customer/track-order/$orderId'),
                icon: const Icon(Icons.local_shipping_outlined),
                label: Text('Track Order'.tr(ref)),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/customer'),
                child: Text('Continue Shopping'.tr(ref)),
              ).animate(delay: 600.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
