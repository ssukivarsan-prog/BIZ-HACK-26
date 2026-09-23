import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, confirmed, preparing, outForDelivery, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItem {
  final String vegetableId;
  final String vegetableName;
  final String vendorId;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String? imageUrl;
  final String category;

  const OrderItem({
    required this.vegetableId,
    required this.vegetableName,
    required this.vendorId,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.imageUrl,
    this.category = 'General',
  });

  double get totalPrice => quantity * pricePerUnit;

  factory OrderItem.fromMap(Map<String, dynamic> data) => OrderItem(
        vegetableId: data['vegetableId'] ?? '',
        vegetableName: data['vegetableName'] ?? '',
        vendorId: data['vendorId'] ?? '',
        quantity: (data['quantity'] ?? 0.0).toDouble(),
        unit: data['unit'] ?? 'kg',
        pricePerUnit: (data['pricePerUnit'] ?? 0.0).toDouble(),
        imageUrl: data['imageUrl'],
        category: data['category'] ?? 'General',
      );

  Map<String, dynamic> toMap() => {
        'vegetableId': vegetableId,
        'vegetableName': vegetableName,
        'vendorId': vendorId,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'imageUrl': imageUrl,
        'category': category,
      };
}

class OrderModel {
  final String id;
  final String vendorId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderedAt;
  final DateTime? updatedAt;
  final String? deliveryAddress;
  final String? notes;

  const OrderModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderedAt,
    this.updatedAt,
    this.deliveryAddress,
    this.notes,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      vendorId: data['vendorId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatusExtension.fromString(data['status'] ?? 'pending'),
      orderedAt: (data['orderedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deliveryAddress: data['deliveryAddress'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'vendorId': vendorId,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'items': items.map((e) => e.toMap()).toList(),
        'totalAmount': totalAmount,
        'status': status.value,
        'orderedAt': Timestamp.fromDate(orderedAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'deliveryAddress': deliveryAddress,
        'notes': notes,
      };

  OrderModel copyWith({OrderStatus? status}) => OrderModel(
        id: id,
        vendorId: vendorId,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        items: items,
        totalAmount: totalAmount,
        status: status ?? this.status,
        orderedAt: orderedAt,
        updatedAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
        notes: notes,
      );
}

class CartItem {
  final String vegetableId;
  final String vegetableName;
  final String vendorId;
  double quantity;
  final String unit;
  final double pricePerUnit;
  final String? imageUrl;
  final String category;

  CartItem({
    required this.vegetableId,
    required this.vegetableName,
    required this.vendorId,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.imageUrl,
    this.category = 'General',
  });

  double get totalPrice => quantity * pricePerUnit;

  OrderItem toOrderItem() => OrderItem(
        vegetableId: vegetableId,
        vegetableName: vegetableName,
        vendorId: vendorId,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        imageUrl: imageUrl,
        category: category,
      );
}
