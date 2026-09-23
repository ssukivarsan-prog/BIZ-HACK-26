// lib/services/smart_market_insights_service.dart
// Demonstration service for Smart Market Insight and Smart Buyer Matching.
// Uses local/static simulated data for showcase purposes.
// Strictly READ-ONLY: Never alters database, orders, or pricing.

enum DemandLevel {
  high,
  moderate,
  low,
  insufficientData,
}

enum MatchStrength {
  strong,
  good,
  possible,
  low,
}

class MarketInsightData {
  final String cropName;
  final String location;
  final int buyerSearches;
  final int listingViews;
  final int purchaseRequests;
  final int acceptedOrders;
  final double quantityRequested; // in kg
  final double quantitySold; // in kg
  final double availableQuantity; // in kg
  final double averagePrice; // in ₹/kg
  final double minPrice;
  final double maxPrice;
  final String period;

  const MarketInsightData({
    required this.cropName,
    required this.location,
    required this.buyerSearches,
    required this.listingViews,
    required this.purchaseRequests,
    required this.acceptedOrders,
    required this.quantityRequested,
    required this.quantitySold,
    required this.availableQuantity,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    this.period = 'Last 7 Days',
  });

  /// Transparent demand calculation:
  /// Evaluates demand pressure (ratio of requested to available quantity),
  /// search & view activity, and purchase request conversion.
  double get demandScore {
    // 1. Demand pressure (weight 40%)
    final double ratio = availableQuantity > 0 ? (quantityRequested / availableQuantity) : 0.0;
    final double supplyPressureScore = (ratio >= 3.0)
        ? 40.0
        : (ratio >= 1.0)
            ? 25.0 + ((ratio - 1.0) / 2.0 * 15.0)
            : (ratio * 25.0);

    // 2. Buyer interest & search activity (weight 30%)
    final double activityScore =
        ((buyerSearches + listingViews) / 500.0 * 30.0).clamp(0.0, 30.0);

    // 3. Purchase requests & conversion (weight 30%)
    final double requestScore =
        (purchaseRequests / 40.0 * 20.0).clamp(0.0, 20.0);
    final double conversionRate =
        purchaseRequests > 0 ? (acceptedOrders / purchaseRequests) : 0.0;
    final double conversionScore = (conversionRate * 10.0).clamp(0.0, 10.0);

    return (supplyPressureScore + activityScore + requestScore + conversionScore)
        .clamp(0.0, 100.0);
  }

  DemandLevel get demandLevel {
    final score = demandScore;
    if (score >= 70.0) return DemandLevel.high;
    if (score >= 40.0) return DemandLevel.moderate;
    return DemandLevel.low;
  }

  String get demandLabel {
    switch (demandLevel) {
      case DemandLevel.high:
        return 'HIGH DEMAND';
      case DemandLevel.moderate:
        return 'MODERATE DEMAND';
      case DemandLevel.low:
        return 'LOW DEMAND';
      case DemandLevel.insufficientData:
        return 'INSUFFICIENT DATA';
    }
  }

  String get demandBadgeEmoji {
    switch (demandLevel) {
      case DemandLevel.high:
        return '🔥';
      case DemandLevel.moderate:
        return '⚡';
      case DemandLevel.low:
        return '❄️';
      case DemandLevel.insufficientData:
        return '📊';
    }
  }

  String get demandExplanation {
    switch (demandLevel) {
      case DemandLevel.high:
        return 'Buyer activity and purchase requests are high relative to the currently available quantity.';
      case DemandLevel.moderate:
        return 'Market demand is steady and balanced with the current supply and order requests.';
      case DemandLevel.low:
        return 'Current available quantity exceeds incoming purchase requests and search activity.';
      case DemandLevel.insufficientData:
        return 'Insufficient marketplace activity to compute a reliable demand score.';
    }
  }

  String get supplyStatusSummary {
    switch (demandLevel) {
      case DemandLevel.high:
        return 'Demand exceeds available supply';
      case DemandLevel.moderate:
        return 'Demand and supply are well balanced';
      case DemandLevel.low:
        return 'Supply exceeds current market demand';
      case DemandLevel.insufficientData:
        return 'Standard market activity';
    }
  }
}

class DemoBuyer {
  final String id;
  final String name;
  final String crop;
  final double requiredQuantity;
  final String location;
  final bool isActive;
  final String category;

  const DemoBuyer({
    required this.id,
    required this.name,
    required this.crop,
    required this.requiredQuantity,
    required this.location,
    required this.isActive,
    this.category = 'Wholesale / Retailer',
  });
}

class BuyerMatchResult {
  final DemoBuyer buyer;
  final int totalScore;
  final MatchStrength strength;
  final int cropScore;
  final int locationScore;
  final int quantityScore;
  final int activeScore;

  const BuyerMatchResult({
    required this.buyer,
    required this.totalScore,
    required this.strength,
    required this.cropScore,
    required this.locationScore,
    required this.quantityScore,
    required this.activeScore,
  });

  String get strengthLabel {
    switch (strength) {
      case MatchStrength.strong:
        return 'Strong Match';
      case MatchStrength.good:
        return 'Good Match';
      case MatchStrength.possible:
        return 'Possible Match';
      case MatchStrength.low:
        return 'Low Match';
    }
  }
}

class SmartMarketInsightsService {
  SmartMarketInsightsService._();
  static final SmartMarketInsightsService instance = SmartMarketInsightsService._();

