import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/vegetable_service.dart';
import '../../models/vegetable_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  Timer? _debounce;

  static const _recentSearches = [
    'Tomato', 'Spinach', 'Carrot', 'Onion', 'Potato'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vegsAsync = ref.watch(availableVegetablesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Search vegetables...'.tr(ref),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: vegsAsync.when(
        data: (vegs) {
          if (_query.isEmpty) {
            return _EmptySearchState(
              recentSearches: _recentSearches,
              categories: VegetableModel.categories,
              onSearch: (q) {
                _ctrl.text = q;
                setState(() => _query = q);
              },
              onCategory: (cat) => context.pop(cat),
            );
          }

          final results = vegs
              .where((v) =>
                  v.name.toLowerCase().contains(_query.toLowerCase()) ||
                  v.category.toLowerCase().contains(_query.toLowerCase()))
              .toList();

          if (results.isEmpty) {
            return EmptyStateWidget(
              title: '${'No results for'.tr(ref)} "$_query"',
              subtitle: 'Try a different search term or browse categories'.tr(ref),
              icon: Icons.search_off_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final veg = results[i];
              return GestureDetector(
                onTap: () => context.push('/customer/vegetable/${veg.id}'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      AppNetworkImage(
                          imageUrl: veg.imageUrl, category: veg.category, width: 56, height: 56, borderRadius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HighlightedText(text: veg.name, query: _query),
                            Text(veg.category.tr(ref), style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Text(
                              '${veg.availableQuantityKg} ${veg.unit}${' available'.tr(ref)}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${veg.pricePerKg}/${veg.unit}', style: AppTextStyles.price),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: veg.isAvailable
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              veg.isAvailable ? 'In Stock'.tr(ref) : 'Out'.tr(ref),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: veg.isAvailable
                                    ? AppTheme.successGreen
                                    : AppTheme.errorRed,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: i * 40)).fadeIn().slideX(begin: 0.05),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${'Error: '.tr(ref)}$e')),
      ),
    );
  }
}

class _EmptySearchState extends ConsumerWidget {
  final List<String> recentSearches;
  final List<String> categories;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCategory;

  const _EmptySearchState({
    required this.recentSearches,
    required this.categories,
    required this.onSearch,
    required this.onCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Recent Searches'.tr(ref), style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches
              .map((s) => GestureDetector(
                    onTap: () => onSearch(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history_rounded,
                              size: 14, color: AppTheme.textGrey),
                          const SizedBox(width: 6),
                          Text(s,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.textGrey)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 28),
        Text('Browse Categories'.tr(ref), style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3,
          children: categories
              .map((cat) => GestureDetector(
                    onTap: () => onCategory(cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco_outlined,
                              size: 16, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat.tr(ref),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins'));
    }

    final lower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final start = lower.indexOf(queryLower);

    if (start == -1) {
      return Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins'));
    }

    final end = start + query.length;
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Poppins',
            color: AppTheme.textDark),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
              backgroundColor: Color(0xFFFFF9C4),
              color: AppTheme.textDark,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}
