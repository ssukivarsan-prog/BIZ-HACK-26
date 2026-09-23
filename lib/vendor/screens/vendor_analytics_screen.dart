import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';

class VendorAnalyticsScreen extends ConsumerWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Analytics'.tr(ref))),
      body: ordersAsync.when(
        data: (orders) {
          final analytics = _Analytics(orders);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Summary row
              _SummaryRow(analytics: analytics)
                  .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),

              // Revenue bar chart (last 7 days)
              _SectionCard(
                title: 'Revenue — Last 7 Days'.tr(ref),
                child: SizedBox(
                  height: 200,
                  child: _RevenueChart(analytics: analytics),
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 16),

              // Order status pie chart
              _SectionCard(
                title: 'Order Status Breakdown'.tr(ref),
                child: SizedBox(
                  height: 220,
                  child: _StatusPieChart(analytics: analytics),
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 16),

              // Top selling vegetables
              _SectionCard(
                title: 'Top Selling Vegetables'.tr(ref),
                child: _TopVegetablesList(analytics: analytics),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 16),

              // Recent activity timeline
              _SectionCard(
                title: 'Recent Activity'.tr(ref),
                child: _ActivityTimeline(orders: orders.take(8).toList()),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ShimmerBox(height: 100),
            SizedBox(height: 16),
            ShimmerBox(height: 240),
            SizedBox(height: 16),
            ShimmerBox(height: 240),
            SizedBox(height: 16),
            ShimmerBox(height: 200),
          ],
        ),
        error: (e, _) => Center(child: Text('${'Error: '.tr(ref)}$e')),
      ),
    );
  }
}

// ─── Data Model ────────────────────────────────────────────────────────────────
class _Analytics {
  final List<OrderModel> orders;

  _Analytics(this.orders);

  double get totalRevenue => deliveredOrders
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  List<OrderModel> get deliveredOrders =>
      orders.where((o) => o.status == OrderStatus.delivered).toList();

  int get totalOrders => orders.length;

  int get pendingCount =>
      orders.where((o) => o.status == OrderStatus.pending).length;

  double get avgOrderValue =>
      deliveredOrders.isEmpty ? 0 : totalRevenue / deliveredOrders.length;

  /// Revenue per day for last 7 days
  Map<DateTime, double> get revenueByDay {
    final map = <DateTime, double>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      map[day] = 0;
    }
    for (final order in deliveredOrders) {
      final day = DateTime(
        order.orderedAt.year,
        order.orderedAt.month,
        order.orderedAt.day,
      );
      if (map.containsKey(day)) {
        map[day] = (map[day] ?? 0) + order.totalAmount;
      }
    }
    return map;
  }

  /// Count by status
  Map<OrderStatus, int> get countByStatus {
    final map = <OrderStatus, int>{};
    for (final o in orders) {
      map[o.status] = (map[o.status] ?? 0) + 1;
    }
    return map;
  }

  /// Top 5 vegetables by total quantity sold
  List<MapEntry<String, double>> get topVegetables {
    final map = <String, double>{};
    for (final order in deliveredOrders) {
      for (final item in order.items) {
        map[item.vegetableName] =
            (map[item.vegetableName] ?? 0) + item.quantity;
      }
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }
}

// ─── Summary Row ──────────────────────────────────────────────────────────────
class _SummaryRow extends ConsumerWidget {
  final _Analytics analytics;
  const _SummaryRow({required this.analytics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          label: 'Total Revenue'.tr(ref),
          value: '₹${analytics.totalRevenue.toStringAsFixed(0)}',
          icon: Icons.currency_rupee_rounded,
          color: AppTheme.primaryGreen,
        ),
        StatCard(
          label: 'Total Orders'.tr(ref),
          value: '${analytics.totalOrders}',
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF1565C0),
        ),
        StatCard(
          label: 'Avg Order Value'.tr(ref),
          value: '₹${analytics.avgOrderValue.toStringAsFixed(0)}',
          icon: Icons.trending_up_rounded,
          color: AppTheme.accentOrange,
        ),
        StatCard(
          label: 'Pending'.tr(ref),
          value: '${analytics.pendingCount}',
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFF6A1B9A),
        ),
      ],
    );
  }
}