  // ─── Static Demo Dataset for Market Insights ─────────────────────────────
  static final Map<String, MarketInsightData> demoMarketData = {
    'tomato': const MarketInsightData(
      cropName: 'Tomato',
      location: 'Erode',
      buyerSearches: 185,
      listingViews: 320,
      purchaseRequests: 42,
      acceptedOrders: 31,
      quantityRequested: 1240.0,
      quantitySold: 890.0,
      availableQuantity: 350.0,
      averagePrice: 30.0,
      minPrice: 28.0,
      maxPrice: 32.0,
      period: 'Last 7 Days',
    ),
    'onion': const MarketInsightData(
      cropName: 'Onion',
      location: 'Erode',
      buyerSearches: 92,
      listingViews: 170,
      purchaseRequests: 18,
      acceptedOrders: 12,
      quantityRequested: 520.0,
      quantitySold: 420.0,
      availableQuantity: 380.0,
      averagePrice: 27.0,
      minPrice: 25.0,
      maxPrice: 29.0,
      period: 'Last 7 Days',
    ),
    'banana': const MarketInsightData(
      cropName: 'Banana',
      location: 'Coimbatore',
      buyerSearches: 35,
      listingViews: 61,
      purchaseRequests: 4,
      acceptedOrders: 3,
      quantityRequested: 100.0,
      quantitySold: 80.0,
      availableQuantity: 500.0,
      averagePrice: 35.0,
      minPrice: 32.0,
      maxPrice: 38.0,
      period: 'Last 7 Days',
    ),
  };

  // ─── Static Demo Dataset for Potential Buyers ─────────────────────────────
  static const List<DemoBuyer> demoBuyers = [
    DemoBuyer(
      id: 'buyer_a',
      name: 'Buyer A (FreshMart Erode)',
      crop: 'Tomato',
      requiredQuantity: 150.0,
      location: 'Erode',
      isActive: true,
      category: 'Wholesale Supermarket',
    ),
    DemoBuyer(
      id: 'buyer_b',
      name: 'Buyer B (Kongu Veg Store)',
      crop: 'Tomato',
      requiredQuantity: 80.0,
      location: 'Erode',
      isActive: true,
      category: 'Retail Outlet',
    ),
    DemoBuyer(
      id: 'buyer_c',
      name: 'Buyer C (GreenValley Mart)',
      crop: 'Tomato',
      requiredQuantity: 200.0,
      location: 'Nearby',
      isActive: true,
      category: 'Bulk Catering',
    ),
    DemoBuyer(
      id: 'buyer_d',
      name: 'Buyer D (Tiruppur Organics)',
      crop: 'Onion',
      requiredQuantity: 200.0,
      location: 'Tiruppur',
      isActive: true,
      category: 'Produce Distributor',
    ),
    DemoBuyer(
      id: 'buyer_e',
      name: 'Buyer E (Kaveri Kitchens)',
      crop: 'Tomato',
      requiredQuantity: 50.0,
      location: 'Erode',
      isActive: true,
      category: 'Restaurant Chain',
    ),
    DemoBuyer(
      id: 'buyer_f',
      name: 'Buyer F (Coimbatore Fruit Hub)',
      crop: 'Banana',
      requiredQuantity: 60.0,
      location: 'Coimbatore',
      isActive: true,
      category: 'Fruit Merchant',
    ),
  ];

  /// Look up simulated market data for a given crop name.
  /// Matches case-insensitively against supported demo crops.
  MarketInsightData? getInsightForCrop(String cropName) {
    final lower = cropName.toLowerCase().trim();
    for (final entry in demoMarketData.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Calculates potential buyer matches for the farmer's produce.
  /// Scoring formula:
  /// - Crop Match: +40
  /// - Location Match: +30 (or +15 for "Nearby")
  /// - Quantity Match: +20 (satisfies required)
  /// - Active Buyer: +10
  /// Total max: 100
  List<BuyerMatchResult> findMatches({
    required String cropName,
    required double availableQuantity,
    String farmerLocation = 'Erode',
  }) {
    final lowerCrop = cropName.toLowerCase().trim();
    final results = <BuyerMatchResult>[];

    for (final buyer in demoBuyers) {
      final buyerCrop = buyer.crop.toLowerCase().trim();
      final isCropMatch = lowerCrop.contains(buyerCrop) || buyerCrop.contains(lowerCrop);

      // Only evaluate buyers looking for this crop (or if partial match)
      if (!isCropMatch) continue;

      const int cropScore = 40;

      // Location match
      int locationScore = 0;
      if (buyer.location.toLowerCase() == farmerLocation.toLowerCase()) {
        locationScore = 30;
      } else if (buyer.location.toLowerCase() == 'nearby') {
        locationScore = 15;
      } else {
        locationScore = 5;
      }

      // Quantity match: does available satisfy buyer requirement?
      int quantityScore = 0;
      if (availableQuantity >= buyer.requiredQuantity) {
        quantityScore = 20;
      } else if (availableQuantity > 0) {
        quantityScore = ((availableQuantity / buyer.requiredQuantity) * 20.0).round().clamp(0, 20);
      }

      // Active score
      final int activeScore = buyer.isActive ? 10 : 0;

      final totalScore = (cropScore + locationScore + quantityScore + activeScore).clamp(0, 100);

      MatchStrength strength;
      if (totalScore >= 80) {
        strength = MatchStrength.strong;
      } else if (totalScore >= 60) {
        strength = MatchStrength.good;
      } else if (totalScore >= 40) {
        strength = MatchStrength.possible;
      } else {
        strength = MatchStrength.low;
      }

      results.add(
        BuyerMatchResult(
          buyer: buyer,
          totalScore: totalScore,
          strength: strength,
          cropScore: cropScore,
          locationScore: locationScore,
          quantityScore: quantityScore,
          activeScore: activeScore,
        ),
      );
    }

    // Sort by highest score first
    results.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return results;
  }
}
