// lib/services/demand_calculation_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pre_booking_model.dart';
import 'pre_booking_service.dart';
import 'vegetable_service.dart';

enum ProduceDemandLevel {
  high,
  moderate,
  low,
  insufficientData,
}

class ProduceDemandInsight {
  final String productName;
  final String? productId;
  final double availableQuantity;
  final double totalPreBookedQuantity;
  final int preBookingCount;
  final double demandRatio;
  final double demandScore;
  final ProduceDemandLevel demandLevel;
  final List<PreBookingModel> preBookings;

  const ProduceDemandInsight({
    required this.productName,
    this.productId,
    required this.availableQuantity,
    required this.totalPreBookedQuantity,
    required this.preBookingCount,
    required this.demandRatio,
    required this.demandScore,
    required this.demandLevel,
    this.preBookings = const [],
  });

  String get demandLabel {
    switch (demandLevel) {
      case ProduceDemandLevel.high:
        return 'HIGH DEMAND';
      case ProduceDemandLevel.moderate:
        return 'MODERATE DEMAND';
      case ProduceDemandLevel.low:
        return 'LOW DEMAND';
      case ProduceDemandLevel.insufficientData:
        return 'INSUFFICIENT DATA';
    }
  }

  String get emoji {
    switch (demandLevel) {
      case ProduceDemandLevel.high:
        return '🔥';
      case ProduceDemandLevel.moderate:
        return '⚡';
      case ProduceDemandLevel.low:
        return '❄️';
      case ProduceDemandLevel.insufficientData:
        return '📊';
    }
  }

  String get shortReason {
    switch (demandLevel) {
      case ProduceDemandLevel.high:
        return 'Pre-booked requests exceed 75% of available inventory.';
      case ProduceDemandLevel.moderate:
        return 'Steady pre-booking volume balanced with available stock.';
      case ProduceDemandLevel.low:
        return 'Available inventory currently exceeds pre-booking volume.';
      case ProduceDemandLevel.insufficientData:
        return 'No pre-booking requests received yet.';
    }
  }
}

class DemandCalculationService {
  DemandCalculationService._();
  static final DemandCalculationService instance = DemandCalculationService._();

  /// Default baseline available inventory for demo produce if not in inventory yet.
  static const Map<String, double> defaultAvailableQuantities = {
    'tomato': 100.0,
    'onion': 150.0,
    'banana': 200.0,
    'carrot': 100.0,
  };

  /// Calculates dynamic demand insight for a produce given its name, available quantity,
  /// and the active pre-bookings list from Firestore.
  ProduceDemandInsight calculateDemand({
    required String productName,
    String? productId,
    required double availableQuantity,
    required List<PreBookingModel> allPreBookings,
  }) {
    final cleanName = productName.toLowerCase().trim();

    // Match pre-bookings belonging to this produce (by productId or name)
    final matchedBookings = allPreBookings.where((b) {
      final bName = b.productName.toLowerCase().trim();
      final bId = b.productId.trim();
      final isIdMatch = productId != null && productId.isNotEmpty && bId == productId;
      final isNameMatch = cleanName.contains(bName) || bName.contains(cleanName);
      return isIdMatch || isNameMatch;
    }).toList();

    final preBookingCount = matchedBookings.length;
    final totalPreBookedQuantity = matchedBookings.fold<double>(
      0.0,
      (sum, b) => sum + b.quantityRequested,
    );

    // Resolve available quantity
    double effectiveAvailable = availableQuantity;
    if (effectiveAvailable <= 0) {
      effectiveAvailable = defaultAvailableQuantities[cleanName] ?? 100.0;
    }

    if (preBookingCount == 0 && totalPreBookedQuantity == 0) {
      return ProduceDemandInsight(
        productName: productName,
        productId: productId,
        availableQuantity: effectiveAvailable,
        totalPreBookedQuantity: 0.0,
        preBookingCount: 0,
        demandRatio: 0.0,
        demandScore: 0.0,
        demandLevel: ProduceDemandLevel.insufficientData,
        preBookings: [],
      );
    }

    // 1. Demand ratio = preBooked / available
    final demandRatio = effectiveAvailable > 0
        ? (totalPreBookedQuantity / effectiveAvailable)
        : 1.0;

    // 2. Explainable transparent score:
    // 60% based on requested quantity / available quantity (ratio 1.0 = 60 pts)
    final quantityComponent = (demandRatio * 60.0).clamp(0.0, 60.0);
    // 40% based on number of pre-booking requests (10 requests = 40 pts)
    final countComponent = ((preBookingCount / 10.0) * 40.0).clamp(0.0, 40.0);

    final demandScore = (quantityComponent + countComponent).clamp(0.0, 100.0);

    // 3. Classification according to user specifications:
    // HIGH: demandRatio >= 0.75 (or score >= 70)
    // MODERATE: 0.40 <= demandRatio < 0.75 (or 40 <= score < 70)
    // LOW: demandRatio < 0.40
    ProduceDemandLevel level;
    if (demandRatio >= 0.75 || demandScore >= 70.0) {
      level = ProduceDemandLevel.high;
    } else if (demandRatio >= 0.40 || demandScore >= 40.0) {
      level = ProduceDemandLevel.moderate;
    } else {
      level = ProduceDemandLevel.low;
    }

    return ProduceDemandInsight(
      productName: productName,
      productId: productId,
      availableQuantity: effectiveAvailable,
      totalPreBookedQuantity: totalPreBookedQuantity,
      preBookingCount: preBookingCount,
      demandRatio: demandRatio,
      demandScore: demandScore,
      demandLevel: level,
      preBookings: matchedBookings,
    );
  }
}

