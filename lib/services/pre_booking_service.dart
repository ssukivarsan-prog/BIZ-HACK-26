// lib/services/pre_booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pre_booking_model.dart';
import '../utils/logger.dart';

class PreBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'preBookings';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionName);

  /// Submits a new pre-booking.
  /// Strictly does NOT reduce vegetable inventory or create purchase orders.
  Future<String> createPreBooking(PreBookingModel preBooking) async {
    try {
      final docRef = await _collection.add(preBooking.toFirestore());
      AppLogger.info('Pre-booking submitted: ${docRef.id} for ${preBooking.productName}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error submitting pre-booking: $e');
      rethrow;
    }
  }

  /// Streams all pre-bookings in real-time.
  Stream<List<PreBookingModel>> streamAllPreBookings() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => PreBookingModel.fromFirestore(doc)).toList());
  }

  /// Streams active pre-bookings for a specific customer.
  Stream<List<PreBookingModel>> streamPreBookingsByCustomer(String customerId) {
    return _collection
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((doc) => PreBookingModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Streams active pre-bookings for a specific farmer.
  Stream<List<PreBookingModel>> streamPreBookingsByFarmer(String farmerId) {
    return _collection
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((doc) => PreBookingModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Updates status of a pre-booking (e.g. 'can_deliver', 'accepted', 'rejected')
  /// and attaches an optional farmer delivery response note.
  Future<void> updatePreBookingStatus(
    String bookingId,
    String newStatus, {
    String? farmerResponseNote,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      };
      if (farmerResponseNote != null && farmerResponseNote.trim().isNotEmpty) {
        updateData['farmerResponseNote'] = farmerResponseNote.trim();
      }
      await _collection.doc(bookingId).update(updateData);
      AppLogger.info('Pre-booking $bookingId status updated to $newStatus');
    } catch (e) {
      AppLogger.error('Error updating pre-booking status: $e');
      rethrow;
    }
  }

  /// Optional one-time demonstration seeder.
  /// Seeds initial demo pre-bookings if collection is empty, matching:
  /// - Tomato: ~80 kg pre-booked
  /// - Onion: ~60 kg pre-booked
  /// - Banana: ~20 kg pre-booked
  Future<void> seedInitialDemoPreBookingsIfNeeded() async {
    try {
      final existing = await _collection.limit(1).get();
      if (existing.docs.isNotEmpty) return; // Already has data

      final now = DateTime.now();
      final demoBookings = [
        PreBookingModel(
          id: '',
          productId: 'demo_tomato',
          productName: 'Tomato',
          farmerId: 'farmer_ramasamy',
          farmerName: 'Ramasamy Natural Farm',
          farmerLocation: 'Erode - Bhavani Road (4.5 km away)',
          freshnessDescription: '🌱 Harvested at 5 AM on dispatch day • 100% natural, crisp Grade-A',
          deliveryCapabilityNote: '🚚 Can deliver within 15 km radius • Direct farm-to-door',
          customerId: 'buyer_1',
          customerName: 'Kaveri Mart (Karthik)',
          customerLocation: 'Gandhi Nagar, Erode Central',
          quantityRequested: 35.0,
          preferredDate: now.add(const Duration(days: 3)),
          note: 'Need fresh red ripe harvest for wholesale',
          status: 'pending',
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
        PreBookingModel(
          id: '',
          productId: 'demo_tomato',
          productName: 'Tomato',
          farmerId: 'farmer_kavitha',
          farmerName: 'Kavitha Agro Farms',
          farmerLocation: 'Perundurai Agro Belt (11 km away)',
          freshnessDescription: '🌿 Naturally vine-ripened • Zero chemical sprays • Rich aroma',
          deliveryCapabilityNote: '🚚 Delivers across Erode & Perundurai • Within 20 km radius',
          customerId: 'buyer_2',
          customerName: 'FreshBasket Erode (Subha)',
          customerLocation: 'Brough Road, Erode',
          quantityRequested: 45.0,
          preferredDate: now.add(const Duration(days: 4)),
          note: 'Morning delivery required before 9 AM',
          status: 'can_deliver',
          farmerResponseNote: 'Confirmed: Morning harvest batch ready. Can deliver to Brough Road by 8:30 AM.',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        PreBookingModel(
          id: '',
          productId: 'demo_onion',
          productName: 'Onion',
          farmerId: 'farmer_murugan',
          farmerName: 'Murugan Agro Onion Belt',
          farmerLocation: 'Erode - Chennimalai (9 km away)',
          freshnessDescription: '🧅 Sun-cured dry harvest • High pungency • Zero moisture loss',
          deliveryCapabilityNote: '🚚 Bulk & retail delivery up to 25 km radius',
          customerId: 'buyer_3',
          customerName: 'Tiruppur Traders (Muthu)',
          customerLocation: 'Kangeyam Road, Tiruppur',
          quantityRequested: 60.0,
          preferredDate: now.add(const Duration(days: 5)),
          note: 'Medium grade dry onions for bulk retail',
          status: 'pending',
          createdAt: now.subtract(const Duration(hours: 4)),
        ),
        PreBookingModel(
          id: '',
          productId: 'demo_banana',
          productName: 'Banana',
          farmerId: 'farmer_sengottaiyan',
          farmerName: 'Sengottaiyan Banana Groves',
          farmerLocation: 'Coimbatore - Pollachi Foothills (28 km away)',
          freshnessDescription: '🍌 Tree-matured Robusta bunches • Naturally ripened without carbide',
          deliveryCapabilityNote: '🚚 Cold-van delivery to Erode/Coimbatore within 40 km',
          customerId: 'buyer_4',
          customerName: 'Salem Fruits Co. (Ramesh)',
          customerLocation: 'Suramangalam, Salem',
          quantityRequested: 20.0,
          preferredDate: now.add(const Duration(days: 2)),
          note: 'Green robust bunches for long shelf life',
          status: 'can_deliver',
          farmerResponseNote: 'Batch confirmed: Will deliver via morning route to central market.',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ];

      for (final booking in demoBookings) {
        await _collection.add(booking.toFirestore());
      }
      AppLogger.info('Seeded initial demo pre-bookings successfully.');
    } catch (e) {
      AppLogger.error('Demo seeder note: $e');
    }
  }
}

final preBookingServiceProvider = Provider<PreBookingService>((ref) {
  return PreBookingService();
});

final allPreBookingsStreamProvider = StreamProvider<List<PreBookingModel>>((ref) {
  return ref.watch(preBookingServiceProvider).streamAllPreBookings();
});

final customerPreBookingsStreamProvider =
    StreamProvider.family<List<PreBookingModel>, String>((ref, customerId) {
  return ref
      .watch(preBookingServiceProvider)
      .streamPreBookingsByCustomer(customerId);
});
