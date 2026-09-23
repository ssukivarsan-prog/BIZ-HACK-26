// test/pre_booking_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:veggie_vendor_app/models/pre_booking_model.dart';
import 'package:veggie_vendor_app/services/demand_calculation_service.dart';

void main() {
  group('DemandCalculationService Tests', () {
    final service = DemandCalculationService.instance;

    test('Zero pre-bookings returns INSUFFICIENT DATA level and 0 score', () {
      final insight = service.calculateDemand(
        productName: 'Tomato',
        productId: 'veg_tomato_1',
        availableQuantity: 100.0,
        allPreBookings: [],
      );

      expect(insight.demandLevel, ProduceDemandLevel.insufficientData);
      expect(insight.demandScore, 0.0);
      expect(insight.demandRatio, 0.0);
      expect(insight.preBookingCount, 0);
      expect(insight.totalPreBookedQuantity, 0.0);
      expect(insight.demandLabel, 'INSUFFICIENT DATA');
      expect(insight.availableQuantity, 100.0);
    });

    test('High pre-bookings ratio (>= 0.75) returns HIGH DEMAND', () {
      final now = DateTime.now();
      final preBookings = [
        PreBookingModel(
          id: 'pb_1',
          productId: 'veg_tomato_1',
          productName: 'Tomato',
          farmerId: 'farmer_1',
          farmerName: 'Ramasamy Natural Farm',
          farmerLocation: 'Erode - Bhavani Road (4.5 km away)',
          freshnessDescription: '🌱 Harvested at 5 AM on dispatch day • 100% natural',
          deliveryCapabilityNote: '🚚 Can deliver within 15 km radius',
          customerId: 'cust_1',
          customerName: 'Anand',
          customerLocation: 'Gandhi Nagar, Erode',
          quantityRequested: 50.0,
          preferredDate: now.add(const Duration(days: 3)),
          createdAt: now,
        ),
        PreBookingModel(
          id: 'pb_2',
          productId: 'veg_tomato_1',
          productName: 'Tomato',
          farmerId: 'farmer_1',
          farmerName: 'Ramasamy Natural Farm',
          farmerLocation: 'Erode - Bhavani Road (4.5 km away)',
          freshnessDescription: '🌱 Harvested at 5 AM on dispatch day',
          deliveryCapabilityNote: '🚚 Can deliver within 15 km radius',
          customerId: 'cust_2',
          customerName: 'Bala',
          customerLocation: 'Perundurai Road, Erode',
          quantityRequested: 35.0,
          preferredDate: now.add(const Duration(days: 4)),
          createdAt: now,
        ),
      ];

      // Available is 100 kg, total requested is 85 kg => demandRatio = 0.85
      final insight = service.calculateDemand(
        productName: 'Tomato',
        productId: 'veg_tomato_1',
        availableQuantity: 100.0,
        allPreBookings: preBookings,
      );

      expect(insight.demandLevel, ProduceDemandLevel.high);
      expect(insight.demandLabel, 'HIGH DEMAND');
      expect(insight.totalPreBookedQuantity, 85.0);
      expect(insight.preBookingCount, 2);
      expect(insight.demandRatio, closeTo(0.85, 0.001));
      // Verify availableQuantity remains untouched
      expect(insight.availableQuantity, 100.0);
    });

    test('Moderate pre-booking ratio (0.40 <= ratio < 0.75) returns MODERATE DEMAND', () {
      final now = DateTime.now();
      final preBookings = [
        PreBookingModel(
          id: 'pb_3',
          productId: 'veg_onion_1',
          productName: 'Onion',
          farmerId: 'farmer_1',
          farmerName: 'Murugan Agro',
          farmerLocation: 'Erode - Chennimalai',
          customerId: 'cust_3',
          customerName: 'Chitra',
          quantityRequested: 50.0,
          preferredDate: now.add(const Duration(days: 2)),
          createdAt: now,
        ),
      ];

      // Available is 100 kg, total requested is 50 kg => ratio = 0.50
      final insight = service.calculateDemand(
        productName: 'Onion',
        productId: 'veg_onion_1',
        availableQuantity: 100.0,
        allPreBookings: preBookings,
      );

      expect(insight.demandLevel, ProduceDemandLevel.moderate);
      expect(insight.demandLabel, 'MODERATE DEMAND');
      expect(insight.demandRatio, closeTo(0.50, 0.001));
    });

    test('Low pre-booking ratio (< 0.40) returns LOW DEMAND', () {
      final now = DateTime.now();
      final preBookings = [
        PreBookingModel(
          id: 'pb_4',
          productId: 'veg_banana_1',
          productName: 'Banana',
          farmerId: 'farmer_1',
          customerId: 'cust_4',
          customerName: 'Devi',
          quantityRequested: 15.0,
          preferredDate: now.add(const Duration(days: 5)),
          createdAt: now,
        ),
      ];

      // Available is 100 kg, requested is 15 kg => ratio = 0.15
      final insight = service.calculateDemand(
        productName: 'Banana',
        productId: 'veg_banana_1',
        availableQuantity: 100.0,
        allPreBookings: preBookings,
      );

      expect(insight.demandLevel, ProduceDemandLevel.low);
      expect(insight.demandLabel, 'LOW DEMAND');
      expect(insight.demandRatio, closeTo(0.15, 0.001));
    });

    test('Matching produce by name when productId is omitted or different', () {
      final now = DateTime.now();
      final preBookings = [
        PreBookingModel(
          id: 'pb_5',
          productId: '',
          productName: 'Country Tomato',
          farmerId: 'farmer_2',
          customerId: 'cust_5',
          customerName: 'Ezhil',
          quantityRequested: 80.0,
          preferredDate: now.add(const Duration(days: 2)),
          createdAt: now,
        ),
      ];

      final insight = service.calculateDemand(
        productName: 'Tomato',
        productId: 'prod_99',
        availableQuantity: 100.0,
        allPreBookings: preBookings,
      );

      expect(insight.preBookingCount, 1);
      expect(insight.totalPreBookedQuantity, 80.0);
      expect(insight.demandLevel, ProduceDemandLevel.high);
    });
  });

  group('PreBookingModel & FarmerProduceOption Tests', () {
    test('FarmerProduceOption returns options for crop with freshness and location', () {
      final options = FarmerProduceOption.getOptionsForProduce(produceName: 'Tomato');
      expect(options.isNotEmpty, true);
      final first = options.first;
      expect(first.farmerName.isNotEmpty, true);
      expect(first.farmLocation.contains('Erode') || first.farmLocation.contains('km'), true);
      expect(first.freshnessDescription.isNotEmpty, true);
      expect(first.deliveryCapability.contains('deliver') || first.deliveryCapability.contains('km'), true);
    });

    test('copyWith updates customer location, farmer name, and delivery status', () {
      final now = DateTime.now();
      final original = PreBookingModel(
        id: '1',
        productId: 'prod_1',
        productName: 'Tomato',
        farmerId: 'f_1',
        farmerName: 'Ramasamy Natural Farm',
        farmerLocation: 'Erode Bhavani',
        freshnessDescription: 'Harvested morning',
        deliveryCapabilityNote: '15 km reach',
        customerId: 'c_1',
        customerName: 'Alice',
        customerLocation: 'Gandhi Nagar',
        quantityRequested: 10.0,
        preferredDate: now,
        createdAt: now,
      );

      final updated = original.copyWith(
        status: 'can_deliver',
        farmerResponseNote: 'Confirmed: Delivery on 26th morning.',
        quantityRequested: 25.0,
      );

      expect(updated.id, '1');
      expect(updated.status, 'can_deliver');
      expect(updated.farmerResponseNote, 'Confirmed: Delivery on 26th morning.');
      expect(updated.quantityRequested, 25.0);
      expect(updated.farmerName, 'Ramasamy Natural Farm');
      expect(updated.customerLocation, 'Gandhi Nagar');
    });
  });
}
