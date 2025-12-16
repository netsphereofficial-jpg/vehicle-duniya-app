import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/realtime_firebase_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/data/models/auction_model.dart';
import '../../../../shared/data/models/bid_model.dart';
import '../../../../shared/data/models/vehicle_item_model.dart';
import '../../../../shared/domain/entities/auction.dart';
import '../../../../shared/domain/entities/bid.dart';
import '../../../../shared/domain/entities/vehicle_item.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

part 'vehicle_auction_event.dart';
part 'vehicle_auction_state.dart';

class VehicleAuctionBloc extends Bloc<VehicleAuctionEvent, VehicleAuctionState> {
  final FirebaseService _firebaseService;
  final RealtimeFirebaseService _realtimeService;

  // Stream subscriptions for real-time updates
  StreamSubscription<List<VehicleItem>>? _vehiclesSubscription;
  StreamSubscription<List<Bid>>? _bidsSubscription;

  VehicleAuctionBloc({
    required FirebaseService firebaseService,
    required RealtimeFirebaseService realtimeService,
  })  : _firebaseService = firebaseService,
        _realtimeService = realtimeService,
        super(const VehicleAuctionState()) {
    // Existing handlers
    on<VehicleAuctionLoadRequested>(_onLoadRequested);
    on<VehicleAuctionDetailRequested>(_onDetailRequested);
    on<VehicleItemsLoadRequested>(_onVehicleItemsRequested);

    // New handlers
    on<VehicleAuctionStartRealtime>(_onStartRealtime);
    on<VehicleAuctionStopRealtime>(_onStopRealtime);
    on<VehicleSearchRequested>(_onSearchRequested);
    on<VehicleFilterRequested>(_onFilterRequested);
    on<VehicleBidRequested>(_onBidRequested);
    on<VehicleWatchlistToggled>(_onWatchlistToggled);
    on<VehicleBidsHistoryRequested>(_onBidsHistoryRequested);
    on<VehiclesRealtimeUpdated>(_onVehiclesRealtimeUpdated);
    on<BidsRealtimeUpdated>(_onBidsRealtimeUpdated);
    on<VehicleSelectionCleared>(_onSelectionCleared);
    on<BidStatusReset>(_onBidStatusReset);
  }

  /// Load all auctions
  Future<void> _onLoadRequested(
    VehicleAuctionLoadRequested event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'LoadRequested');
    emit(state.copyWith(status: VehicleAuctionStatus.loading));