/// Provider that aggregates all vegetables with all active pre-bookings from Firestore
/// and returns a list of ProduceDemandInsight.
final allProduceDemandListProvider = Provider<List<ProduceDemandInsight>>((ref) {
  final preBookingsAsync = ref.watch(allPreBookingsStreamProvider);
  final allVegetablesAsync = ref.watch(availableVegetablesProvider);

  final preBookings = preBookingsAsync.value ?? [];
  final vegetables = allVegetablesAsync.value ?? [];

  final results = <ProduceDemandInsight>[];
  final processedNames = <String>{};

  // 1. Calculate for all vegetables currently in inventory
  for (final veg in vegetables) {
    final lower = veg.name.toLowerCase().trim();
    processedNames.add(lower);
    final insight = DemandCalculationService.instance.calculateDemand(
      productName: veg.name,
      productId: veg.id,
      availableQuantity: veg.availableQuantityKg,
      allPreBookings: preBookings,
    );
    results.add(insight);
  }

  // 2. Also ensure standard demo items (Tomato, Onion, Banana) appear if pre-bookings exist
  const demoItems = ['Tomato', 'Onion', 'Banana', 'Carrot'];
  for (final item in demoItems) {
    final lower = item.toLowerCase().trim();
    if (!processedNames.contains(lower)) {
      final defaultAvail = DemandCalculationService.defaultAvailableQuantities[lower] ?? 100.0;
      final insight = DemandCalculationService.instance.calculateDemand(
        productName: item,
        availableQuantity: defaultAvail,
        allPreBookings: preBookings,
      );
      if (insight.preBookingCount > 0) {
        results.add(insight);
      }
    }
  }

  // Sort: High demand first, then by demand score descending
  results.sort((a, b) => b.demandScore.compareTo(a.demandScore));
  return results;
});

/// Returns only items classified as HIGH demand.
final highDemandOnlyProvider = Provider<List<ProduceDemandInsight>>((ref) {
  final all = ref.watch(allProduceDemandListProvider);
  return all.where((i) => i.demandLevel == ProduceDemandLevel.high).toList();
});

/// Family provider to watch real-time demand for a specific produce name or ID.
final singleProduceDemandProvider =
    Provider.family<ProduceDemandInsight, String>((ref, produceNameOrId) {
  final allDemand = ref.watch(allProduceDemandListProvider);
  final clean = produceNameOrId.toLowerCase().trim();

  for (final item in allDemand) {
    if ((item.productId != null && item.productId == produceNameOrId) ||
        item.productName.toLowerCase().trim() == clean ||
        item.productName.toLowerCase().contains(clean) ||
        clean.contains(item.productName.toLowerCase())) {
      return item;
    }
  }

  final preBookings = ref.watch(allPreBookingsStreamProvider).value ?? [];
  return DemandCalculationService.instance.calculateDemand(
    productName: produceNameOrId,
    availableQuantity: 100.0,
    allPreBookings: preBookings,
  );
});
