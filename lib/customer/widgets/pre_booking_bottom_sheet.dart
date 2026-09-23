// lib/customer/widgets/pre_booking_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/pre_booking_model.dart';
import '../../models/vegetable_model.dart';
import '../../services/auth_service.dart';
import '../../services/pre_booking_service.dart';
import '../../theme/app_theme.dart';

class PreBookingBottomSheet extends ConsumerStatefulWidget {
  final VegetableModel vegetable;

  const PreBookingBottomSheet({super.key, required this.vegetable});

  static void show(BuildContext context, VegetableModel vegetable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PreBookingBottomSheet(vegetable: vegetable),
    );
  }

  @override
  ConsumerState<PreBookingBottomSheet> createState() => _PreBookingBottomSheetState();
}

class _PreBookingBottomSheetState extends ConsumerState<PreBookingBottomSheet> {
  final _qtyCtrl = TextEditingController(text: '10');
  final _locationCtrl = TextEditingController(text: 'Gandhi Nagar, Erode');
  final _noteCtrl = TextEditingController();
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 3));
  bool _isSubmitting = false;

  late List<FarmerProduceOption> _farmerOptions;
  late FarmerProduceOption _selectedFarmer;

  @override
  void initState() {
    super.initState();
    _farmerOptions = FarmerProduceOption.getOptionsForProduce(
      produceName: widget.vegetable.name,
      defaultVendorId: widget.vegetable.vendorId,
    );
    _selectedFarmer = _farmerOptions.first;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _locationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final qty = double.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity in kg')),
      );
      return;
    }

    final custLocation = _locationCtrl.text.trim();
    if (custLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your delivery location/area')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final currentUser = ref.read(currentUserProvider).value;
      final preBooking = PreBookingModel(
        id: '',
        productId: widget.vegetable.id,
        productName: widget.vegetable.name,
        farmerId: _selectedFarmer.farmerId,
        farmerName: _selectedFarmer.farmerName,
        farmerLocation: _selectedFarmer.farmLocation,
        freshnessDescription: _selectedFarmer.freshnessDescription,
        deliveryCapabilityNote: _selectedFarmer.deliveryCapability,
        customerId: currentUser?.uid ?? 'guest_customer',
        customerName: currentUser?.name ?? 'Registered Customer',
        customerLocation: custLocation,
        quantityRequested: qty,
        preferredDate: _preferredDate,
        note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ref.read(preBookingServiceProvider).createPreBooking(preBooking);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primaryGreen,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pre-booking for ${qty.toStringAsFixed(0)} kg ${widget.vegetable.name} submitted to ${_selectedFarmer.farmerName}!',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit pre-booking: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _preferredDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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
              const SizedBox(height: 14),

              // Title & Produce summary
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Pre-Book Produce',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DEMAND SIGNAL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB45309),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.vegetable.name} • ₹${widget.vegetable.pricePerKg.toStringAsFixed(0)}/${widget.vegetable.unit}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
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
              const Divider(height: 1, color: AppTheme.dividerColor),
              const SizedBox(height: 16),

              // 1. SELECT SPECIFIC FARMER & FRESHNESS GUARANTEE
              Row(
                children: [
                  const Icon(Icons.agriculture_rounded, size: 18, color: AppTheme.primaryGreen),
                  const SizedBox(width: 6),
                  const Text(
                    'Select Specific Farmer & Freshness',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_farmerOptions.length} available',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a farmer based on harvest freshness description, distance, and delivery reach:',
                style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),

              // Farmer option cards
              ...List.generate(_farmerOptions.length, (idx) {
                final option = _farmerOptions[idx];
                final isSelected = _selectedFarmer.farmerId == option.farmerId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFarmer = option),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryGreen : AppTheme.dividerColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option.farmerName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                option.badgeText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? const Color(0xFF15803D) : const Color(0xFF1D4ED8),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Farm Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textGrey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                option.farmLocation,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                              ),
                            ),
                            Text(
                              '⭐ ${option.rating} (${option.reviewsCount})',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Freshness guarantee
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            option.freshnessDescription,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Delivery capability & harvest window
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.deliveryCapability,
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF4B5563), fontFamily: 'Poppins'),
                              ),
                            ),
                            Text(
                              option.harvestWindow,
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280), fontStyle: FontStyle.italic, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // 2. REQUIRED QUANTITY (KG)
              const Text(
                'Required Quantity (kg)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.scale_rounded, size: 20, color: AppTheme.primaryGreen),
                        suffixText: 'kg',
                        hintText: 'e.g. 20',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.dividerColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick add chips
              Wrap(
                spacing: 8,
                children: [5, 10, 25, 50, 100].map((q) {
                  return ActionChip(
                    label: Text('+$q kg', style: const TextStyle(fontSize: 11, fontFamily: 'Poppins')),
                    backgroundColor: const Color(0xFFF0FDF4),
                    side: const BorderSide(color: Color(0xFFBBF7D0)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final current = double.tryParse(_qtyCtrl.text) ?? 0.0;
                      _qtyCtrl.text = (current + q).toStringAsFixed(0);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // 3. CUSTOMER DELIVERY LOCATION
              const Text(
                'Your Delivery Location / Area',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_rounded, size: 20, color: AppTheme.primaryGreen),
                  hintText: 'e.g. Gandhi Nagar, Erode Central',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. PREFERRED HARVEST / DELIVERY DATE
              const Text(
                'Preferred Harvest / Delivery Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 20, color: AppTheme.primaryGreen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, dd MMMM yyyy').format(_preferredDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textGrey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. OPTIONAL NOTE FOR FARMER
              const Text(
                'Optional Note for Farmer',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Need fresh morning harvest for wholesale',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Non-purchase disclaimer note
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pre-booking is an advance harvest signal directly to ${_selectedFarmer.farmerName}. The farmer will review whether they can deliver to your area. Zero payment charged now.',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, height: 1.35, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_rounded, size: 18),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Confirm Pre-Booking with ${_selectedFarmer.farmerName.split(' ').first}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
