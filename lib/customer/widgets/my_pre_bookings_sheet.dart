// lib/customer/widgets/my_pre_bookings_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/pre_booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/pre_booking_service.dart';
import '../../theme/app_theme.dart';

class MyPreBookingsSheet extends ConsumerWidget {
  const MyPreBookingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MyPreBookingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final customerId = currentUser?.uid ?? '';
    // Show user-specific pre-bookings if logged in, or all pre-bookings if guest/demo
    final preBookingsAsync = customerId.isNotEmpty
        ? ref.watch(customerPreBookingsStreamProvider(customerId))
        : ref.watch(allPreBookingsStreamProvider);

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
                      'My Pre-Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Your advance produce reservation signals',
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
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
            child: preBookingsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.bookmark_border_rounded, size: 48, color: AppTheme.textGrey),
                          SizedBox(height: 8),
                          Text(
                            'No pre-bookings yet',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark, fontFamily: 'Poppins'),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap "Pre-Book" on any vegetable to choose a farmer and request harvest.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _buildBookingTile(context, list[i]),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                ),
              ),
              error: (e, _) => Center(child: Text('Error loading pre-bookings: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTile(BuildContext context, PreBookingModel b) {
    final isCanDeliver = b.status == 'can_deliver' || b.status == 'accepted';
    final isRejected = b.status == 'rejected';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCanDeliver ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCanDeliver ? const Color(0xFFBBF7D0) : AppTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Produce & Status
          Row(
            children: [
              Text(
                b.productName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Poppins'),
              ),
              const Spacer(),
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
                      : (isRejected ? 'DECLINED' : '⏳ PENDING CONFIRMATION'),
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

          const SizedBox(height: 6),

          // Selected Farmer & Farm Location
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.agriculture_rounded, size: 14, color: AppTheme.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Farmer: ${b.farmerName}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textDark, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        b.farmerLocation,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
                if (b.freshnessDescription.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    b.freshnessDescription,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF15803D), fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Qty & Preferred Date
          Row(
            children: [
              Text(
                '${b.quantityRequested.toStringAsFixed(0)} kg requested',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.event_available_rounded, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(b.preferredDate),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textDark, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Delivery Address
          Row(
            children: [
              const Icon(Icons.home_outlined, size: 13, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Delivery Address: ${b.customerLocation}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),

          // Farmer delivery response if accepted
          if (isCanDeliver) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 15, color: Color(0xFF1B5E20)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Farmer Response: ${b.farmerResponseNote ?? "Delivery confirmed! Produce will be harvested and delivered on target date."}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1B5E20), fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
