import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/vegetable_service.dart';
import '../../models/vegetable_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';
import '../widgets/farmer_produce_detail_sheet.dart';

class VendorInventoryScreen extends ConsumerStatefulWidget {
  const VendorInventoryScreen({super.key});

  @override
  ConsumerState<VendorInventoryScreen> createState() => _VendorInventoryScreenState();
}

class _VendorInventoryScreenState extends ConsumerState<VendorInventoryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final vegsAsync = ref.watch(vegetablesStreamProvider);
    final categories = ['All', ...VegetableModel.categories];

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'.tr(ref)),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/vendor/add-vegetable'),
            icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryGreen),
            label: Text('Add'.tr(ref), style: const TextStyle(color: AppTheme.primaryGreen, fontFamily: 'Poppins')),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: AppSearchBar(
              controller: _searchCtrl,
              hint: 'Search vegetables...'.tr(ref),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final selected = _selectedCategory == cat;
                return FilterChip(
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
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: vegsAsync.when(
              data: (vegs) {
                final filtered = vegs.where((v) {
                  final matchSearch = v.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchCat = _selectedCategory == 'All' || v.category == _selectedCategory;
                  return matchSearch && matchCat;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No vegetables found'.tr(ref),
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try a different search term'.tr(ref)
                        : 'Add your first vegetable to get started'.tr(ref),
                    icon: Icons.eco_outlined,
                    buttonLabel: 'Add Vegetable'.tr(ref),
                    onButton: () => context.push('/vendor/add-vegetable'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _VegetableCard(
                    vegetable: filtered[i],
                    onEdit: () => context.push('/vendor/edit-vegetable/${filtered[i].id}'),
                    onDelete: () => _confirmDelete(filtered[i]),
                    onToggle: () => _toggleAvailability(filtered[i]),
                  ).animate(delay: Duration(milliseconds: i * 40)).fadeIn().slideY(begin: 0.1),
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) => const ShimmerBox(height: 90),
              ),
              error: (e, _) => Center(child: Text('${'Error: '.tr(ref)}$e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(VegetableModel veg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Vegetable'.tr(ref), style: AppTextStyles.heading3),
        content: Text('${'Are you sure you want to delete "'.tr(ref)}${veg.name}${'"? This cannot be undone.'.tr(ref)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr(ref))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete'.tr(ref), style: const TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(vegetableServiceProvider).deleteVegetable(veg.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${veg.name}${' deleted'.tr(ref)}')),
        );
      }
    }
  }

  Future<void> _toggleAvailability(VegetableModel veg) async {
    await ref.read(vegetableServiceProvider).updateVegetable(
      veg.copyWith(isAvailable: !veg.isAvailable),
    );
  }
}

class _VegetableCard extends ConsumerWidget {
  final VegetableModel vegetable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _VegetableCard({
    required this.vegetable,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => FarmerProduceDetailSheet.show(context, vegetable),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              AppNetworkImage(imageUrl: vegetable.imageUrl, category: vegetable.category, width: 60, height: 60, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vegetable.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Poppins'),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: vegetable.isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            vegetable.isAvailable ? 'In Stock'.tr(ref) : 'Out'.tr(ref),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: vegetable.isAvailable ? AppTheme.successGreen : AppTheme.errorRed,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${vegetable.pricePerKg}/${vegetable.unit} • ${vegetable.availableQuantityKg} ${vegetable.unit}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(vegetable.category.tr(ref), style: AppTextStyles.caption),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_graph_rounded, size: 10, color: AppTheme.primaryGreen),
                              SizedBox(width: 3),
                              Text(
                                'Insights & Matches',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryGreen,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppTheme.textGrey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text('Edit'.tr(ref))),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(vegetable.isAvailable ? 'Mark Out of Stock'.tr(ref) : 'Mark In Stock'.tr(ref)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'.tr(ref), style: const TextStyle(color: AppTheme.errorRed)),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'toggle') onToggle();
                  if (val == 'delete') onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
