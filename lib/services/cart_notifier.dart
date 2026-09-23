import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/vegetable_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(VegetableModel veg, double quantity) {
    final existing = state.where((e) => e.vegetableId == veg.id).toList();
    if (existing.isNotEmpty) {
      updateQuantity(veg.id, existing.first.quantity + quantity);
    } else {
      state = [
        ...state,
        CartItem(
          vegetableId: veg.id,
          vegetableName: veg.name,
          vendorId: veg.vendorId,
          quantity: quantity,
          unit: veg.unit,
          pricePerUnit: veg.pricePerKg,
          imageUrl: veg.imageUrl,
          category: veg.category,
        ),
      ];
    }
  }

  void updateQuantity(String vegetableId, double quantity) {
    if (quantity <= 0) {
      removeItem(vegetableId);
      return;
    }
    state = state.map((item) {
      if (item.vegetableId == vegetableId) {
        return CartItem(
          vegetableId: item.vegetableId,
          vegetableName: item.vegetableName,
          vendorId: item.vendorId,
          quantity: quantity,
          unit: item.unit,
          pricePerUnit: item.pricePerUnit,
          imageUrl: item.imageUrl,
          category: item.category,
        );
      }
      return item;
    }).toList();
  }

  void removeItem(String vegetableId) {
    state = state.where((e) => e.vegetableId != vegetableId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount =>
      state.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get itemCount => state.length;

  bool isInCart(String vegetableId) =>
      state.any((e) => e.vegetableId == vegetableId);

  double quantityInCart(String vegetableId) {
    final item = state.where((e) => e.vegetableId == vegetableId).toList();
    return item.isEmpty ? 0.0 : item.first.quantity;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (_) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).length;
});
