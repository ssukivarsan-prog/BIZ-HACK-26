import 'package:cloud_firestore/cloud_firestore.dart';

class VegetableModel {
  final String id;
  final String vendorId;
  final String name;
  final double pricePerKg;
  final double availableQuantityKg;
  final String? imageUrl;
  final String unit; // 'kg', 'piece', 'bunch'
  final String category;
  final bool isAvailable;
  final DateTime updatedAt;

  const VegetableModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.pricePerKg,
    required this.availableQuantityKg,
    this.imageUrl,
    required this.unit,
    required this.category,
    required this.isAvailable,
    required this.updatedAt,
  });

  factory VegetableModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VegetableModel(
      id: doc.id,
      vendorId: data['vendorId'] ?? '',
      name: data['name'] ?? '',
      pricePerKg: (data['pricePerKg'] ?? 0.0).toDouble(),
      availableQuantityKg: (data['availableQuantityKg'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      unit: data['unit'] ?? 'kg',
      category: data['category'] ?? 'General',
      isAvailable: data['isAvailable'] ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'vendorId': vendorId,
        'name': name,
        'pricePerKg': pricePerKg,
        'availableQuantityKg': availableQuantityKg,
        'imageUrl': imageUrl,
        'unit': unit,
        'category': category,
        'isAvailable': isAvailable,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  VegetableModel copyWith({
    String? vendorId,
    String? name,
    double? pricePerKg,
    double? availableQuantityKg,
    String? imageUrl,
    String? unit,
    String? category,
    bool? isAvailable,
  }) =>
      VegetableModel(
        id: id,
        vendorId: vendorId ?? this.vendorId,
        name: name ?? this.name,
        pricePerKg: pricePerKg ?? this.pricePerKg,
        availableQuantityKg: availableQuantityKg ?? this.availableQuantityKg,
        imageUrl: imageUrl ?? this.imageUrl,
        unit: unit ?? this.unit,
        category: category ?? this.category,
        isAvailable: isAvailable ?? this.isAvailable,
        updatedAt: DateTime.now(),
      );

  static const List<String> categories = [
    'Leafy Greens',
    'Root Vegetables',
    'Gourds & Melons',
    'Beans & Pods',
    'Herbs & Spices',
    'Exotic',
    'General',
  ];
}
