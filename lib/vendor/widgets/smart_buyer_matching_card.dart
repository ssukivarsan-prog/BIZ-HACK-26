// lib/vendor/widgets/smart_buyer_matching_card.dart
import 'package:flutter/material.dart';
import '../../services/smart_market_insights_service.dart';
import '../../theme/app_theme.dart';

class SmartBuyerMatchingCard extends StatelessWidget {
  final String cropName;
  final double availableQuantity;
  final String location;

  const SmartBuyerMatchingCard({
    super.key,
    required this.cropName,
    required this.availableQuantity,
    this.location = 'Erode',
  });

  @override
  Widget build(BuildContext context) {
    final matches = SmartMarketInsightsService.instance.findMatches(
      cropName: cropName,
      availableQuantity: availableQuantity,
      farmerLocation: location,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              const Text(
                '🎯 POTENTIAL BUYERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF4338CA),
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Text(
                  '${matches.length} Matches',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4338CA),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            matches.isNotEmpty
                ? '${matches.length} potential buyers match this produce'
                : 'No simulated buyer matches found for this crop.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Based on:',
            style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 4),

          // Criteria checklist
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildCriterion('✓ Crop'),
              _buildCriterion('✓ Quantity'),
              _buildCriterion('✓ Location'),
              _buildCriterion('✓ Buyer activity'),
            ],
          ),

          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: matches.isNotEmpty
                  ? () => _showBuyerMatchesSheet(context, matches)
                  : null,
              icon: const Icon(Icons.people_outline_rounded, size: 18),
              label: const Text(
                'View Buyer Matches',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterion(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  void _showBuyerMatchesSheet(BuildContext context, List<BuyerMatchResult> matches) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BuyerMatchesBottomSheet(
        cropName: cropName,
        matches: matches,
      ),
    );
  }
}

class _BuyerMatchesBottomSheet extends StatelessWidget {
  final String cropName;
  final List<BuyerMatchResult> matches;

  const _BuyerMatchesBottomSheet({
    required this.cropName,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential Buyers for $cropName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${matches.length} matching simulated buyer requirements',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        fontFamily: 'Poppins',
                      ),
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

          // Buyer list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _buildBuyerTile(context, matches[i]),
            ),
          ),

          const SizedBox(height: 14),

          // Disclaimer note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 16, color: AppTheme.textGrey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Simulated buyer requirement data for demonstration only. No automatic orders are created and existing inventory remains unchanged.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textGrey,
                      height: 1.35,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerTile(BuildContext context, BuyerMatchResult result) {
    final buyer = result.buyer;

    Color badgeBg;
    Color badgeFg;
    switch (result.strength) {
      case MatchStrength.strong:
        badgeBg = const Color(0xFFDCFCE7);
        badgeFg = const Color(0xFF15803D);
        break;
      case MatchStrength.good:
        badgeBg = const Color(0xFFEFF6FF);
        badgeFg = const Color(0xFF1D4ED8);
        break;
      case MatchStrength.possible:
        badgeBg = const Color(0xFFFEF3C7);
        badgeFg = const Color(0xFFB45309);
        break;
      case MatchStrength.low:
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and match score badge
          Row(
            children: [
              Expanded(
                child: Text(
                  buyer.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${result.totalScore}% — ${result.strengthLabel}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeFg,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Crop, quantity, location
          Row(
            children: [
              _buildInfoChip('📦 Required: ${buyer.requiredQuantity.toStringAsFixed(0)} kg'),
              const SizedBox(width: 8),
              _buildInfoChip('📍 ${buyer.location}'),
              const SizedBox(width: 8),
              if (buyer.isActive)
                _buildInfoChip('⚡ Active Buyer'),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Score breakdown: Crop (+${result.cropScore}) • Location (+${result.locationScore}) • Qty (+${result.quantityScore}) • Active (+${result.activeScore})',
            style: const TextStyle(fontSize: 10, color: AppTheme.textGrey, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.textDark,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
