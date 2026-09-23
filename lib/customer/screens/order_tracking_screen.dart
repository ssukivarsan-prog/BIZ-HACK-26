import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';

final orderTrackingProvider = StreamProvider.family<OrderModel?, String>((ref, id) {
  return ref.read(orderServiceProvider).getOrderById(id);
});

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  static const _stepLabels = [
    'Order Placed',
    'Confirmed',
    'Preparing',
    'Out for Delivery',
    'Delivered',
  ];

  static const _stepIcons = [
    Icons.receipt_long_outlined,
    Icons.check_circle_outline_rounded,
    Icons.kitchen_outlined,
    Icons.local_shipping_outlined,
    Icons.home_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStream = ref.watch(orderTrackingProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order'.tr(ref)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderStream.when(
        data: (order) {
          if (order == null) return Center(child: Text('Order not found'.tr(ref)));
          if (order.status == OrderStatus.cancelled) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_outlined, size: 64, color: AppTheme.errorRed),
                  const SizedBox(height: 16),
                  Text('Order Cancelled'.tr(ref), style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(
                    '${'Order #'.tr(ref)}${orderId.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            );
          }

          final currentStep = _steps.indexOf(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID chip
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      '${'Order #'.tr(ref)}${orderId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Stepper
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    children: List.generate(_steps.length, (i) {
                      final isDone = i < currentStep;
                      final isCurrent = i == currentStep;
                      final isLast = i == _steps.length - 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppTheme.primaryGreen
                                      : isCurrent
                                          ? AppTheme.primaryGreen.withOpacity(0.15)
                                          : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: isCurrent
                                      ? Border.all(color: AppTheme.primaryGreen, width: 2)
                                      : null,
                                ),
                                child: Icon(
                                  _stepIcons[i],
                                  size: 20,
                                  color: isDone
                                      ? Colors.white
                                      : isCurrent
                                          ? AppTheme.primaryGreen
                                          : AppTheme.textGrey,
                                ),
                              ),
                              if (!isLast)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 2,
                                  height: 36,
                                  color: isDone ? AppTheme.primaryGreen : AppTheme.dividerColor,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _stepLabels[i].tr(ref),
                                    style: TextStyle(
                                      fontWeight: isCurrent || isDone
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: isDone || isCurrent
                                          ? AppTheme.textDark
                                          : AppTheme.textGrey,
                                    ),
                                  ),
                                  if (isCurrent)
                                    Text(
                                      'Current status'.tr(ref),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.primaryGreen,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  SizedBox(height: isLast ? 0 : 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Order summary
                Text('Order Summary'.tr(ref), style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      ...order.items.asMap().entries.map((e) {
                        final item = e.value;
                        final isLast = e.key == order.items.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.vegetableName} × ${item.quantity}${item.unit}',
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                  Text('₹${item.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.price),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1, color: AppTheme.dividerColor, indent: 14, endIndent: 14),
                          ],
                        );
                      }),
                      const Divider(height: 1, color: AppTheme.dividerColor),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total'.tr(ref), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Poppins')),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textGrey),
                      const SizedBox(width: 8),
                      Text(
                        '${'Ordered on '.tr(ref)}${DateFormat('dd MMM yyyy, hh:mm a').format(order.orderedAt)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Cancel Order'.tr(ref), style: AppTextStyles.heading3),
                            content: Text('Are you sure you want to cancel this order?'.tr(ref)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('No'.tr(ref))),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('Yes, Cancel'.tr(ref), style: const TextStyle(color: AppTheme.errorRed)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await ref.read(orderServiceProvider).updateOrderStatus(orderId, OrderStatus.cancelled);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order cancelled successfully'.tr(ref))),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel Order'.tr(ref), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
                const SizedBox(height: 60),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${'Error: '.tr(ref)}$e')),
      ),
    );
  }
}
