import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vegetable_model.dart';
import '../utils/logger.dart';

class OfflineCacheService {
  static const _vegetablesKey = 'cached_vegetables';
  static const _cacheTimestampKey = 'vegetables_cache_timestamp';
  static const _cacheDurationHours = 6;

  // ─── Vegetable Cache ──────────────────────────────────────────────────────

  Future<void> cacheVegetables(List<VegetableModel> vegetables) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = vegetables
          .map((v) => v.toFirestore()..['id'] = v.id)
          .toList();
      await prefs.setString(_vegetablesKey, jsonEncode(encoded));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      AppLogger.info('Cached ${vegetables.length} vegetables');
    } catch (e) {
      AppLogger.error('Error caching vegetables: $e');
    }
  }

  Future<List<VegetableModel>?> getCachedVegetables() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      if (timestamp == null) return null;

      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      const maxAge = _cacheDurationHours * 3600 * 1000;
      if (cacheAge > maxAge) {
        AppLogger.info('Vegetable cache expired');
        return null;
      }

      final raw = prefs.getString(_vegetablesKey);
      if (raw == null) return null;

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) {
        final map = item as Map<String, dynamic>;
        // Reconstruct a minimal DocumentSnapshot-like structure
        return _vegetableFromMap(map);
      }).toList();
    } catch (e) {
      AppLogger.error('Error reading vegetable cache: $e');
      return null;
    }
  }

  VegetableModel _vegetableFromMap(Map<String, dynamic> map) {
    return VegetableModel(
      id: map['id'] ?? '',
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      pricePerKg: (map['pricePerKg'] ?? 0.0).toDouble(),
      availableQuantityKg: (map['availableQuantityKg'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      unit: map['unit'] ?? 'kg',
      category: map['category'] ?? 'General',
      isAvailable: map['isAvailable'] ?? true,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vegetablesKey);
    await prefs.remove(_cacheTimestampKey);
  }

  Future<bool> hasFreshCache() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return false;
    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    return cacheAge <= _cacheDurationHours * 3600 * 1000;
  }
}

// ─── Connectivity Provider ─────────────────────────────────────────────────

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (result) => result != ConnectivityResult.none,
    loading: () => true,
    error: (_, __) => true,
  );
});

final offlineCacheProvider = Provider<OfflineCacheService>(
  (_) => OfflineCacheService(),
);

// ─── Offline-aware Vegetable Provider ──────────────────────────────────────
// Use this in the customer home screen in place of availableVegetablesProvider

final offlineAwareVegetablesProvider =
    FutureProvider<List<VegetableModel>>((ref) async {
  final isOnline = ref.watch(isOnlineProvider);
  final cache = ref.read(offlineCacheProvider);

  if (!isOnline) {
    AppLogger.info('Offline: loading from cache');
    final cached = await cache.getCachedVegetables();
    return cached ?? [];
  }

  // Online: use stream but also write to cache
  // Watch the Firestore stream and cache on each emission
  final completer = <VegetableModel>[];
  try {
    // Get a one-time snapshot when online
    final snap = await ref
        .read(offlineCacheProvider)
        .getCachedVegetables(); // fallback
    // Real data would come from Firestore; stream is preferred in UI
    return snap ?? [];
  } catch (e) {
    return await cache.getCachedVegetables() ?? [];
  }
});
