// lib/models/pre_booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PreBookingModel {
  final String id;
  final String productId;
  final String productName;
  final String farmerId;
  final String farmerName;
  final String farmerLocation;
  final String freshnessDescription;
  final String? deliveryCapabilityNote;
  final String customerId;
  final String customerName;
  final String customerLocation;
  final double quantityRequested;
  final DateTime preferredDate;
  final String? note;
  final String status; // 'pending', 'can_deliver', 'accepted', 'rejected'
  final String? farmerResponseNote;
  final DateTime createdAt;

  const PreBookingModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.farmerId,
    this.farmerName = 'Local Farm',
    this.farmerLocation = 'Erode Farm Belt',
    this.freshnessDescription = 'Fresh harvest guarantee',
    this.deliveryCapabilityNote,
    required this.customerId,
    required this.customerName,
    this.customerLocation = 'Erode',
    required this.quantityRequested,
    required this.preferredDate,
    this.note,
    this.status = 'pending',
    this.farmerResponseNote,
    required this.createdAt,
  });

  factory PreBookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PreBookingModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? 'Local Farm',
      farmerLocation: data['farmerLocation'] ?? 'Erode Farm Belt',
      freshnessDescription: data['freshnessDescription'] ?? 'Fresh harvest guarantee',
      deliveryCapabilityNote: data['deliveryCapabilityNote'],
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? 'Customer',
      customerLocation: data['customerLocation'] ?? 'Erode',
      quantityRequested: (data['quantityRequested'] ?? 0.0).toDouble(),
      preferredDate: (data['preferredDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'],
      status: data['status'] ?? 'pending',
      farmerResponseNote: data['farmerResponseNote'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'productName': productName,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'farmerLocation': farmerLocation,
        'freshnessDescription': freshnessDescription,
        'deliveryCapabilityNote': deliveryCapabilityNote,
        'customerId': customerId,
        'customerName': customerName,
        'customerLocation': customerLocation,
        'quantityRequested': quantityRequested,
        'preferredDate': Timestamp.fromDate(preferredDate),
        'note': note,
        'status': status,
        'farmerResponseNote': farmerResponseNote,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  PreBookingModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? farmerId,
    String? farmerName,
    String? farmerLocation,
    String? freshnessDescription,
    String? deliveryCapabilityNote,
    String? customerId,
    String? customerName,
    String? customerLocation,
    double? quantityRequested,
    DateTime? preferredDate,
    String? note,
    String? status,
    String? farmerResponseNote,
    DateTime? createdAt,
  }) {
    return PreBookingModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      freshnessDescription: freshnessDescription ?? this.freshnessDescription,
      deliveryCapabilityNote: deliveryCapabilityNote ?? this.deliveryCapabilityNote,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerLocation: customerLocation ?? this.customerLocation,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      preferredDate: preferredDate ?? this.preferredDate,
      note: note ?? this.note,
      status: status ?? this.status,
      farmerResponseNote: farmerResponseNote ?? this.farmerResponseNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Represents a specific farmer option offering a crop with distinct
/// freshness descriptions, harvest windows, farm locations, and delivery ranges.
class FarmerProduceOption {
  final String farmerId;
  final String farmerName;
  final String farmLocation;
  final String freshnessDescription;
  final String deliveryCapability;
  final String harvestWindow;
  final double rating;
  final int reviewsCount;
  final String badgeText;

  const FarmerProduceOption({
    required this.farmerId,
    required this.farmerName,
    required this.farmLocation,
    required this.freshnessDescription,
    required this.deliveryCapability,
    required this.harvestWindow,
    required this.rating,
    required this.reviewsCount,
    this.badgeText = 'Certified Fresh',
  });

  static List<FarmerProduceOption> getOptionsForProduce({
    required String produceName,
    String? defaultVendorId,
    String? defaultVendorName,
  }) {
    final clean = produceName.toLowerCase().trim();
    if (clean.contains('tomato')) {
      return [
        FarmerProduceOption(
          farmerId: defaultVendorId?.isNotEmpty == true ? defaultVendorId! : 'farmer_ramasamy',
          farmerName: defaultVendorName?.isNotEmpty == true ? defaultVendorName! : 'Ramasamy Natural Farm',
          farmLocation: 'Erode - Bhavani Road (4.5 km away)',
          freshnessDescription: '🌱 Harvested at 5 AM on dispatch day • 100% natural, crisp Grade-A',
          deliveryCapability: '🚚 Can deliver within 15 km radius • Direct farm-to-door',
          harvestWindow: 'Next harvest ready in 2 days',
          rating: 4.9,
          reviewsCount: 124,
          badgeText: 'Top Rated Farm',
        ),
        const FarmerProduceOption(
          farmerId: 'farmer_kavitha',
          farmerName: 'Kavitha Agro Farms',
          farmLocation: 'Perundurai Agro Belt (11 km away)',
          freshnessDescription: '🌿 Naturally vine-ripened • Zero chemical sprays • Rich aroma',
          deliveryCapability: '🚚 Delivers across Erode & Perundurai • Within 20 km radius',
          harvestWindow: 'Next harvest ready in 3 days',
          rating: 4.8,
          reviewsCount: 89,
          badgeText: 'Pesticide-Free',
        ),
        const FarmerProduceOption(
          farmerId: 'farmer_velan',
          farmerName: 'Velan Greenfields',
          farmLocation: 'Modakkurichi (8 km away)',
          freshnessDescription: '☀️ Greenhouse hydro-fresh • Long shelf life • Uniform size',
          deliveryCapability: '🚚 Same-day evening delivery post harvest',
          harvestWindow: 'Next harvest ready in 1-2 days',
          rating: 4.7,
          reviewsCount: 56,
          badgeText: 'Hydro Fresh',
        ),
      ];
    } else if (clean.contains('onion')) {
      return [
        FarmerProduceOption(
          farmerId: defaultVendorId?.isNotEmpty == true ? defaultVendorId! : 'farmer_murugan',
          farmerName: defaultVendorName?.isNotEmpty == true ? defaultVendorName! : 'Murugan Agro Onion Belt',
          farmLocation: 'Erode - Chennimalai (9 km away)',
          freshnessDescription: '🧅 Sun-cured dry harvest • High pungency • Zero moisture loss',
          deliveryCapability: '🚚 Bulk & retail delivery up to 25 km radius',
          harvestWindow: 'Next harvest ready in 2-3 days',
          rating: 4.9,
          reviewsCount: 142,
          badgeText: 'Sun Cured',
        ),
        const FarmerProduceOption(
          farmerId: 'farmer_chellam',
          farmerName: 'Chellam Organic Lands',
          farmLocation: 'Kangeyam Road (14 km away)',
          freshnessDescription: '🌿 Organic small/medium shallots • Rich flavor • Hand graded',
          deliveryCapability: '🚚 Direct farm delivery within 18 km radius',
          harvestWindow: 'Next harvest ready in 4 days',
          rating: 4.8,
          reviewsCount: 78,
          badgeText: '100% Organic',
        ),
      ];
    } else if (clean.contains('banana')) {
      return [
        FarmerProduceOption(
          farmerId: defaultVendorId?.isNotEmpty == true ? defaultVendorId! : 'farmer_sengottaiyan',
          farmerName: defaultVendorName?.isNotEmpty == true ? defaultVendorName! : 'Sengottaiyan Banana Groves',
          farmLocation: 'Coimbatore - Pollachi Foothills (28 km away)',
          freshnessDescription: '🍌 Tree-matured Robusta bunches • Naturally ripened without carbide',
          deliveryCapability: '🚚 Cold-van delivery to Erode/Coimbatore within 40 km',
          harvestWindow: 'Next harvest ready in 3-4 days',
          rating: 4.9,
          reviewsCount: 96,
          badgeText: 'No Carbide',
        ),
        const FarmerProduceOption(
          farmerId: 'farmer_ananthi',
          farmerName: 'Ananthi Fruit Orchards',
          farmLocation: 'Bhavani River Basin (7 km away)',
          freshnessDescription: '🌿 Fresh river-soil harvest • Sweet natural aroma • Hand harvested',
          deliveryCapability: '🚚 Delivers within 15 km of Bhavani & Erode',
          harvestWindow: 'Next harvest ready in 2 days',
          rating: 4.8,
          reviewsCount: 65,
          badgeText: 'River Soil',
        ),
      ];
    } else {
      return [
        FarmerProduceOption(
          farmerId: defaultVendorId?.isNotEmpty == true ? defaultVendorId! : 'farmer_local',
          farmerName: defaultVendorName?.isNotEmpty == true ? defaultVendorName! : 'Green Valley Farm',
          farmLocation: 'Erode Local Agro Belt (6 km away)',
          freshnessDescription: '🌱 Field-fresh harvest • Directly cut on order date • Crisp quality',
          deliveryCapability: '🚚 Farm direct delivery within 15 km radius',
          harvestWindow: 'Next harvest ready in 2-3 days',
          rating: 4.8,
          reviewsCount: 45,
          badgeText: 'Direct Harvest',
        ),
        const FarmerProduceOption(
          farmerId: 'farmer_coop',
          farmerName: 'Erode Farmers Co-operative',
          farmLocation: 'Perundurai Center (10 km away)',
          freshnessDescription: '🌿 Quality tested & graded • Direct from regional farmers',
          deliveryCapability: '🚚 Scheduled co-op delivery across district',
          harvestWindow: 'Daily morning dispatch',
          rating: 4.7,
          reviewsCount: 110,
          badgeText: 'Co-op Certified',
        ),
      ];
    }
  }
}
