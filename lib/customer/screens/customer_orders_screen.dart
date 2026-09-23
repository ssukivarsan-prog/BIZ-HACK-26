import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';

class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text('My Orders'.tr(ref))),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const SizedBox();
          final ordersAsync = ref.watch(customerOrdersProvider(user.uid));
          return ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return EmptyStateWidget(
                  title: 'No orders yet'.tr(ref),
                  subtitle: 'Your order history will appear here'.tr(ref),
                  icon: Icons.receipt_long_outlined,
                  buttonLabel: 'Shop Now'.tr(ref),
                  onButton: () {},
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => _CustomerOrderCard(
                  order: orders[i],
                  onTrack: () => context.push('/customer/track-order/${orders[i].id}'),
                ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideY(begin: 0.1),
              );
            },
            loading: () => ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => const ShimmerBox(height: 130),
            ),
            error: (e, _) {
              final isAuthError = e.toString().contains('permission-denied');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: EmptyStateWidget(
                    title: isAuthError ? 'Account Error'.tr(ref) : 'Error'.tr(ref),
                    subtitle: isAuthError 
                      ? 'Your customer account data is missing. Please go to Profile, log out, and sign up again.'.tr(ref) 
                      : e.toString(),
                    icon: isAuthError ? Icons.no_accounts_outlined : Icons.error_outline_rounded,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}

class _CustomerOrderCard extends ConsumerWidget {
  final OrderModel order;
  final VoidCallback onTrack;

  const _CustomerOrderCard({required this.order, required this.onTrack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
                '${'Order #'.tr(ref)}${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
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
          const Divider(color: AppTheme.dividerColor, height: 1),
          const SizedBox(height: 10),
          ...order.items.take(3).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.vegetableName} × ${item.quantity}${item.unit}',
                        style: AppTextStyles.body,
                      ),
                      Text('₹${item.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.body),
                    ],
                  ),
                ),
              ),
          if (order.items.length > 3)
            Text(
              '${'+ '.tr(ref)}${order.items.length - 3}${' more item'.tr(ref)}${order.items.length - 3 > 1 ? 's'.tr(ref) : ''}',
              style: AppTextStyles.caption,
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'Total: '.tr(ref)}₹${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.primaryGreen,
                  fontFamily: 'Poppins',
                ),
              ),
              if (order.status != OrderStatus.delivered &&
                  order.status != OrderStatus.cancelled)
                GestureDetector(
                  onTap: onTrack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryGreen),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Track Order'.tr(ref),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
