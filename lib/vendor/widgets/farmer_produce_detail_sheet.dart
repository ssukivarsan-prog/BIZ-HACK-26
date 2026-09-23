// lib/vendor/widgets/farmer_produce_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/vegetable_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'smart_market_insight_card.dart';
import 'smart_buyer_matching_card.dart';

class FarmerProduceDetailSheet extends StatelessWidget {
  final VegetableModel vegetable;

  const FarmerProduceDetailSheet({super.key, required this.vegetable});

  static void show(BuildContext context, VegetableModel vegetable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FarmerProduceDetailSheet(vegetable: vegetable),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vegetable.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '${vegetable.category} • Produce Details',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
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
          ),

          const Divider(height: 1, color: AppTheme.dividerColor),

          // Scrollable body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              children: [
                // Produce Summary Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      AppNetworkImage(
                        imageUrl: vegetable.imageUrl,
                        category: vegetable.category,
                        width: 64,
                        height: 64,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '₹${vegetable.pricePerKg}/${vegetable.unit}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGreen,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: vegetable.isAvailable
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    vegetable.isAvailable ? 'In Stock' : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: vegetable.isAvailable
                                          ? AppTheme.successGreen
                                          : AppTheme.errorRed,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Available: ${vegetable.availableQuantityKg} ${vegetable.unit}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textDark,
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

                // FEATURE 1: Smart Market Insight Card
                SmartMarketInsightCard(
                  cropName: vegetable.name,
                ),

                const SizedBox(height: 16),

                // FEATURE 2: Smart Buyer Matching Card
                SmartBuyerMatchingCard(
                  cropName: vegetable.name,
                  availableQuantity: vegetable.availableQuantityKg,
                ),

                const SizedBox(height: 16),

                // Edit produce button (using existing route)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/vendor/edit-vegetable/${vegetable.id}');
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    'Edit Produce Listing',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
