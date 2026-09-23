import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../models/order_model.dart';

// ─── Loading Shimmer ─────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─── App Cached Image ─────────────────────────────────────────────────────────
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? category;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const AppNetworkImage({
    super.key,
    this.imageUrl,
    this.category,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _PlaceholderImage(
        width: width,
        height: height,
        borderRadius: borderRadius,
        category: category,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) =>
            ShimmerBox(width: width, height: height, radius: borderRadius),
        errorWidget: (_, __, ___) =>
            _PlaceholderImage(width: width, height: height, borderRadius: borderRadius, category: category),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final String? category;

  const _PlaceholderImage({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.category,
  });

  String _getCategoryAsset(String? category) {
    switch (category) {
      case 'Leafy Greens':
        return 'assets/images/categories/leafy_greens.png';
      case 'Root Vegetables':
        return 'assets/images/categories/root_vegetables.png';
      case 'Gourds & Melons':
        return 'assets/images/categories/gourds_melons.png';
      case 'Beans & Pods':
        return 'assets/images/categories/beans_pods.png';
      case 'Herbs & Spices':
        return 'assets/images/categories/herbs_spices.png';
      case 'Exotic':
        return 'assets/images/categories/exotic.png';
      default:
        return 'assets/images/categories/general.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        _getCategoryAsset(category),
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}

// ─── Order Status Badge ────────────────────────────────────────────────────────
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _statusProps(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  (Color, Color, String) _statusProps(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return (
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100),
          'Pending',
        );
      case OrderStatus.confirmed:
        return (
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
          'Confirmed',
        );
      case OrderStatus.preparing:
        return (
          const Color(0xFFF3E5F5),
          const Color(0xFF6A1B9A),
          'Preparing',
        );
      case OrderStatus.outForDelivery:
        return (
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
          'Out for Delivery',
        );
      case OrderStatus.delivered:
        return (
          const Color(0xFFE8F5E9),
          const Color(0xFF1B5E20),
          'Delivered',
        );
      case OrderStatus.cancelled:
        return (
          const Color(0xFFFFEBEE),
          const Color(0xFFC62828),
          'Cancelled',
        );
    }
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(icon, size: 40, color: AppTheme.lightGreen),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: onButton,
                  child: Text(buttonLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card (for vendor dashboard) ─────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ─── Custom Search Bar ────────────────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged?.call('');
                },
                child: const Icon(Icons.close, color: AppTheme.textGrey, size: 18),
              )
            : null,
      ),
    );
  }
}
