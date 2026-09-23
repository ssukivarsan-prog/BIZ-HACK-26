import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/vegetable_service.dart';
import '../../services/cart_notifier.dart';
import '../../models/vegetable_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';
import '../../services/demand_calculation_service.dart';
import '../widgets/pre_booking_bottom_sheet.dart';

final vegetableDetailProvider = FutureProvider.family<VegetableModel?, String>((ref, id) {
  return ref.read(vegetableServiceProvider).getVegetableById(id);
});

class VegetableDetailScreen extends ConsumerStatefulWidget {
  final String vegetableId;
  const VegetableDetailScreen({super.key, required this.vegetableId});

  @override
  ConsumerState<VegetableDetailScreen> createState() => _VegetableDetailScreenState();
}

class _VegetableDetailScreenState extends ConsumerState<VegetableDetailScreen> {
  double _qty = 1.0;

  @override
  Widget build(BuildContext context) {
    final vegAsync = ref.watch(vegetableDetailProvider(widget.vegetableId));

    return Scaffold(
      body: vegAsync.when(
        data: (veg) {
          if (veg == null) return Center(child: Text('Vegetable not found'.tr(ref)));
          final inCart = ref.watch(cartProvider.select(
            (c) => c.any((e) => e.vegetableId == veg.id),
          ));
          final cartQty = ref.read(cartProvider.notifier).quantityInCart(veg.id);
          if (cartQty > 0) _qty = cartQty;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppTheme.textDark),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: AppNetworkImage(
                    imageUrl: veg.imageUrl,
                    category: veg.category,
                    height: 260,
                    borderRadius: 0,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(veg.name, style: AppTextStyles.heading2),
                                const SizedBox(height: 4),
                                Text(veg.category.tr(ref), style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: veg.isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              veg.isAvailable ? 'In Stock'.tr(ref) : 'Out of Stock'.tr(ref),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: veg.isAvailable ? AppTheme.successGreen : AppTheme.errorRed,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _DetailStat(
                              label: 'Price'.tr(ref),
                              value: '₹${veg.pricePerKg}',
                              sub: '${'per '.tr(ref)}${veg.unit}',
                              color: AppTheme.primaryGreen,
                            ),
                            Container(width: 1, height: 40, color: AppTheme.dividerColor),
                            _DetailStat(
                              label: 'Available'.tr(ref),
                              value: '${veg.availableQuantityKg}',
                              sub: veg.unit,
                              color: AppTheme.accentOrange,
                            ),
                          ],
                        ),
                      ),
                      Builder(builder: (ctx) {
                        final demandInsight = ref.watch(singleProduceDemandProvider(veg.name));
                        if (demandInsight.preBookingCount == 0) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: demandInsight.demandLevel == ProduceDemandLevel.high
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: demandInsight.demandLevel == ProduceDemandLevel.high
                                  ? const Color(0xFFFFCDD2)
                                  : const Color(0xFFFFECB3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(demandInsight.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${demandInsight.demandLabel} • ${demandInsight.preBookingCount} pre-bookings (${demandInsight.totalPreBookedQuantity.toStringAsFixed(0)} kg requested)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: demandInsight.demandLevel == ProduceDemandLevel.high
                                            ? const Color(0xFFC62828)
                                            : const Color(0xFFB45309),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      demandInsight.shortReason,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: demandInsight.demandLevel == ProduceDemandLevel.high
                                            ? const Color(0xFFB71C1C)
                                            : const Color(0xFF92400E),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (veg.isAvailable) ...[
                        const SizedBox(height: 24),
                        Text('Select Quantity'.tr(ref), style: AppTextStyles.heading3),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove_rounded,
                              onTap: () => setState(() => _qty = (_qty - 0.5).clamp(0.5, veg.availableQuantityKg)),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '$_qty ${veg.unit}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      color: AppTheme.textDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '₹${(_qty * veg.pricePerKg).toStringAsFixed(2)}',
                                    style: AppTextStyles.price,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add_rounded,
                              onTap: () => setState(() => _qty = (_qty + 0.5).clamp(0.5, veg.availableQuantityKg)),
                              isPrimary: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.primaryGreen,
                            thumbColor: AppTheme.primaryGreen,
                            inactiveTrackColor: AppTheme.dividerColor,
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _qty,
                            min: 0.5,
                            max: veg.availableQuantityKg,
                            divisions: ((veg.availableQuantityKg - 0.5) / 0.5).round(),
                            onChanged: (v) => setState(() => _qty = v),
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (inCart) {
                              ref.read(cartProvider.notifier).updateQuantity(veg.id, _qty);
                            } else {
                              ref.read(cartProvider.notifier).addItem(veg, _qty);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  inCart ? 'Cart updated!'.tr(ref) : '${veg.name}${' added to cart!'.tr(ref)}',
                                ),
                                action: SnackBarAction(
                                  label: 'View Cart'.tr(ref),
                                  textColor: AppTheme.lightGreen,
                                  onPressed: () => context.push('/customer/cart'),
                                ),
                              ),
                            );
                          },
                          icon: Icon(inCart ? Icons.edit_rounded : Icons.shopping_cart_rounded),
                          label: Text(inCart ? 'Update Cart'.tr(ref) : 'Add to Cart'.tr(ref)),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => PreBookingBottomSheet.show(context, veg),
                            icon: const Icon(Icons.bookmark_add_rounded, size: 20),
                            label: const Text(
                              'Pre-Book Produce',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Currently Out of Stock',
                                style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFC2410C), fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'You can pre-book this produce now to signal advance harvest demand to the farmer.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF9A3412)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => PreBookingBottomSheet.show(context, veg),
                            icon: const Icon(Icons.bookmark_add_rounded, size: 20),
                            label: const Text(
                              'Pre-Book for Next Harvest',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${'Error: '.tr(ref)}$e')),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _DetailStat({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
        Text(sub, style: AppTextStyles.caption),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QtyButton({required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPrimary ? AppTheme.primaryGreen : AppTheme.dividerColor),
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : AppTheme.textDark, size: 20),
      ),
    );
  }
}
