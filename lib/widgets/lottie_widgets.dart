import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum AppAnimation {
  loading,
  success,
  emptyCart,
  emptyOrders,
  delivery,
}

extension AppAnimationX on AppAnimation {
  String get path {
    switch (this) {
      case AppAnimation.loading:
        return 'assets/animations/loading.json';
      case AppAnimation.success:
        return 'assets/animations/success.json';
      case AppAnimation.emptyCart:
        return 'assets/animations/empty_cart.json';
      case AppAnimation.emptyOrders:
        return 'assets/animations/empty_orders.json';
      case AppAnimation.delivery:
        return 'assets/animations/delivery.json';
    }
  }
}

/// Plays a Lottie animation from assets/animations/.
/// Falls back gracefully to an icon if the asset isn't found.
class AppLottie extends StatelessWidget {
  final AppAnimation animation;
  final double size;
  final bool repeat;
  final bool autoPlay;

  const AppLottie({
    super.key,
    required this.animation,
    this.size = 200,
    this.repeat = true,
    this.autoPlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        animation.path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: repeat,
        animate: autoPlay,
        errorBuilder: (context, error, _) => Icon(
          _fallbackIcon,
          size: size * 0.5,
          color: const Color(0xFF4CAF50),
        ),
      ),
    );
  }

  IconData get _fallbackIcon {
    switch (animation) {
      case AppAnimation.loading:
        return Icons.hourglass_empty_rounded;
      case AppAnimation.success:
        return Icons.check_circle_outline_rounded;
      case AppAnimation.emptyCart:
        return Icons.shopping_cart_outlined;
      case AppAnimation.emptyOrders:
        return Icons.receipt_long_outlined;
      case AppAnimation.delivery:
        return Icons.local_shipping_outlined;
    }
  }
}

/// One-shot success animation — plays once then stays on last frame.
class SuccessAnimation extends StatelessWidget {
  final double size;
  const SuccessAnimation({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return AppLottie(
      animation: AppAnimation.success,
      size: size,
      repeat: false,
    );
  }
}

/// Looping delivery animation for the tracking screen.
class DeliveryAnimation extends StatelessWidget {
  final double size;
  const DeliveryAnimation({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AppLottie(
      animation: AppAnimation.delivery,
      size: size,
      repeat: true,
    );
  }
}
