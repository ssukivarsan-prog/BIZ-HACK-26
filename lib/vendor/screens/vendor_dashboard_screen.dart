import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/vegetable_service.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';
import '../../models/vegetable_model.dart';
import '../widgets/farmer_produce_detail_sheet.dart';
import '../widgets/smart_market_insight_card.dart';
import '../widgets/smart_buyer_matching_card.dart';
import '../widgets/market_demand_card.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final allOrders = ref.watch(allOrdersProvider);
    final allVegetables = ref.watch(vegetablesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.vendorPrimary, AppTheme.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: currentUser.when(
                  data: (user) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${'Good '.tr(ref)}${_timeGreeting().tr(ref)}, ${user?.name.split(' ').first ?? 'Vendor'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Here\'s your store overview'.tr(ref),
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats grid
                  allOrders.when(
                    data: (orders) {
                      final pending = orders.where((o) => o.status == OrderStatus.pending).length;
                      final delivered = orders.where((o) => o.status == OrderStatus.delivered).length;
                      final revenue = orders
                          .where((o) => o.status == OrderStatus.delivered)
                          .fold(0.0, (sum, o) => sum + o.totalAmount);
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  label: 'Total Orders'.tr(ref),
                                  value: '${orders.length}',
                                  icon: Icons.receipt_long_rounded,
                                  color: AppTheme.primaryGreen,
                                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  label: 'Pending'.tr(ref),
                                  value: '$pending',
                                  icon: Icons.pending_actions_rounded,
                                  color: AppTheme.accentOrange,
                                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  label: 'Delivered'.tr(ref),
                                  value: '$delivered',
                                  icon: Icons.check_circle_outline_rounded,
                                  color: const Color(0xFF1565C0),
                                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  label: 'Revenue'.tr(ref),
                                  value: '₹${revenue.toStringAsFixed(0)}',
                                  icon: Icons.currency_rupee_rounded,
                                  color: const Color(0xFF6A1B9A),
                                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const _StatsShimmer(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 28),

                  // Inventory summary
                  SectionHeader(
                    title: 'Inventory'.tr(ref),
                    actionLabel: 'Manage'.tr(ref),
                    onAction: () {},
                  ),
                  const SizedBox(height: 16),
                  allVegetables.when(
                    data: (vegs) {
                      final available = vegs.where((v) => v.isAvailable).length;
                      final outOfStock = vegs.where((v) => !v.isAvailable).length;
                      return Column(
                        children: [
                          _InventoryBanner(
                            available: available,
                            outOfStock: outOfStock,
                            total: vegs.length,
                          ),
                          const SizedBox(height: 16),
                          ...vegs.take(5).map((veg) => _VegListTile(veg: veg)),
                        ],
                      );
                    },
                    loading: () => const ShimmerBox(height: 80),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),

                  // Real-time Market Demand driven by live customer pre-bookings
                  const MarketDemandCard(),

                  const SizedBox(height: 24),

                  // Smart Market Intelligence Showcase Section
                  const _DashboardMarketIntelligenceSection(),

                  const SizedBox(height: 28),

                  // Recent orders
                  SectionHeader(title: 'Recent Orders'.tr(ref)),
                  const SizedBox(height: 16),
                  allOrders.when(
                    data: (orders) {
                      final recent = orders.take(5).toList();
                      if (recent.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No orders yet'.tr(ref),
                          subtitle: 'Orders from customers will appear here'.tr(ref),
                          icon: Icons.receipt_long_outlined,
                        );
                      }
                      return Column(
                        children: recent
                            .map((order) => _OrderListTile(order: order))
                            .toList(),
                      );
                    },
                    loading: () => const ShimmerBox(height: 200),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: ShimmerBox(height: 90)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 90)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: ShimmerBox(height: 90)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 90)),
          ],
        ),
      ],
    );
  }
}

class _InventoryBanner extends StatelessWidget {
  final int available;
  final int outOfStock;
  final int total;

  const _InventoryBanner({
    required this.available,
    required this.outOfStock,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _BannerStat(value: '$total', label: 'Total Items', color: AppTheme.textDark)),
          _divider(),
          Expanded(child: _BannerStat(value: '$available', label: 'In Stock', color: AppTheme.successGreen)),
          _divider(),
          Expanded(child: _BannerStat(value: '$outOfStock', label: 'Out of Stock', color: AppTheme.errorRed)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: const Color(0xFFBBF7D0));
}

class _BannerStat extends ConsumerWidget {
  final String value;
  final String label;
  final Color color;

  const _BannerStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
        Text(label.tr(ref), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins')),
      ],
    );
  }
}

class _VegListTile extends ConsumerWidget {
  final dynamic veg;

  const _VegListTile({required this.veg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (veg is VegetableModel) {
            FarmerProduceDetailSheet.show(context, veg);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              AppNetworkImage(
                imageUrl: veg.imageUrl,
                category: veg.category,
                width: 44,
                height: 44,
                borderRadius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(veg.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins')),
                    Text('${veg.availableQuantityKg} ${veg.unit}${' available'.tr(ref)}', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Text('₹${veg.pricePerKg}/${veg.unit}', style: AppTextStyles.price),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderListTile extends ConsumerWidget {
  final OrderModel order;

  const _OrderListTile({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
                Text(order.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(order.orderedAt),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.items.length}${' item'.tr(ref)}${order.items.length > 1 ? 's'.tr(ref) : ''} • ₹${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }
}

class _DashboardMarketIntelligenceSection extends StatefulWidget {
  const _DashboardMarketIntelligenceSection();

  @override
  State<_DashboardMarketIntelligenceSection> createState() =>
      _DashboardMarketIntelligenceSectionState();
}

class _DashboardMarketIntelligenceSectionState
    extends State<_DashboardMarketIntelligenceSection> {
  String _selectedCrop = 'Tomato';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_alt_outlined, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Market Intelligence (Demo)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Text(
                'Showcase',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCropChoice('Tomato', '🍅 Tomato — Erode 🔥'),
              const SizedBox(width: 8),
              _buildCropChoice('Onion', '🧅 Onion — Erode ⚡'),
              const SizedBox(width: 8),
              _buildCropChoice('Banana', '🍌 Banana — Cbe ❄️'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SmartMarketInsightCard(cropName: _selectedCrop),
        SmartBuyerMatchingCard(
          cropName: _selectedCrop,
          availableQuantity: _selectedCrop == 'Banana'
              ? 500.0
              : (_selectedCrop == 'Onion' ? 380.0 : 350.0),
          location: _selectedCrop == 'Banana' ? 'Coimbatore' : 'Erode',
        ),
      ],
    );
  }

  Widget _buildCropChoice(String key, String label) {
    final isSelected = _selectedCrop == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textDark,
          fontFamily: 'Poppins',
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: Colors.white,
      showCheckmark: false,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryGreen : AppTheme.dividerColor,
      ),
      onSelected: (_) => setState(() => _selectedCrop = key),
    );
  }
}

