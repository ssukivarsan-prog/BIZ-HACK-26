import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/vegetable_service.dart';
import '../../models/vegetable_model.dart';
import '../../theme/app_theme.dart';

/// Shows a quick bottom sheet to update just the quantity/price of a vegetable
/// without navigating to the full edit screen.
Future<void> showQuickEditSheet(
  BuildContext context,
  WidgetRef ref,
  VegetableModel veg,
) {
  final qtyCtrl = TextEditingController(text: veg.availableQuantityKg.toString());
  final priceCtrl = TextEditingController(text: veg.pricePerKg.toString());

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick Edit — ${veg.name}',
                  style: AppTextStyles.heading3,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Quantity',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        suffixText: veg.unit,
                        suffixStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppTheme.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price per ${veg.unit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppTheme.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final newQty = double.tryParse(qtyCtrl.text.trim());
              final newPrice = double.tryParse(priceCtrl.text.trim());
              if (newQty == null || newPrice == null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please enter valid numbers')),
                );
                return;
              }
              await ref.read(vegetableServiceProvider).updateVegetable(
                    veg.copyWith(
                      availableQuantityKg: newQty,
                      pricePerKg: newPrice,
                    ),
                  );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('${veg.name} updated!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    ),
  );
}
