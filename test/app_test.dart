import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_vendor_app/models/order_model.dart';
import 'package:veggie_vendor_app/models/vegetable_model.dart';
import 'package:veggie_vendor_app/models/user_model.dart';
import 'package:veggie_vendor_app/services/cart_notifier.dart';
import 'package:veggie_vendor_app/theme/app_theme.dart';

VegetableModel makeVeg({
  String id = 'v1',
  String vendorId = 'vendor1',
  String name = 'Tomato',
  double price = 40.0,
  double qty = 10.0,
  bool available = true,
  String unit = 'kg',
  String category = 'General',
}) =>
    VegetableModel(
      id: id,
      vendorId: vendorId,
      name: name,
      pricePerKg: price,
      availableQuantityKg: qty,
      unit: unit,
      category: category,
      isAvailable: available,
      updatedAt: DateTime(2025),
    );

void main() {
  group('CartNotifier', () {
    late CartNotifier cart;
    setUp(() => cart = CartNotifier());

    test('starts empty', () {
      expect(cart.state, isEmpty);
      expect(cart.totalAmount, 0.0);
      expect(cart.itemCount, 0);
    });
    test('add item', () {
      cart.addItem(makeVeg(), 1.5);
      expect(cart.state.length, 1);
      expect(cart.state.first.quantity, 1.5);
    });
    test('same veg accumulates', () {
      cart.addItem(makeVeg(), 1.0);
      cart.addItem(makeVeg(), 2.5);
      expect(cart.state.length, 1);
      expect(cart.state.first.quantity, 3.5);
    });
    test('two different vegs', () {
      cart.addItem(makeVeg(id: 'v1'), 1.0);
      cart.addItem(makeVeg(id: 'v2', name: 'Spinach'), 0.5);
      expect(cart.state.length, 2);
    });
    test('removeItem', () {
      cart.addItem(makeVeg(id: 'v1'), 1.0);
      cart.addItem(makeVeg(id: 'v2', name: 'Spinach'), 0.5);
      cart.removeItem('v1');
      expect(cart.state.length, 1);
      expect(cart.state.first.vegetableName, 'Spinach');
    });
    test('updateQuantity', () {
      cart.addItem(makeVeg(), 1.0);
      cart.updateQuantity('v1', 3.5);
      expect(cart.state.first.quantity, 3.5);
    });
    test('updateQuantity to zero removes', () {
      cart.addItem(makeVeg(), 1.0);
      cart.updateQuantity('v1', 0.0);
      expect(cart.state, isEmpty);
    });
    test('clearCart', () {
      cart.addItem(makeVeg(id: 'v1'), 1.0);
      cart.addItem(makeVeg(id: 'v2', name: 'X'), 2.0);
      cart.clearCart();
      expect(cart.state, isEmpty);
      expect(cart.totalAmount, 0.0);
    });
    test('totalAmount', () {
      cart.addItem(makeVeg(id: 'v1', price: 40.0), 2.0);
      cart.addItem(makeVeg(id: 'v2', price: 30.0), 1.5);
      expect(cart.totalAmount, closeTo(125.0, 0.001));
    });
    test('isInCart', () {
      expect(cart.isInCart('v1'), isFalse);
      cart.addItem(makeVeg(), 1.0);
      expect(cart.isInCart('v1'), isTrue);
      expect(cart.isInCart('v99'), isFalse);
    });
    test('quantityInCart', () {
      cart.addItem(makeVeg(), 2.5);
      expect(cart.quantityInCart('v1'), 2.5);
      expect(cart.quantityInCart('v99'), 0.0);
    });
    test('CartItem.toOrderItem', () {
      cart.addItem(makeVeg(id: 'v1', name: 'Tomato', price: 40.0, unit: 'kg'), 2.0);
      final oi = cart.state.first.toOrderItem();
      expect(oi.vegetableId, 'v1');
      expect(oi.totalPrice, 80.0);
    });
  });

  group('OrderItem', () {
    test('totalPrice', () {
      const item = OrderItem(
        vegetableId: 'v1', vegetableName: 'Tomato', vendorId: 'vendor1',
        quantity: 3.0, unit: 'kg', pricePerUnit: 40.0,
      );
      expect(item.totalPrice, 120.0);
    });
    test('toMap / fromMap round-trip', () {
      const item = OrderItem(
        vegetableId: 'v1', vegetableName: 'Carrot', vendorId: 'vendor1',
        quantity: 1.5, unit: 'kg', pricePerUnit: 30.0,
        imageUrl: 'https://example.com/carrot.jpg',
      );
      final restored = OrderItem.fromMap(item.toMap());
      expect(restored.vegetableId, item.vegetableId);
      expect(restored.quantity, item.quantity);
      expect(restored.imageUrl, item.imageUrl);
    });
  });

  group('OrderStatus', () {
    test('fromString all values', () {
      expect(OrderStatusExtension.fromString('pending'), OrderStatus.pending);
      expect(OrderStatusExtension.fromString('confirmed'), OrderStatus.confirmed);
      expect(OrderStatusExtension.fromString('preparing'), OrderStatus.preparing);
      expect(OrderStatusExtension.fromString('out_for_delivery'), OrderStatus.outForDelivery);
      expect(OrderStatusExtension.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatusExtension.fromString('cancelled'), OrderStatus.cancelled);
    });
    test('fromString unknown → pending', () {
      expect(OrderStatusExtension.fromString('bogus'), OrderStatus.pending);
    });
    test('labels', () {
      expect(OrderStatus.outForDelivery.label, 'Out for Delivery');
      expect(OrderStatus.delivered.label, 'Delivered');
    });
    test('values', () {
      expect(OrderStatus.outForDelivery.value, 'out_for_delivery');
      expect(OrderStatus.pending.value, 'pending');
    });
  });

  group('VegetableModel', () {
    final veg = makeVeg(id: 'v1', name: 'Carrot', price: 30.0, qty: 5.0, category: 'Root Vegetables');

    test('copyWith', () {
      final u = veg.copyWith(name: 'Red Carrot', pricePerKg: 35.0);
      expect(u.name, 'Red Carrot');
      expect(u.pricePerKg, 35.0);
      expect(u.id, 'v1');
    });
    test('toFirestore has required keys', () {
      final map = veg.toFirestore();
      expect(map['name'], 'Carrot');
      expect(map['isAvailable'], true);
      expect(map.containsKey('updatedAt'), isTrue);
    });
    test('categories non-empty', () {
      expect(VegetableModel.categories, isNotEmpty);
      expect(VegetableModel.categories, contains('Leafy Greens'));
    });
  });

  group('UserModel', () {
    final customer = UserModel(
      uid: 'u1', name: 'Alice', email: 'a@b.com',
      phone: '9876543210', role: UserRole.customer,
      createdAt: DateTime(2025),
    );
    test('toFirestore role = customer', () {
      expect(customer.toFirestore()['role'], 'customer');
    });
    test('vendor role serialises', () {
      final v = UserModel(
        uid: 'u2', name: 'Bob', email: 'b@c.com',
        phone: '123', role: UserRole.vendor,
        createdAt: DateTime(2025),
      );
      expect(v.toFirestore()['role'], 'vendor');
    });
    test('copyWith name', () {
      final u = customer.copyWith(name: 'Alice Singh');
      expect(u.name, 'Alice Singh');
      expect(u.uid, 'u1');
    });
  });

  group('AppTheme', () {
    test('lightTheme uses Material3', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });
    test('primaryGreen colour value', () {
      expect(AppTheme.primaryGreen, equals(const Color(0xFF2E7D32)));
    });
    test('accentOrange colour value', () {
      expect(AppTheme.accentOrange, equals(const Color(0xFFFF6F00)));
    });
  });

  group('Widget smoke tests', () {
    testWidgets('ProviderScope + MaterialApp renders', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: Text('FreshVeg'))),
        ),
      );
      expect(find.text('FreshVeg'), findsOneWidget);
    });

    testWidgets('cart total updates reactively', (tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(builder: (ctx, ref, _) {
            capturedRef = ref;
            final total = ref.watch(cartTotalProvider);
            return MaterialApp(
              home: Scaffold(body: Text('Total: $total')),
            );
          }),
        ),
      );
      await tester.pump();
      expect(find.text('Total: 0.0'), findsOneWidget);

      capturedRef.read(cartProvider.notifier).addItem(makeVeg(price: 50.0), 2.0);
      await tester.pump();
      expect(find.text('Total: 100.0'), findsOneWidget);
    });

    testWidgets('CartNotifier accessible from widget tree', (tester) async {
      late CartNotifier notifier;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(builder: (ctx, ref, _) {
            notifier = ref.read(cartProvider.notifier);
            return const MaterialApp(home: Scaffold(body: Text('ok')));
          }),
        ),
      );
      await tester.pump();
      expect(notifier.state, isEmpty);
    });
  });
}
