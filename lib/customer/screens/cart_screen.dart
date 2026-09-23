import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/cart_notifier.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../l10n/app_translations.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isPlacing = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    setState(() => _isPlacing = true);
    try {
      final orderId = await ref.read(orderServiceProvider).placeOrder(
        customer: user,
        cartItems: cart,
        deliveryAddress: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      ref.read(cartProvider.notifier).clearCart();
      if (mounted) {
        context.go('/customer/order-confirmation/$orderId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'Error: '.tr(ref)}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'.tr(ref)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: Text(
                'Clear'.tr(ref),
                style: const TextStyle(color: AppTheme.errorRed, fontFamily: 'Poppins'),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyStateWidget(
              title: 'Your cart is empty'.tr(ref),
              subtitle: 'Add fresh vegetables from our store'.tr(ref),
              icon: Icons.shopping_cart_outlined,
              buttonLabel: 'Browse Vegetables'.tr(ref),
              onButton: () => context.pop(),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cart items
                        ...cart.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CartItemCard(
                                item: e.value,
                                onRemove: () => ref
                                    .read(cartProvider.notifier)
                                    .removeItem(e.value.vegetableId),
                                onIncrease: () => ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(e.value.vegetableId, e.value.quantity + 0.5),
                                onDecrease: () => ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(e.value.vegetableId, e.value.quantity - 0.5),
                              ).animate(delay: Duration(milliseconds: e.key * 50)).fadeIn().slideY(begin: 0.1),
                            )),
                        const SizedBox(height: 20),

                        // Delivery address
                        Text('Delivery Address'.tr(ref), style: AppTextStyles.heading3),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addressCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Enter delivery address (optional)'.tr(ref),
                            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Notes'.tr(ref), style: AppTextStyles.heading3),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesCtrl,
                          decoration: InputDecoration(
                            hintText: 'Any special instructions? (optional)'.tr(ref),
                            prefixIcon: const Icon(Icons.note_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bill summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bill Summary'.tr(ref), style: AppTextStyles.heading3),
                              const SizedBox(height: 12),
                              const Divider(color: AppTheme.dividerColor, height: 1),
                              const SizedBox(height: 12),
                              ...cart.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item.vegetableName} × ${item.quantity}${item.unit}',
                                          style: AppTextStyles.body,
                                        ),
                                        Text(
                                          '₹${item.totalPrice.toStringAsFixed(2)}',
                                          style: AppTextStyles.body,
                                        ),
                                      ],
                                    ),
                                  )),
                              const Divider(color: AppTheme.dividerColor, height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total'.tr(ref),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    '₹${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryGreen,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                // Bottom CTA
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppTheme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Total'.tr(ref), style: AppTextStyles.caption),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isPlacing ? null : _placeOrder,
                          child: _isPlacing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Place Order'.tr(ref)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.vegetableId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            AppNetworkImage(imageUrl: item.imageUrl, category: item.category, width: 56, height: 56, borderRadius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.vegetableName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins')),
                  Text('₹${item.pricePerUnit}/${item.unit}', style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.price,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SmallQtyBtn(icon: Icons.remove_rounded, onTap: onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins'),
                      ),
                    ),
                    _SmallQtyBtn(icon: Icons.add_rounded, onTap: onIncrease, isPrimary: true),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _SmallQtyBtn({required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isPrimary ? AppTheme.primaryGreen : AppTheme.dividerColor),
        ),
        child: Icon(icon, size: 14, color: isPrimary ? Colors.white : AppTheme.textDark),
      ),
    );
  }
}
