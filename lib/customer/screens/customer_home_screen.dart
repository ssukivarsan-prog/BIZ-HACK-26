import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/vegetable_service.dart';
import '../../services/auth_service.dart';
import '../../services/cart_notifier.dart';
import '../../models/vegetable_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';
import '../../services/pre_booking_service.dart';
import '../widgets/high_demand_section.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Seed initial demo pre-bookings if empty so high-demand showcase has live data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(preBookingServiceProvider).seedInitialDemoPreBookingsIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vegsAsync = ref.watch(availableVegetablesProvider);
    final userAsync = ref.watch(currentUserProvider);
    // Categories should be localized during build
    final categories = ['All', ...VegetableModel.categories];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () => context.push('/customer/cart'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), AppTheme.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                child: userAsync.when(
                  data: (user) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Delivering to your location'.tr(ref),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'Hello, '.tr(ref)}${user?.name.split(' ').first ?? 'there'.tr(ref)}! 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'What fresh veggies do you need today?'.tr(ref),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search vegetables...'.tr(ref),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(Icons.close, size: 18, color: AppTheme.textGrey),
                            )
                          : null,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),

                  // Promo banner
                  _PromoBanner().animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 20),

                  // Category chips
                  SectionHeader(title: 'Browse by Category'.tr(ref)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  final selected = _selectedCategory == cat;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Text(cat.tr(ref)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      selectedColor: AppTheme.primaryGreen,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.textGrey,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
          ),

          // High Demand produce section driven by real-time pre-bookings
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: HighDemandSection(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader(title: 'Fresh Today'.tr(ref)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _isGridView = true),
                        icon: Icon(
                          Icons.grid_view_rounded,
                          color: _isGridView ? AppTheme.primaryGreen : AppTheme.textGrey,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() => _isGridView = false),
                        icon: Icon(
                          Icons.view_list_rounded,
                          color: !_isGridView ? AppTheme.primaryGreen : AppTheme.textGrey,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Vegetables grid/list
          vegsAsync.when(
            data: (vegs) {
              final filtered = vegs.where((v) {
                final matchSearch = v.name.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchCat = _selectedCategory == 'All' || v.category == _selectedCategory;
                return matchSearch && matchCat;
              }).toList();

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    title: 'No vegetables found'.tr(ref),
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try a different search'.tr(ref)
                        : 'No vegetables available today'.tr(ref),
                    icon: Icons.eco_outlined,
                  ),
                );
              }

              if (_isGridView) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _VegetableGridCard(
                        vegetable: filtered[i],
                      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().scale(begin: const Offset(0.95, 0.95)),
                      childCount: filtered.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
                );
              } else {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _VegetableListCard(vegetable: filtered[i])
                            .animate(delay: Duration(milliseconds: i * 40))
                            .fadeIn()
                            .slideX(begin: 0.05),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                );
              }
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const ShimmerBox(height: 200),
                  childCount: 6,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
            error: (e, _) {
              final isAuthError = e.toString().contains('permission-denied');
              return SliverToBoxAdapter(
                child: EmptyStateWidget(
                  title: isAuthError ? 'Account Error'.tr(ref) : 'Oops, something went wrong'.tr(ref),
                  subtitle: isAuthError 
                    ? 'Your customer account data is missing. Please go to Profile, log out, and sign up again.'.tr(ref) 
                    : e.toString(),
                  icon: isAuthError ? Icons.no_accounts_outlined : Icons.error_outline_rounded,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fresh Daily Delivery'.tr(ref),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Farm fresh vegetables, every morning'.tr(ref),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _VegetableGridCard extends ConsumerWidget {
  final VegetableModel vegetable;

  const _VegetableGridCard({required this.vegetable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(cartProvider.select(
      (cart) => cart.any((e) => e.vegetableId == vegetable.id),
    ));
    final qtyInCart = ref.read(cartProvider.notifier).quantityInCart(vegetable.id);

    return GestureDetector(
      onTap: () => context.push('/customer/vegetable/${vegetable.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: inCart ? AppTheme.primaryGreen.withOpacity(0.4) : AppTheme.dividerColor,
            width: inCart ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: AppNetworkImage(
                      imageUrl: vegetable.imageUrl,
                      category: vegetable.category,
                      height: double.infinity,
                      borderRadius: 0,
                    ),
                  ),
                if (!vegetable.isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Center(
                        child: Text(
                          'Out of Stock'.tr(ref),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vegetable.category.tr(ref),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.textGrey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vegetable.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vegetable.availableQuantityKg} ${vegetable.unit}${' left'.tr(ref)}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${vegetable.pricePerKg}/${vegetable.unit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.primaryGreen,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (vegetable.isAvailable)
                        GestureDetector(
                          onTap: () => _addToCart(ref),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: inCart ? AppTheme.primaryGreen : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            child: Icon(
                              inCart ? Icons.check_rounded : Icons.add_rounded,
                              size: 16,
                              color: inCart ? Colors.white : AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(WidgetRef ref) {
    ref.read(cartProvider.notifier).addItem(vegetable, 1);
  }
}

class _VegetableListCard extends ConsumerWidget {
  final VegetableModel vegetable;

  const _VegetableListCard({required this.vegetable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(cartProvider.select(
      (cart) => cart.any((e) => e.vegetableId == vegetable.id),
    ));

    return GestureDetector(
      onTap: () => context.push('/customer/vegetable/${vegetable.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: inCart ? AppTheme.primaryGreen.withOpacity(0.3) : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: vegetable.imageUrl,
              category: vegetable.category,
              width: 70,
              height: 70,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vegetable.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Poppins'),
                  ),
                  Text(vegetable.category.tr(ref), style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    '${vegetable.availableQuantityKg} ${vegetable.unit}${' available'.tr(ref)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${vegetable.pricePerKg}/${vegetable.unit}', style: AppTextStyles.price),
                const SizedBox(height: 8),
                if (vegetable.isAvailable)
                  GestureDetector(
                    onTap: () => ref.read(cartProvider.notifier).addItem(vegetable, 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: inCart ? AppTheme.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryGreen),
                      ),
                      child: Text(
                        inCart ? 'Added'.tr(ref) : 'Add'.tr(ref),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: inCart ? Colors.white : AppTheme.primaryGreen,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
