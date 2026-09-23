import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';

final vendorOrderDetailProvider = StreamProvider.family<OrderModel?, String>((ref, id) {
  return ref.read(orderServiceProvider).getOrderById(id);
});

class VendorOrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const VendorOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStream = ref.watch(vendorOrderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'.tr(ref)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderStream.when(
        data: (order) {
          if (order == null) return Center(child: Text('Order not found'.tr(ref)));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'Order #'.tr(ref)}${order.id.substring(0, 8).toUpperCase()}',
                      style: AppTextStyles.heading2,
                    ),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(order.orderedAt),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 24),

                // Customer Info
                Text('Customer Details'.tr(ref), style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 20, color: AppTheme.primaryGreen),
                          const SizedBox(width: 12),
                          Text(order.customerName, style: AppTextStyles.body),
                        ],
                      ),
                      const Divider(height: 24, color: AppTheme.dividerColor),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 20, color: AppTheme.primaryGreen),
                          const SizedBox(width: 12),
                          Text(order.customerPhone, style: AppTextStyles.body),
                        ],
                      ),
                      if (order.deliveryAddress != null) ...[
                        const Divider(height: 24, color: AppTheme.dividerColor),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 20, color: AppTheme.primaryGreen),
                            const SizedBox(width: 12),
                            Expanded(child: Text(order.deliveryAddress!, style: AppTextStyles.body)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Order Items
                Text('Order Items'.tr(ref), style: AppTextStyles.heading3),
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
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  AppNetworkImage(
                                    imageUrl: item.imageUrl,
                                    category: item.category,
                                    width: 50,
                                    height: 50,
                                    borderRadius: 10,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.vegetableName,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                                        ),
                                        Text(
                                          '₹${item.pricePerUnit}/${item.unit.tr(ref)} × ${item.quantity}',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1, color: AppTheme.dividerColor),
                          ],
                        );
                      }),
                      const Divider(height: 1, color: AppTheme.dividerColor),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount'.tr(ref), style: AppTextStyles.heading3),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
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
                if (order.notes != null) ...[
                  const SizedBox(height: 24),
                  Text('Customer Notes'.tr(ref), style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Text(
                      order.notes!,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFFF57F17)),
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Status Update Buttons
                if (order.status != OrderStatus.cancelled && order.status != OrderStatus.delivered) ...[
                  Text('Update Status'.tr(ref), style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  _StatusUpdater(order: order),
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

class _StatusUpdater extends ConsumerWidget {
  final OrderModel order;
  const _StatusUpdater({required this.order});

  static const _nextStatuses = {
    OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
    OrderStatus.confirmed: [OrderStatus.preparing, OrderStatus.cancelled],
    OrderStatus.preparing: [OrderStatus.outForDelivery],
    OrderStatus.outForDelivery: [OrderStatus.delivered],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = _nextStatuses[order.status] ?? [];
    if (options.isEmpty) return const SizedBox();

    return Row(
      children: options.map((status) {
        final isCancel = status == OrderStatus.cancelled;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: status == options.last ? 0 : 12),
            child: ElevatedButton(
              onPressed: () {
                ref.read(orderServiceProvider).updateOrderStatus(order.id, status);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${'Order marked as '.tr(ref)}${status.label.tr(ref)}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCancel ? AppTheme.errorRed : AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(status.label.tr(ref)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
