import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/data/models/auction_model.dart';
import '../../../../shared/data/models/vehicle_item_model.dart';
import '../../../../shared/domain/entities/auction.dart';
import '../../../../shared/domain/entities/vehicle_item.dart';

part 'vehicle_auction_event.dart';
part 'vehicle_auction_state.dart';

class VehicleAuctionBloc extends Bloc<VehicleAuctionEvent, VehicleAuctionState> {
  final FirebaseService _firebaseService;

  VehicleAuctionBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(const VehicleAuctionState()) {
    on<VehicleAuctionLoadRequested>(_onLoadRequested);
    on<VehicleAuctionDetailRequested>(_onDetailRequested);
    on<VehicleItemsLoadRequested>(_onVehicleItemsRequested);
  }

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

  Future<void> _onDetailRequested(
    VehicleAuctionDetailRequested event,
    Emitter<VehicleAuctionState> emit,
  ) async {
    AppLogger.blocEvent('VehicleAuctionBloc', 'DetailRequested');
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
      ));

      // Load vehicles for this auction
      add(VehicleItemsLoadRequested(event.auctionId));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleAuctionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onVehicleItemsRequested(
    VehicleItemsLoadRequested event,
    Emitter<VehicleAuctionState> emit,
  ) async {
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
}
