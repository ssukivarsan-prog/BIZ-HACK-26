import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vegetable_model.dart';
import '../utils/logger.dart';
import 'auth_service.dart';

class VegetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _collection = 'vegetables';

  Stream<List<VegetableModel>> getVegetables({bool availableOnly = false, String? vendorId}) {
    Query query = _firestore.collection(_collection);
    
    if (availableOnly) {
      query = query.where('isAvailable', isEqualTo: true);
    }
    
    if (vendorId != null) {
      query = query.where('vendorId', isEqualTo: vendorId);
    }
    
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => VegetableModel.fromFirestore(doc))
          .toList();
      // Sort locally to avoid requiring Firestore composite indexes
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<VegetableModel?> getVegetableById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return VegetableModel.fromFirestore(doc);
  }

  Future<String> addVegetable(VegetableModel vegetable, {File? imageFile}) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, null);
      }
      final docRef = await _firestore.collection(_collection).add(
            vegetable
                .copyWith(imageUrl: imageUrl ?? vegetable.imageUrl)
                .toFirestore(),
          );
      AppLogger.info('Vegetable added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error adding vegetable: $e');
      rethrow;
    }
  }

  Future<void> updateVegetable(VegetableModel vegetable, {File? imageFile}) async {
    try {
      String? imageUrl = vegetable.imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, vegetable.id);
      }
      await _firestore.collection(_collection).doc(vegetable.id).update(
            vegetable.copyWith(imageUrl: imageUrl).toFirestore(),
          );
      AppLogger.info('Vegetable updated: ${vegetable.id}');
    } catch (e) {
      AppLogger.error('Error updating vegetable: $e');
      rethrow;
    }
  }

  Future<void> deleteVegetable(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      // Try to delete image from storage
      try {
        await _storage.ref('vegetables/$id').delete();
      } catch (_) {}
      AppLogger.info('Vegetable deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting vegetable: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String id, double newQuantity) async {
    await _firestore.collection(_collection).doc(id).update({
      'availableQuantityKg': newQuantity,
      'isAvailable': newQuantity > 0,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> resetDailyInventory(String vendorId) async {
    final batch = _firestore.batch();
    final docs = await _firestore
        .collection(_collection)
        .where('vendorId', isEqualTo: vendorId)
        .get();
    for (final doc in docs.docs) {
      batch.update(doc.reference, {
        'isAvailable': true,
        'updatedAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  Future<String?> _uploadImage(File imageFile, String? existingId) async {
    final path = 'vegetables/${existingId ?? DateTime.now().millisecondsSinceEpoch}';
    final ref = _storage.ref(path);
    
    try {
      AppLogger.info('Uploading image to $path');
      final uploadTask = ref.putData(
        await imageFile.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final snapshot = await uploadTask;
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed: ${snapshot.state}');
      }
      
      AppLogger.info('Upload complete, getting download URL for $path');
      
      String? url;
      int retries = 3;
      while (retries > 0) {
        try {
          url = await ref.getDownloadURL();
          break;
        } catch (e) {
          if (e.toString().contains('object-not-found') && retries > 1) {
            AppLogger.info('Object not found, retrying... ($retries left)');
            await Future.delayed(const Duration(milliseconds: 1000));
            retries--;
          } else {
            rethrow;
          }
        }
      }
      
      AppLogger.info('Download URL obtained: $url');
      return url;
    } catch (e) {
      AppLogger.error('Storage error in _uploadImage: $e');
      // If Firebase Storage is not initialized or fails, fallback to null
      // so the vegetable can still be added to the database without breaking.
      return null;
    }
  }
}

final vegetableServiceProvider = Provider<VegetableService>(
  (_) => VegetableService(),
);

final vegetablesStreamProvider = StreamProvider<List<VegetableModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return ref.watch(vegetableServiceProvider).getVegetables(vendorId: user?.uid);
});

final availableVegetablesProvider = StreamProvider<List<VegetableModel>>((ref) {
  return ref.watch(vegetableServiceProvider).getVegetables(availableOnly: true);
});
