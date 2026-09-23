// lib/customer/widgets/high_demand_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/demand_calculation_service.dart';
import '../../services/vegetable_service.dart';
import '../../theme/app_theme.dart';
import 'pre_booking_bottom_sheet.dart';

class HighDemandSection extends ConsumerWidget {
  const HighDemandSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDemand = ref.watch(allProduceDemandListProvider);
    final highDemandList = allDemand.where((d) => d.demandLevel == ProduceDemandLevel.high).toList();

    // If there are HIGH demand items, show them; otherwise show top active items
    final displayList = highDemandList.isNotEmpty
        ? highDemandList
        : allDemand.where((d) => d.preBookingCount > 0).take(4).toList();

    if (displayList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Demand Produce',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Driven by live customer pre-bookings',
                      style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showAllDemandModal(context, ref),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) => _buildHighDemandCard(context, ref, displayList[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHighDemandCard(
    BuildContext context,
    WidgetRef ref,
    ProduceDemandInsight insight,
  ) {
    final emoji = _getCropEmoji(insight.productName);

    return Container(
      width: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.demandLevel == ProduceDemandLevel.high
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFFFECB3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Name & Demand badge
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  insight.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: insight.demandLevel == ProduceDemandLevel.high
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  insight.demandLevel == ProduceDemandLevel.high ? '🔥 HIGH' : '⚡ MOD',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: insight.demandLevel == ProduceDemandLevel.high
                        ? const Color(0xFFC62828)
                        : const Color(0xFFD97706),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          // Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pre-booked', style: TextStyle(fontSize: 9, color: AppTheme.textGrey)),
                    Text(
                      '${insight.totalPreBookedQuantity.toStringAsFixed(0)} kg',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
                Container(width: 1, height: 22, color: AppTheme.dividerColor),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available', style: TextStyle(fontSize: 9, color: AppTheme.textGrey)),
                    Text(
                      '${insight.availableQuantity.toStringAsFixed(0)} kg',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                  ],
                ),
                Container(width: 1, height: 22, color: AppTheme.dividerColor),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Requests', style: TextStyle(fontSize: 9, color: AppTheme.textGrey)),
                    Text(
                      '${insight.preBookingCount}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () => _handlePreBook(context, ref, insight),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'Pre-Book',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePreBook(
    BuildContext context,
    WidgetRef ref,
    ProduceDemandInsight insight,
  ) {
    // Look up vegetable in availableVegetablesProvider
    final allVegs = ref.read(availableVegetablesProvider).value ?? [];
    final matchingVeg = allVegs.firstWhere(
      (v) =>
          v.name.toLowerCase().contains(insight.productName.toLowerCase()) ||
          insight.productName.toLowerCase().contains(v.name.toLowerCase()),
      orElse: () => allVegs.isNotEmpty ? allVegs.first : throw 'No vegetables',
    );

    PreBookingBottomSheet.show(context, matchingVeg);
  }

  void _showAllDemandModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllDemandBottomSheet(),
    );
  }

  String _getCropEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('carrot')) return '🥕';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('chilli')) return '🌶️';
    return '🥬';
  }
}

class _AllDemandBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDemand = ref.watch(allProduceDemandListProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Demand Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Aggregated from real customer pre-booking requests',
                      style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: allDemand.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final item = allDemand[i];
                Color badgeBg;
                Color badgeFg;
                switch (item.demandLevel) {
                  case ProduceDemandLevel.high:
                    badgeBg = const Color(0xFFFFEBEE);
                    badgeFg = const Color(0xFFC62828);
                    break;
                  case ProduceDemandLevel.moderate:
                    badgeBg = const Color(0xFFFFF8E1);
                    badgeFg = const Color(0xFFD97706);
                    break;
                  case ProduceDemandLevel.low:
                    badgeBg = const Color(0xFFE3F2FD);
                    badgeFg = const Color(0xFF1565C0);
                    break;
                  case ProduceDemandLevel.insufficientData:
                    badgeBg = const Color(0xFFF3F4F6);
                    badgeFg = AppTheme.textGrey;
                    break;
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins'),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pre-booked: ${item.totalPreBookedQuantity.toStringAsFixed(0)} kg • Available: ${item.availableQuantity.toStringAsFixed(0)} kg • ${item.preBookingCount} requests',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.emoji} ${item.demandLabel}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeFg, fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