// ─── Revenue Bar Chart ────────────────────────────────────────────────────────
class _RevenueChart extends StatelessWidget {
  final _Analytics analytics;
  const _RevenueChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final days = analytics.revenueByDay.entries.toList();
    final maxY = days.fold(0.0, (m, e) => e.value > m ? e.value : m);
    final adjustedMax = maxY < 100 ? 100.0 : maxY * 1.2;

    return BarChart(
      BarChartData(
        maxY: adjustedMax,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppTheme.textDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '₹${rod.toY.toStringAsFixed(0)}',
              const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                '₹${value.toInt()}',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textGrey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) return const SizedBox();
                return Text(
                  DateFormat('EEE').format(days[idx].key),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textGrey,
                    fontFamily: 'Poppins',
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppTheme.dividerColor,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: days.asMap().entries.map((e) {
          final isToday = e.key == days.length - 1;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: isToday
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryGreen.withOpacity(0.4),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Status Pie Chart ─────────────────────────────────────────────────────────
class _StatusPieChart extends StatefulWidget {
  final _Analytics analytics;
  const _StatusPieChart({required this.analytics});

  @override
  State<_StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<_StatusPieChart> {
  int _touchedIndex = -1;

  static const _statusColors = {
    OrderStatus.pending: Color(0xFFFF6F00),
    OrderStatus.confirmed: Color(0xFF1565C0),
    OrderStatus.preparing: Color(0xFF6A1B9A),
    OrderStatus.outForDelivery: Color(0xFF00838F),
    OrderStatus.delivered: Color(0xFF2E7D32),
    OrderStatus.cancelled: Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    final counts = widget.analytics.countByStatus;
    if (counts.isEmpty) {
      return const Center(
        child: Text('No order data yet', style: AppTextStyles.subtitle),
      );
    }

    final sections = counts.entries.map((e) {
      final idx = e.key.index;
      final isTouched = idx == _touchedIndex;
      return PieChartSectionData(
        color: _statusColors[e.key] ?? AppTheme.textGrey,
        value: e.value.toDouble(),
        title: isTouched ? '${e.value}' : '',
        radius: isTouched ? 65 : 55,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: counts.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColors[e.key] ?? AppTheme.textGrey,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Consumer(
                    builder: (context, ref, child) {
                      return Text(
                        '${e.key.label.tr(ref)} (${e.value})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textGrey,
                          fontFamily: 'Poppins',
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Top Vegetables ───────────────────────────────────────────────────────────
class _TopVegetablesList extends ConsumerWidget {
  final _Analytics analytics;
  const _TopVegetablesList({required this.analytics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = analytics.topVegetables;
    if (top.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No sales data yet'.tr(ref), style: AppTextStyles.subtitle),
      );
    }

    final maxQty = top.first.value;

    return Column(
      children: top.asMap().entries.map((e) {
        final rank = e.key + 1;
        final entry = e.value;
        final pct = maxQty > 0 ? entry.value / maxQty : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: rank == 1 ? AppTheme.accentOrange : AppTheme.textGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(1)}${' kg sold'.tr(ref)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppTheme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rank == 1 ? AppTheme.accentOrange : AppTheme.primaryGreen,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Activity Timeline ────────────────────────────────────────────────────────
class _ActivityTimeline extends ConsumerWidget {
  final List<OrderModel> orders;
  const _ActivityTimeline({required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text('No recent activity'.tr(ref), style: AppTextStyles.subtitle),
      );
    }
    return Column(
      children: orders.asMap().entries.map((e) {
        final order = e.value;
        final isLast = e.key == orders.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 1, color: AppTheme.dividerColor),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(0)} • ',
                            style: AppTextStyles.caption,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: _statusColor(order.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.status.label.tr(ref),
                              style: TextStyle(
                                fontSize: 10,
                                color: _statusColor(order.status),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(order.orderedAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppTheme.accentOrange;
      case OrderStatus.confirmed:
        return const Color(0xFF1565C0);
      case OrderStatus.preparing:
        return const Color(0xFF6A1B9A);
      case OrderStatus.outForDelivery:
        return const Color(0xFF00838F);
      case OrderStatus.delivered:
        return AppTheme.successGreen;
      case OrderStatus.cancelled:
        return AppTheme.errorRed;
    }
  }
}

// ─── Shared Section Card ───────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
