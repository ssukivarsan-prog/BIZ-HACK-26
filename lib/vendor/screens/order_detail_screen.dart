import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

final vendorOrderDetailProvider = StreamProvider.family<OrderModel?, String>((ref, id) {
  return ref.read(orderServiceProvider).getOrderById(id);
});

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStream = ref.watch(vendorOrderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderStream.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order header card
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${orderId.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textGrey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppTheme.dividerColor, height: 1),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Customer',
                        value: order.customerName,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Phone',
                        value: order.customerPhone,
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Ordered',
                        value: DateFormat('dd MMM yyyy, hh:mm a').format(order.orderedAt),
                        icon: Icons.access_time_rounded,
                      ),
                      if (order.deliveryAddress != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Address',
                          value: order.deliveryAddress!,
                          icon: Icons.location_on_outlined,
                        ),
                      ],
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Notes',
                          value: order.notes!,
                          icon: Icons.note_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Items
                const Text('Ordered Items', style: AppTextStyles.heading3),
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
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  AppNetworkImage(
                                    imageUrl: item.imageUrl,
                                    category: item.category,
                                    width: 48,
                                    height: 48,
                                    borderRadius: 10,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.vegetableName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity}${item.unit} × ₹${item.pricePerUnit}/${item.unit}',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${item.totalPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.price,
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                  color: AppTheme.dividerColor, height: 1, indent: 14, endIndent: 14),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Status update
                if (order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled) ...[
                  const Text('Update Status', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  _StatusButtons(
                    currentStatus: order.status,
                    onUpdate: (status) async {
                      await ref.read(orderServiceProvider).updateOrderStatus(orderId, status);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order status updated to ${status.label}')),
                        );
                      }
                    },
                  ),
                ],
                const SizedBox(height: 60),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusButtons extends StatelessWidget {
  final OrderStatus currentStatus;
  final ValueChanged<OrderStatus> onUpdate;

  const _StatusButtons({required this.currentStatus, required this.onUpdate});

  static const _flow = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _flow.indexOf(currentStatus);
    return Column(
      children: [
        if (currentIdx < _flow.length - 1)
          ElevatedButton(
            onPressed: () => onUpdate(_flow[currentIdx + 1]),
            child: Text('Mark as ${_flow[currentIdx + 1].label}'),
          ),
        const SizedBox(height: 10),
        if (currentStatus != OrderStatus.cancelled)
          OutlinedButton(
            onPressed: () => onUpdate(OrderStatus.cancelled),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
              side: const BorderSide(color: AppTheme.errorRed),
            ),
            child: const Text('Cancel Order'),
          ),
      ],
    );
  }
}
