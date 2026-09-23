import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// ─── Reusable Order Summary Card ──────────────────────────────────────────────
class OrderSummaryCard extends StatelessWidget {
  final List<OrderItem> items;
  final double totalAmount;
  final bool showImages;

  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.totalAmount,
    this.showImages = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Summary', style: AppTextStyles.heading3),
                Text(
                  '${items.length} item${items.length != 1 ? 's' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          ...items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      if (showImages) ...[
                        AppNetworkImage(
                          imageUrl: item.imageUrl,
                          category: item.category,
                          width: 40,
                          height: 40,
                          borderRadius: 8,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.vegetableName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              '${item.quantity}${item.unit} × ₹${item.pricePerUnit}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: AppTheme.dividerColor,
                    indent: 14,
                    endIndent: 14,
                  ),
              ],
            );
          }),
          const Divider(height: 1, color: AppTheme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
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
    );
  }
}

// ─── Delivery Info Card ───────────────────────────────────────────────────────
class DeliveryInfoCard extends StatelessWidget {
  final String? address;
  final String? notes;

  const DeliveryInfoCard({super.key, this.address, this.notes});

  @override
  Widget build(BuildContext context) {
    if (address == null && notes == null) return const SizedBox.shrink();

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
          const Text('Delivery Details', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          if (address != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(address!, style: AppTextStyles.body)),
              ],
            ),
          ],
          if (address != null && notes != null) const SizedBox(height: 10),
          if (notes != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note_alt_outlined,
                    size: 16, color: AppTheme.textGrey),
                const SizedBox(width: 8),
                Expanded(child: Text(notes!, style: AppTextStyles.body)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
