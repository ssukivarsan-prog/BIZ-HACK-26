// lib/vendor/widgets/smart_market_insight_card.dart
import 'package:flutter/material.dart';
import '../../services/smart_market_insights_service.dart';
import '../../theme/app_theme.dart';

class SmartMarketInsightCard extends StatelessWidget {
  final String cropName;
  final String? location;
  final VoidCallback? onCropSelectedForDemo;

  const SmartMarketInsightCard({
    super.key,
    required this.cropName,
    this.location,
    this.onCropSelectedForDemo,
  });

  @override
  Widget build(BuildContext context) {
    final insight = SmartMarketInsightsService.instance.getInsightForCrop(cropName);

    if (insight == null) {
      return _buildFallbackCard(context);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(insight.demandLevel), width: 1.2),
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
          // Header row with Title & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        const Text(
                          '📊 SMART MARKET INSIGHT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppTheme.primaryGreen,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PROTOTYPE DEMO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textGrey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${insight.cropName} — ${insight.location}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildDemandBadge(insight),
            ],
          ),

          const SizedBox(height: 8),
          const Text(
            'Based on recent marketplace activity\nDemo Data • Last 7 Days',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textGrey,
              height: 1.3,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 12),

          // Key metrics grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: '🔎',
                  label: 'Buyer searches',
                  value: '${insight.buyerSearches}',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: '👁',
                  label: 'Listing views',
                  value: '${insight.listingViews}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: '🛒',
                  label: 'Purchase requests',
                  value: '${insight.purchaseRequests}',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: '✅',
                  label: 'Accepted orders',
                  value: '${insight.acceptedOrders}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: '📦',
                  label: 'Quantity sold',
                  value: '${insight.quantitySold.toStringAsFixed(0)} kg',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: '📦',
                  label: 'Available',
                  value: '${insight.availableQuantity.toStringAsFixed(0)} kg',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getBgTint(insight.demandLevel),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(insight.demandBadgeEmoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.supplyStatusSummary,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(insight.demandLevel),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Informational price insight
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Recent Price Range: ',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                      children: [
                        TextSpan(
                          text: '₹${insight.minPrice.toStringAsFixed(0)}–₹${insight.maxPrice.toStringAsFixed(0)}/kg',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                        ),
                        const TextSpan(text: ' • Average: '),
                        TextSpan(
                          text: '₹${insight.averagePrice.toStringAsFixed(0)}/kg',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          // View Analysis Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () => _showAnalysisSheet(context, insight),
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text(
                'View Analysis',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryGreen, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandBadge(MarketInsightData insight) {
    Color bg;
    Color fg;
    switch (insight.demandLevel) {
      case DemandLevel.high:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
      case DemandLevel.moderate:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F17);
        break;
      case DemandLevel.low:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case DemandLevel.insufficientData:
        bg = const Color(0xFFF3F4F6);
        fg = AppTheme.textGrey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(insight.demandBadgeEmoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            insight.demandLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
              ),
              Text(
                value,
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
      ],
    );
  }

  Color _getBorderColor(DemandLevel level) {
    switch (level) {
      case DemandLevel.high:
        return const Color(0xFFFFCDD2);
      case DemandLevel.moderate:
        return const Color(0xFFFFECB3);
      case DemandLevel.low:
        return const Color(0xFFBBDEFB);
      case DemandLevel.insufficientData:
        return AppTheme.dividerColor;
    }
  }

  Color _getBgTint(DemandLevel level) {
    switch (level) {
      case DemandLevel.high:
        return const Color(0xFFFFF5F5);
      case DemandLevel.moderate:
        return const Color(0xFFFFFBEB);
      case DemandLevel.low:
        return const Color(0xFFF0F9FF);
      case DemandLevel.insufficientData:
        return const Color(0xFFF9FAFB);
    }
  }

  Color _getTextColor(DemandLevel level) {
    switch (level) {
      case DemandLevel.high:
        return const Color(0xFFB71C1C);
      case DemandLevel.moderate:
        return const Color(0xFFB45309);
      case DemandLevel.low:
        return const Color(0xFF0369A1);
      case DemandLevel.insufficientData:
        return AppTheme.textDark;
    }
  }

  Widget _buildFallbackCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
              const Text(
                '📊 SMART MARKET INSIGHT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textGrey,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'INSUFFICIENT DATA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Demo insight available for supported demonstration crops:',
            style: TextStyle(fontSize: 12, color: AppTheme.textGrey.withOpacity(0.9), fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDemoCropChip('Tomato (High) 🔥'),
              _buildDemoCropChip('Onion (Moderate) ⚡'),
              _buildDemoCropChip('Banana (Low) ❄️'),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Select one of the demo-supported crops to view the simulated market analysis.',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textGrey, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCropChip(String title) {
    return Chip(
      label: Text(title, style: const TextStyle(fontSize: 11, fontFamily: 'Poppins')),
      backgroundColor: const Color(0xFFF0FDF4),
      side: const BorderSide(color: Color(0xFFBBF7D0)),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showAnalysisSheet(BuildContext context, MarketInsightData insight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MarketAnalysisBottomSheet(insight: insight),
    );
  }
}

class _MarketAnalysisBottomSheet extends StatelessWidget {
  final MarketInsightData insight;

  const _MarketAnalysisBottomSheet({required this.insight});

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

          // Title & Close
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${insight.cropName} — ${insight.location}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Analysis Period: ${insight.period}',
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

          const SizedBox(height: 16),
          // Analysis Metric Table
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              children: [
                _buildTableRow('Buyer searches', '${insight.buyerSearches}', isEven: false),
                _buildTableRow('Listing views', '${insight.listingViews}', isEven: true),
                _buildTableRow('Purchase requests', '${insight.purchaseRequests}', isEven: false),
                _buildTableRow('Accepted orders', '${insight.acceptedOrders}', isEven: true),
                _buildTableRow('Quantity requested', '${insight.quantityRequested.toStringAsFixed(0)} kg', isEven: false),
                _buildTableRow('Quantity sold', '${insight.quantitySold.toStringAsFixed(0)} kg', isEven: true),
                _buildTableRow('Available quantity', '${insight.availableQuantity.toStringAsFixed(0)} kg', isEven: false, isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Observed Demand Box
          Container(
            padding: const EdgeInsets.all(14),
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
                    const Text(
                      'Observed Demand: ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${insight.demandBadgeEmoji} ${insight.demandLabel}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Reason:\n${insight.demandExplanation}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textDark,
                    height: 1.4,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculated Demand Score: ${insight.demandScore.toStringAsFixed(1)} / 100',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Price Range Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.currency_rupee_rounded, size: 18, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recent Market Range: ₹${insight.minPrice.toStringAsFixed(0)}–₹${insight.maxPrice.toStringAsFixed(0)}/kg (Average ₹${insight.averagePrice.toStringAsFixed(0)}/kg)',
                    style: const TextStyle(
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

          const SizedBox(height: 14),
          // Disclaimer note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: This is simulated marketplace data for the prototype demonstration. In a production deployment, these values would be generated from actual buyer activity on the platform.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF92400E),
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

  Widget _buildTableRow(String metric, String value, {required bool isEven, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF9FAFB) : Colors.white,
        border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontFamily: 'Poppins'),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
