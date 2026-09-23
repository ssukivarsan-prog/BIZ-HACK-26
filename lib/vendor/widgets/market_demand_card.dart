// lib/vendor/widgets/market_demand_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/pre_booking_model.dart';
import '../../services/demand_calculation_service.dart';
import '../../services/pre_booking_service.dart';
import '../../theme/app_theme.dart';

class MarketDemandCard extends ConsumerStatefulWidget {
  const MarketDemandCard({super.key});

  @override
  ConsumerState<MarketDemandCard> createState() => _MarketDemandCardState();
}

class _MarketDemandCardState extends ConsumerState<MarketDemandCard> {
  int _selectedTab = 0; // 0 = Demand Grades, 1 = Customer Requests

  @override
  Widget build(BuildContext context) {
    final demandList = ref.watch(allProduceDemandListProvider);
    final activeDemand = demandList.where((d) => d.preBookingCount > 0).toList();
    final allBookingsAsync = ref.watch(allPreBookingsStreamProvider);
    final allBookings = allBookingsAsync.value ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up_rounded, color: AppTheme.primaryGreen, size: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Demand & Pre-Bookings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Live customer demand & delivery requests',
                      style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Text(
                  'REAL-TIME',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Segmented Tabs: Demand Grades vs Customer Requests
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _selectedTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '📊 Demand Grades',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: _selectedTab == 0 ? AppTheme.textDark : AppTheme.textGrey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _selectedTab == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '📦 Customer Requests',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                              color: _selectedTab == 1 ? AppTheme.textDark : AppTheme.textGrey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (allBookings.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? AppTheme.primaryGreen : AppTheme.textGrey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${allBookings.length}',
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // TAB 0: DEMAND GRADES PER PRODUCE
          if (_selectedTab == 0) ...[
            if (activeDemand.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No pre-bookings received yet.\nCustomer pre-bookings will automatically appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeDemand.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _buildProduceDemandTile(context, activeDemand[i]),
              ),
          ]
          // TAB 1: CUSTOMER REQUESTS & DELIVERY ACTIONS
          else ...[
            if (allBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No customer pre-booking requests yet.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allBookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _buildCustomerRequestCard(context, ref, allBookings[i]),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildProduceDemandTile(BuildContext context, ProduceDemandInsight insight) {
    Color badgeBg;
    Color badgeFg;
    switch (insight.demandLevel) {
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

    final emoji = _getCropEmoji(insight.productName);

    return InkWell(
      onTap: () => setState(() => _selectedTab = 1),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    insight.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${insight.emoji} ${insight.demandLabel}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeFg,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${insight.totalPreBookedQuantity.toStringAsFixed(0)} kg requested',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Text(' • ', style: TextStyle(color: AppTheme.textGrey)),
                Text(
                  '${insight.availableQuantity.toStringAsFixed(0)} kg available',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                ),
                const Spacer(),
                Text(
                  '${insight.preBookingCount} bookings',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4338CA),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRequestCard(
    BuildContext context,
    WidgetRef ref,
    PreBookingModel booking,
  ) {
    final isCanDeliver = booking.status == 'can_deliver' || booking.status == 'accepted';
    final isRejected = booking.status == 'rejected';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCanDeliver
            ? const Color(0xFFF0FDF4)
            : (isRejected ? const Color(0xFFF9FAFB) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCanDeliver
              ? const Color(0xFFBBF7D0)
              : (isRejected ? AppTheme.dividerColor : const Color(0xFFFED7AA)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer & Status Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textGrey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            'Delivery to: ${booking.customerLocation}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCanDeliver
                      ? const Color(0xFFDCFCE7)
                      : (isRejected ? const Color(0xFFF3F4F6) : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCanDeliver
                      ? '✓ CAN DELIVER'
                      : (isRejected ? 'DECLINED' : '⏳ PENDING REVIEW'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isCanDeliver
                        ? const Color(0xFF15803D)
                        : (isRejected ? AppTheme.textGrey : const Color(0xFFB45309)),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Requested Produce & kg
          Row(
            children: [
              Text(_getCropEmoji(booking.productName), style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                booking.productName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${booking.quantityRequested.toStringAsFixed(0)} kg requested',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Target harvest date & Freshness
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 13, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(
                'Target Date: ${DateFormat('dd MMM yyyy').format(booking.preferredDate)}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
              ),
            ],
          ),

          if (booking.freshnessDescription.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Freshness preference: ${booking.freshnessDescription}',
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF15803D), fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
            ),
          ],

          if (booking.note != null && booking.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Customer note: "${booking.note}"',
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textDark, fontFamily: 'Poppins'),
            ),
          ],

          // If delivery confirmed, show confirmation note
          if (isCanDeliver && booking.farmerResponseNote != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 14, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Delivery note: ${booking.farmerResponseNote}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Farmer action buttons (Where they can deliver / accept)
          if (!isCanDeliver && !isRejected) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeliverDialog(context, ref, booking),
                      icon: const Icon(Icons.check_circle_rounded, size: 15),
                      label: const Text('Can Deliver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(preBookingServiceProvider).updatePreBookingStatus(booking.id, 'rejected');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pre-booking declined.')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textGrey,
                      side: const BorderSide(color: AppTheme.dividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showDeliverDialog(BuildContext context, WidgetRef ref, PreBookingModel booking) {
    final noteCtrl = TextEditingController(
      text: 'Confirmed: We can deliver ${booking.quantityRequested.toStringAsFixed(0)} kg to ${booking.customerLocation} on harvest morning.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.local_shipping_rounded, color: AppTheme.primaryGreen, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Confirm Delivery Reach',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accept pre-booking for ${booking.customerName}:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 4),
            Text(
              '• Produce: ${booking.quantityRequested.toStringAsFixed(0)} kg ${booking.productName}\n• Location: ${booking.customerLocation}\n• Date: ${DateFormat('dd MMM yyyy').format(booking.preferredDate)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.4, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Delivery confirmation note to customer:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textGrey, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Where and when you will deliver...',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.dividerColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.dividerColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey, fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(preBookingServiceProvider).updatePreBookingStatus(
                    booking.id,
                    'can_deliver',
                    farmerResponseNote: noteCtrl.text.trim(),
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.primaryGreen,
                    content: Text('Delivery confirmed for ${booking.customerName}!'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Delivery', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _getCropEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('carrot')) return '🥕';
    if (lower.contains('potato')) return '🥔';
    return '🥬';
  }
}
