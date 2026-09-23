import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';

class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen> {
  OrderStatus? _filterStatus;

  static const _filters = [
    (label: 'All', status: null),
    (label: 'Pending', status: OrderStatus.pending),
    (label: 'Confirmed', status: OrderStatus.confirmed),
    (label: 'Preparing', status: OrderStatus.preparing),
    (label: 'Delivered', status: OrderStatus.delivered),
    (label: 'Cancelled', status: OrderStatus.cancelled),
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Orders'.tr(ref))),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _filterStatus == f.status;
                return ChoiceChip(
                  label: Text(f.label.tr(ref)),
                  selected: selected,
                  onSelected: (_) => setState(() => _filterStatus = f.status),
                  selectedColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppTheme.textGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filtered = _filterStatus == null
                    ? orders
                    : orders.where((o) => o.status == _filterStatus).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No orders found'.tr(ref),
                    subtitle: _filterStatus == null
                        ? 'Customer orders will appear here'.tr(ref)
                        : 'No ${_filterStatus!.label.toLowerCase()} orders'.tr(ref),
                    icon: Icons.receipt_long_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _OrderCard(
                    order: filtered[i],
                    onTap: () => context.push('/vendor/order/${filtered[i].id}'),
                    onStatusChange: (status) =>
                        ref.read(orderServiceProvider).updateOrderStatus(filtered[i].id, status),
                  ).animate(delay: Duration(milliseconds: i * 40)).fadeIn().slideY(begin: 0.1),
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const ShimmerBox(height: 110),
              ),
              error: (e, _) => Center(child: Text('${'Error: '.tr(ref)}$e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final ValueChanged<OrderStatus> onStatusChange;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Poppins'),
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(order.orderedAt),
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 10),
            Text(
              order.items.map((i) => '${i.vegetableName} × ${i.quantity}${i.unit}').join(', '),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textGrey,
                fontFamily: 'Poppins',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.price,
                ),
                if (order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled)
                  _StatusDropdown(
                    currentStatus: order.status,
                    onChanged: onStatusChange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDropdown extends ConsumerWidget {
  final OrderStatus currentStatus;
  final ValueChanged<OrderStatus> onChanged;

  const _StatusDropdown({required this.currentStatus, required this.onChanged});

  static const _nextStatuses = {
    OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
    OrderStatus.confirmed: [OrderStatus.preparing, OrderStatus.cancelled],
    OrderStatus.preparing: [OrderStatus.outForDelivery],
    OrderStatus.outForDelivery: [OrderStatus.delivered],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = _nextStatuses[currentStatus] ?? [];
    if (options.isEmpty) return const SizedBox();

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryGreen),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus>(
          value: null,
          hint: Text(
            'Update'.tr(ref),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: AppTheme.primaryGreen),
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          items: options
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.label.tr(ref),
                        style: const TextStyle(fontSize: 13, fontFamily: 'Poppins')),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
