import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/vegetable_service.dart';
import '../../services/auth_service.dart';
import '../../models/vegetable_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';
import '../widgets/smart_market_insight_card.dart';
import '../widgets/smart_buyer_matching_card.dart';

class AddVegetableScreen extends ConsumerStatefulWidget {
  final String? vegetableId;
  const AddVegetableScreen({super.key, this.vegetableId});

  @override
  ConsumerState<AddVegetableScreen> createState() => _AddVegetableScreenState();
}

class _AddVegetableScreenState extends ConsumerState<AddVegetableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  String _unit = 'kg';
  String _category = VegetableModel.categories.first;
  File? _pickedImage;
  String? _existingImageUrl;
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _isFetching = false;
  VegetableModel? _existing;

  final _units = ['kg', 'piece', 'bunch', 'g', 'litre'];

  bool get _isEditing => widget.vegetableId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _isFetching = true);
    final veg = await ref.read(vegetableServiceProvider).getVegetableById(widget.vegetableId!);
    if (veg != null && mounted) {
      _existing = veg;
      _nameCtrl.text = veg.name;
      _priceCtrl.text = veg.pricePerKg.toString();
      _qtyCtrl.text = veg.availableQuantityKg.toString();
      _unit = veg.unit;
      _category = veg.category;
      _isAvailable = veg.isAvailable;
      _existingImageUrl = veg.imageUrl;
    }
    if (mounted) setState(() => _isFetching = false);
  }

  // Image picking removed. Image is mapped to category.

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw 'User not found';

      final veg = VegetableModel(
        id: _existing?.id ?? '',
        vendorId: _existing?.vendorId ?? user.uid,
        name: _nameCtrl.text.trim(),
        pricePerKg: double.parse(_priceCtrl.text.trim()),
        availableQuantityKg: double.parse(_qtyCtrl.text.trim()),
        unit: _unit,
        category: _category,
        isAvailable: _isAvailable,
        imageUrl: _existingImageUrl,
        updatedAt: DateTime.now(),
      );

      final svc = ref.read(vegetableServiceProvider);
      if (_isEditing) {
        await svc.updateVegetable(veg);
      } else {
        await svc.addVegetable(veg);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Vegetable updated!'.tr(ref) : 'Vegetable added!'.tr(ref))),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'Error: '.tr(ref)}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...'.tr(ref))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vegetable'.tr(ref) : 'Add Vegetable'.tr(ref)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Category Image Preview
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppNetworkImage(
                  imageUrl: _existingImageUrl,
                  category: _category,
                  height: 160,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Image automatically matches category'.tr(ref),
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 24),

            _label('Vegetable Name'.tr(ref)),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: 'e.g. Tomato'.tr(ref)),
              validator: (v) => v == null || v.isEmpty ? 'Name is required'.tr(ref) : null,
            ).animate(delay: 50.ms).fadeIn(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Price per unit (₹)'.tr(ref)),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '0.00'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required'.tr(ref);
                          if (double.tryParse(v) == null) return 'Invalid number'.tr(ref);
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Available Qty'.tr(ref)),
                      TextFormField(
                        controller: _qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '0.0'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required'.tr(ref);
                          if (double.tryParse(v) == null) return 'Invalid'.tr(ref);
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 16),

            _label('Unit'.tr(ref)),
            DropdownButtonFormField<String>(
              initialValue: _unit,
              decoration: const InputDecoration(),
              borderRadius: BorderRadius.circular(12),
              items: _units
                  .map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u.tr(ref), style: const TextStyle(fontFamily: 'Poppins')),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _unit = v!),
            ).animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: 16),

            _label('Category'.tr(ref)),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(),
              borderRadius: BorderRadius.circular(12),
              items: VegetableModel.categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.tr(ref), style: const TextStyle(fontFamily: 'Poppins')),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Mark as Available'.tr(ref)),
                Switch.adaptive(
                  value: _isAvailable,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (v) => setState(() => _isAvailable = v),
                ),
              ],
            ).animate(delay: 250.ms).fadeIn(),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Update Vegetable'.tr(ref) : 'Add Vegetable'.tr(ref)),
            ).animate(delay: 300.ms).fadeIn(),

            if (_isEditing) ...[
              const SizedBox(height: 28),
              const Divider(color: AppTheme.dividerColor),
              const SizedBox(height: 12),
              SmartMarketInsightCard(cropName: _nameCtrl.text),
              const SizedBox(height: 12),
              SmartBuyerMatchingCard(
                cropName: _nameCtrl.text,
                availableQuantity: double.tryParse(_qtyCtrl.text) ?? 0.0,
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textGrey,
            fontFamily: 'Poppins',
          ),
        ),
      );
}
