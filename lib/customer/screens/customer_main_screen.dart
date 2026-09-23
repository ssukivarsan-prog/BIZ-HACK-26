import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/cart_notifier.dart';
import '../../theme/app_theme.dart';
import 'customer_home_screen.dart';
import 'customer_orders_screen.dart';
import 'customer_profile_screen.dart';
import '../../l10n/app_translations.dart';

class CustomerMainScreen extends ConsumerStatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    CustomerHomeScreen(),
    CustomerOrdersScreen(),
    CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: cartCount > 0 && _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/customer/cart'),
              backgroundColor: AppTheme.primaryGreen,
              elevation: 4,
              icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
              label: Text(
                '$cartCount${cartCount > 1 ? ' items'.tr(ref) : ' item'.tr(ref)}${' in cart'.tr(ref)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          : null,
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
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded, color: AppTheme.primaryGreen),
              label: 'Home'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryGreen),
              label: 'My Orders'.tr(ref),
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