    try {
      final snapshot = await _firebaseService.getCollection(
        FirebaseConstants.auctionsCollection,
        queryBuilder: (ref) => ref.orderBy('startDate', descending: true),
      );

      final auctions = snapshot.docs
          .map((doc) => AuctionModel.fromFirestore(doc))
          .toList();

      emit(state.copyWith(
        status: VehicleAuctionStatus.loaded,
        auctions: auctions,
      ));
    } catch (e) {
      AppLogger.error('VehicleAuctionBloc', 'Load error', error: e);
      emit(state.copyWith(
        status: VehicleAuctionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Load single auction detail
  Future<void> _onDetailRequested(
    VehicleAuctionDetailRequested event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'DetailRequested: ${event.auctionId}');
    emit(state.copyWith(status: VehicleAuctionStatus.loading));

    try {
      final doc = await _firebaseService.getDocument(
        FirebaseConstants.auctionsCollection,
        event.auctionId,
      );

      if (!doc.exists) {
        emit(state.copyWith(
          status: VehicleAuctionStatus.error,
          errorMessage: 'Auction not found',
        ));
        return;
      }

      final auction = AuctionModel.fromFirestore(doc);
      emit(state.copyWith(
        status: VehicleAuctionStatus.loaded,
        selectedAuction: auction,
        // Reset search and filter when loading new auction
        searchQuery: '',
        filter: const VehicleFilter(),
      ));

      // Load vehicles for this auction
      add(VehicleItemsLoadRequested(event.auctionId));
    } catch (e) {
      AppLogger.error('VehicleAuctionBloc', 'Detail error', error: e);
      emit(state.copyWith(
        status: VehicleAuctionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Load vehicles for an auction
  Future<void> _onVehicleItemsRequested(
    VehicleItemsLoadRequested event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'VehicleItemsRequested: ${event.auctionId}');

    try {
      final snapshot = await _firebaseService.getCollection(
        FirebaseConstants.vehiclesCollection,
        queryBuilder: (ref) => ref.where('auctionId', isEqualTo: event.auctionId),
      );

      final vehicles = snapshot.docs
          .map((doc) => VehicleItemModel.fromFirestore(doc))
          .toList();

      emit(state.copyWith(vehicles: vehicles));
    } catch (e) {
      AppLogger.error('VehicleAuctionBloc', 'Load vehicles error', error: e);
    }
  }

  /// Start real-time stream for live auction updates
  Future<void> _onStartRealtime(
    VehicleAuctionStartRealtime event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'StartRealtime: ${event.auctionId}');

    // Cancel existing subscriptions
    await _vehiclesSubscription?.cancel();
    await _bidsSubscription?.cancel();

    // Subscribe to vehicle updates
    _vehiclesSubscription = _realtimeService
        .getAuctionVehiclesStream<VehicleItem>(
          auctionId: event.auctionId,
          fromFirestore: VehicleItemModel.fromFirestore,
        )
        .listen(
          (vehicles) => add(VehiclesRealtimeUpdated(vehicles)),
          onError: (error) {
            AppLogger.error('VehicleAuctionBloc', 'Vehicle stream error', error: error);
          },
        );

    emit(state.copyWith(isRealtimeActive: true));
  }

  /// Stop real-time stream
  Future<void> _onStopRealtime(
    VehicleAuctionStopRealtime event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'StopRealtime');

    await _vehiclesSubscription?.cancel();
    await _bidsSubscription?.cancel();
    _vehiclesSubscription = null;
    _bidsSubscription = null;

    emit(state.copyWith(isRealtimeActive: false));
  }

  /// Handle vehicle search
  void _onSearchRequested(
    VehicleSearchRequested event,
    Emitter<VehicleAuctionState> emit,
  ) {
    AppLogger.blocEvent('VehicleAuctionBloc', 'SearchRequested: ${event.query}');
    emit(state.copyWith(searchQuery: event.query));
  }

  /// Handle filter changes
  void _onFilterRequested(
    VehicleFilterRequested event,
    Emitter<VehicleAuctionState> emit,
  ) {
    AppLogger.blocEvent('VehicleAuctionBloc', 'FilterRequested');
    emit(state.copyWith(filter: event.filter));
  }

  /// Place a bid on a vehicle
  Future<void> _onBidRequested(
    VehicleBidRequested event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'BidRequested: ${event.vehicleId} - ${event.amount}');
    emit(state.copyWith(status: VehicleAuctionStatus.bidding));

    try {
      // Find the vehicle
      final vehicle = state.vehicles.firstWhere(
        (v) => v.id == event.vehicleId,
        orElse: () => throw Exception('Vehicle not found'),
      );

      // Validate bid amount
      if (event.amount < vehicle.minimumBid) {
        throw Exception('Bid must be at least ₹${vehicle.minimumBid.toStringAsFixed(0)}');
      }

      // Get current user
      final authBloc = getIt<AuthBloc>();
      final user = authBloc.state.user;
      if (user == null) {
        throw Exception('Please login to place a bid');
      }

      // Place the bid
      await _realtimeService.placeBid(
        auctionId: state.selectedAuction?.id ?? vehicle.auctionId,
        vehicleId: event.vehicleId,
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        amount: event.amount,
      );

      emit(state.copyWith(
        status: VehicleAuctionStatus.bidSuccess,
        bidSuccessMessage: 'Bid placed successfully! ₹${event.amount.toStringAsFixed(0)}',
      ));

      AppLogger.info('VehicleAuctionBloc', 'Bid placed successfully');
    } catch (e) {
      AppLogger.error('VehicleAuctionBloc', 'Bid error', error: e);
      emit(state.copyWith(
        status: VehicleAuctionStatus.bidError,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Toggle vehicle in watchlist
  void _onWatchlistToggled(
    VehicleWatchlistToggled event,
    Emitter<VehicleAuctionState> emit,
  ) {
    AppLogger.blocEvent('VehicleAuctionBloc', 'WatchlistToggled: ${event.vehicleId}');

    final newWatchlist = Set<String>.from(state.watchlist);
    if (newWatchlist.contains(event.vehicleId)) {
      newWatchlist.remove(event.vehicleId);
    } else {
      newWatchlist.add(event.vehicleId);
    }

    emit(state.copyWith(watchlist: newWatchlist));
  }

  /// Load bid history for a vehicle
  Future<void> _onBidsHistoryRequested(
    VehicleBidsHistoryRequested event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'BidsHistoryRequested: ${event.vehicleId}');

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseConstants.bidsCollection)
          .where('vehicleId', isEqualTo: event.vehicleId)
          .orderBy('amount', descending: true)
          .limit(10)
          .get();

      final bids = snapshot.docs
          .map((doc) => BidModel.fromFirestore(doc))
          .toList();

      emit(state.copyWith(vehicleBids: bids));
    } catch (e) {
      AppLogger.error('VehicleAuctionBloc', 'Load bids error', error: e);
    }
  }

  /// Handle real-time vehicle updates
  void _onVehiclesRealtimeUpdated(
    VehiclesRealtimeUpdated event,
    Emitter<VehicleAuctionState> emit,
  ) {
    AppLogger.blocEvent('VehicleAuctionBloc', 'VehiclesRealtimeUpdated: ${event.vehicles.length} vehicles');
    emit(state.copyWith(vehicles: event.vehicles));
  }

  /// Handle real-time bid updates
  void _onBidsRealtimeUpdated(
    BidsRealtimeUpdated event,
    Emitter<VehicleAuctionState> emit,
  ) {
    AppLogger.blocEvent('VehicleAuctionBloc', 'BidsRealtimeUpdated: ${event.bids.length} bids');
    emit(state.copyWith(vehicleBids: event.bids));
  }

  /// Clear selected vehicle
  void _onSelectionCleared(
    VehicleSelectionCleared event,
    Emitter<VehicleAuctionState> emit,
  ) {
    emit(state.copyWith(clearSelectedVehicle: true, vehicleBids: []));
  }

  /// Reset bid status
  void _onBidStatusReset(
    BidStatusReset event,
    Emitter<VehicleAuctionState> emit,
  ) {
    emit(state.copyWith(
      status: VehicleAuctionStatus.loaded,
      clearBidMessage: true,
      clearError: true,
    ));
  }

  @override
  Future<void> close() {
    _vehiclesSubscription?.cancel();
    _bidsSubscription?.cancel();
    return super.close();
  }
}
