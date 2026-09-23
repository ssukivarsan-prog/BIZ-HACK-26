import 'package:flutter_test/flutter_test.dart';
import 'package:veggie_vendor_app/services/smart_market_insights_service.dart';

void main() {
  group('SmartMarketInsightsService Tests', () {
    final svc = SmartMarketInsightsService.instance;

    test('Tomato has HIGH demand and correct demo metrics', () {
      final tomato = svc.getInsightForCrop('Tomato');
      expect(tomato, isNotNull);
      expect(tomato!.cropName, 'Tomato');
      expect(tomato.location, 'Erode');
      expect(tomato.buyerSearches, 185);
      expect(tomato.listingViews, 320);
      expect(tomato.purchaseRequests, 42);
      expect(tomato.acceptedOrders, 31);
      expect(tomato.quantityRequested, 1240.0);
      expect(tomato.quantitySold, 890.0);
      expect(tomato.availableQuantity, 350.0);
      expect(tomato.averagePrice, 30.0);
      expect(tomato.minPrice, 28.0);
      expect(tomato.maxPrice, 32.0);
      expect(tomato.demandLevel, DemandLevel.high);
      expect(tomato.demandLabel, 'HIGH DEMAND');
    });

    test('Onion has MODERATE demand and correct demo metrics', () {
      final onion = svc.getInsightForCrop('Onion');
      expect(onion, isNotNull);
      expect(onion!.cropName, 'Onion');
      expect(onion.location, 'Erode');
      expect(onion.buyerSearches, 92);
      expect(onion.listingViews, 170);
      expect(onion.purchaseRequests, 18);
      expect(onion.acceptedOrders, 12);
      expect(onion.quantityRequested, 520.0);
      expect(onion.quantitySold, 420.0);
      expect(onion.availableQuantity, 380.0);
      expect(onion.averagePrice, 27.0);
      expect(onion.minPrice, 25.0);
      expect(onion.maxPrice, 29.0);
      expect(onion.demandLevel, DemandLevel.moderate);
      expect(onion.demandLabel, 'MODERATE DEMAND');
    });

    test('Banana has LOW demand and correct demo metrics', () {
      final banana = svc.getInsightForCrop('Banana');
      expect(banana, isNotNull);
      expect(banana!.cropName, 'Banana');
      expect(banana.location, 'Coimbatore');
      expect(banana.buyerSearches, 35);
      expect(banana.listingViews, 61);
      expect(banana.purchaseRequests, 4);
      expect(banana.acceptedOrders, 3);
      expect(banana.quantityRequested, 100.0);
      expect(banana.quantitySold, 80.0);
      expect(banana.availableQuantity, 500.0);
      expect(banana.averagePrice, 35.0);
      expect(banana.minPrice, 32.0);
      expect(banana.maxPrice, 38.0);
      expect(banana.demandLevel, DemandLevel.low);
      expect(banana.demandLabel, 'LOW DEMAND');
    });

    test('Unsupported crop returns null for fallback handling', () {
      final unsupported = svc.getInsightForCrop('Dragonfruit');
      expect(unsupported, isNull);
    });

    test('Smart Buyer Matching finds and ranks potential buyers for Tomato', () {
      final matches = svc.findMatches(
        cropName: 'Tomato',
        availableQuantity: 350.0,
        farmerLocation: 'Erode',
      );
      expect(matches, isNotEmpty);
      expect(matches.length, 4); // Buyer A, Buyer B, Buyer C, Buyer E

      // Strong matches
      final topMatch = matches.first;
      expect(topMatch.totalScore, greaterThanOrEqualTo(80));
      expect(topMatch.strength, MatchStrength.strong);
      expect(topMatch.cropScore, 40);
      expect(topMatch.locationScore, 30);
      expect(topMatch.quantityScore, 20);
      expect(topMatch.activeScore, 10);
    });

    test('Smart Buyer Matching finds Onion buyers', () {
      final matches = svc.findMatches(
        cropName: 'Onion',
        availableQuantity: 380.0,
        farmerLocation: 'Erode',
      );
      expect(matches, isNotEmpty);
      final buyerD = matches.firstWhere((m) => m.buyer.crop == 'Onion');
      expect(buyerD.buyer.name, contains('Buyer D'));
    });
  });
}
