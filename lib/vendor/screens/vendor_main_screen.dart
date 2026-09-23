import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'vendor_dashboard_screen.dart';
import 'vendor_inventory_screen.dart';
import 'vendor_orders_screen.dart';
import 'vendor_analytics_screen.dart';
import 'vendor_profile_screen.dart';

import '../../services/order_service.dart';
import '../../notifications/notification_service.dart';
import '../../l10n/app_translations.dart';

class VendorMainScreen extends ConsumerStatefulWidget {
  const VendorMainScreen({super.key});

  @override
  ConsumerState<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends ConsumerState<VendorMainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    VendorDashboardScreen(),
    VendorInventoryScreen(),
    VendorOrdersScreen(),
    VendorAnalyticsScreen(),
    VendorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen(allOrdersProvider, (previous, next) {
      final prevList = previous?.value;
      final nextList = next.value;
      if (prevList != null && nextList != null && nextList.length > prevList.length) {
        final newOrder = nextList.first;
        ref.read(notificationServiceProvider).showLocalNotification(
          title: 'New Order Received! 🛒'.tr(ref),
          body: '${'Order #'.tr(ref)}${newOrder.id.substring(0, 8).toUpperCase()}${' from '.tr(ref)}${newOrder.customerName}',
        );
      }
    });

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppTheme.primaryGreen.withOpacity(0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard_rounded, color: AppTheme.primaryGreen),
              label: 'Dashboard'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2_rounded, color: AppTheme.primaryGreen),
              label: 'Inventory'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryGreen),
              label: 'Orders'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryGreen),
              label: 'Analytics'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
              label: 'Profile'.tr(ref),
            ),
          ],
        ),
      ),
    );
  }
}
