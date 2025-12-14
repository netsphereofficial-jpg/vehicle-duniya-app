import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';
import '../utils/app_logger.dart';

/// Optimized real-time Firebase service for blazing fast performance
/// Uses streams, caching, and efficient queries
class RealtimeFirebaseService {
  final FirebaseFirestore _firestore;

  // Stream controllers for real-time data
  final Map<String, StreamController> _streamControllers = {};
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Cache duration (5 minutes for frequently changing data)
  static const Duration _cacheDuration = Duration(minutes: 5);

  RealtimeFirebaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    // Enable offline persistence for faster loads
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Get live auctions as a real-time stream
  Stream<List<T>> getLiveAuctionsStream<T>({
    required T Function(DocumentSnapshot) fromFirestore,
    int limit = 20,
  }) {
    AppLogger.firebase('STREAM', FirebaseConstants.auctionsCollection);

    return _firestore
        .collection(FirebaseConstants.auctionsCollection)
        .where('status', isEqualTo: 'live')
        .where('isActive', isEqualTo: true)
        .orderBy('startDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        });
  }

  /// Get upcoming auctions as a real-time stream
  Stream<List<T>> getUpcomingAuctionsStream<T>({
    required T Function(DocumentSnapshot) fromFirestore,
    int limit = 20,
  }) {
    AppLogger.firebase('STREAM', FirebaseConstants.auctionsCollection);

    return _firestore
        .collection(FirebaseConstants.auctionsCollection)
        .where('status', isEqualTo: 'upcoming')
        .where('isActive', isEqualTo: true)
        .orderBy('startDate')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        });
  }

  /// Get auction detail with real-time updates
  Stream<T?> getAuctionDetailStream<T>({
    required String auctionId,
    required T Function(DocumentSnapshot) fromFirestore,
  }) {
    AppLogger.firebase('STREAM_DETAIL', FirebaseConstants.auctionsCollection, docId: auctionId);

    return _firestore
        .collection(FirebaseConstants.auctionsCollection)
        .doc(auctionId)
        .snapshots()
        .map((doc) => doc.exists ? fromFirestore(doc) : null);
  }

  /// Get vehicles for an auction with real-time bid updates
  Stream<List<T>> getAuctionVehiclesStream<T>({
    required String auctionId,
    required T Function(DocumentSnapshot) fromFirestore,
  }) {
    AppLogger.firebase('STREAM_VEHICLES', FirebaseConstants.vehiclesCollection);

    return _firestore
        .collection(FirebaseConstants.vehiclesCollection)
        .where('auctionId', isEqualTo: auctionId)
        .where('isActive', isEqualTo: true)
        .orderBy('currentBid', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        });
  }

  /// Get user's bids with real-time status updates
  Stream<List<T>> getUserBidsStream<T>({
    required String userId,
    required T Function(DocumentSnapshot) fromFirestore,
    int limit = 50,
  }) {
    AppLogger.firebase('STREAM_BIDS', FirebaseConstants.bidsCollection);

    return _firestore
        .collection(FirebaseConstants.bidsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        });
  }

  /// Place a bid with optimistic update
  Future<void> placeBid({
    required String auctionId,
    required String vehicleId,
    required String userId,
    required String userName,
    required String userPhone,
    required double amount,
  }) async {
    AppLogger.firebase('PLACE_BID', FirebaseConstants.bidsCollection);

    final batch = _firestore.batch();

    // Create bid document
    final bidRef = _firestore.collection(FirebaseConstants.bidsCollection).doc();
    batch.set(bidRef, {
      'auctionId': auctionId,
      'vehicleId': vehicleId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'amount': amount,
      'type': 'vehicle',
      'status': 'active',
      'isWinning': true,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update vehicle's current bid
    final vehicleRef = _firestore
        .collection(FirebaseConstants.vehiclesCollection)
        .doc(vehicleId);
    batch.update(vehicleRef, {
      'currentBid': amount,
      'winnerId': userId,
      'winningBid': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    AppLogger.info('RealtimeFirebaseService', 'Bid placed successfully');
  }

  /// Get cached data with fallback to fresh fetch
  Future<T?> getCachedOrFetch<T>({
    required String cacheKey,
    required Future<T> Function() fetchFunction,
  }) async {
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheDuration) {
        AppLogger.debug('RealtimeFirebaseService', 'Cache hit: $cacheKey');
        return _cache[cacheKey] as T;
      }
    }

    // Fetch fresh data
    final data = await fetchFunction();
    _cache[cacheKey] = data;
    _cacheTimestamps[cacheKey] = DateTime.now();
    return data;
  }

  /// Prefetch data for faster subsequent loads
  Future<void> prefetchHomeData<T>({
    required T Function(DocumentSnapshot) fromFirestore,
  }) async {
    AppLogger.info('RealtimeFirebaseService', 'Prefetching home data...');

    // Prefetch in parallel for speed
    await Future.wait([
      _firestore
          .collection(FirebaseConstants.auctionsCollection)
          .where('status', isEqualTo: 'live')
          .limit(10)
          .get(const GetOptions(source: Source.serverAndCache)),
      _firestore
          .collection(FirebaseConstants.auctionsCollection)
          .where('status', isEqualTo: 'upcoming')
          .limit(10)
          .get(const GetOptions(source: Source.serverAndCache)),
      _firestore
          .collection(FirebaseConstants.categoriesCollection)
          .get(const GetOptions(source: Source.serverAndCache)),
    ]);

    AppLogger.info('RealtimeFirebaseService', 'Prefetch complete');
  }

  /// Clear all caches
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    AppLogger.info('RealtimeFirebaseService', 'Cache cleared');
  }

  /// Dispose all stream controllers
  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}
