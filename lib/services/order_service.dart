import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _collection = 'orders';

  Future<String> placeOrder({
    required UserModel customer,
    required List<CartItem> cartItems,
    String? deliveryAddress,
    String? notes,
  }) async {
    final itemsByVendor = <String, List<CartItem>>{};
    for (final item in cartItems) {
      itemsByVendor.putIfAbsent(item.vendorId, () => []).add(item);
    }

    String? firstOrderId;

    for (final vendorEntry in itemsByVendor.entries) {
      final vendorId = vendorEntry.key;
      final vendorItems = vendorEntry.value;

      final totalAmount = vendorItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      
      final order = OrderModel(
        id: '',
        vendorId: vendorId,
        customerId: customer.uid,
        customerName: customer.name,
        customerPhone: customer.phone,
        items: vendorItems.map((c) => c.toOrderItem()).toList(),
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        orderedAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
        notes: notes,
      );
      
      final ref = await _firestore.collection(_collection).add(order.toFirestore());
      firstOrderId ??= ref.id;

      // Update vegetable inventory
      for (final item in vendorItems) {
        final vegDoc = _firestore.collection('vegetables').doc(item.vegetableId);
        await _firestore.runTransaction((tx) async {
          final snap = await tx.get(vegDoc);
          final current = (snap.data()?['availableQuantityKg'] ?? 0.0).toDouble();
          final updated = (current - item.quantity).clamp(0.0, double.infinity);
          tx.update(vegDoc, {
            'availableQuantityKg': updated,
            'isAvailable': updated > 0,
            'updatedAt': Timestamp.now(),
          });
        });
      }
    }
    
    return firstOrderId ?? '';
  }

  Stream<List<OrderModel>> getAllOrders({String? vendorId}) {
    Query query = _firestore.collection(_collection);
    
    if (vendorId != null) {
      query = query.where('vendorId', isEqualTo: vendorId);
    }
    
    return query
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
          list.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
          return list;
        });
  }

  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
      return list;
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection(_collection).doc(orderId).update({
      'status': status.value,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<OrderModel?> getOrderById(String orderId) {
    return _firestore
        .collection(_collection)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
  }
}

final orderServiceProvider = Provider<OrderService>((_) => OrderService());

final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return ref.watch(orderServiceProvider).getAllOrders(vendorId: user?.uid);
});

final customerOrdersProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, customerId) {
  return ref.watch(orderServiceProvider).getCustomerOrders(customerId);
});
