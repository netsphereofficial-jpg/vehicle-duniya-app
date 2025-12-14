import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/domain/entities/property_auction.dart';

part 'property_auction_event.dart';
part 'property_auction_state.dart';

class PropertyAuctionBloc extends Bloc<PropertyAuctionEvent, PropertyAuctionState> {
  final FirebaseService _firebaseService;

  PropertyAuctionBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(const PropertyAuctionState()) {
    on<PropertyAuctionLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    PropertyAuctionLoadRequested event,
    Emitter<PropertyAuctionState> emit,
  ) async {
    AppLogger.blocEvent('PropertyAuctionBloc', 'LoadRequested');
    emit(state.copyWith(status: PropertyAuctionStatus.loading));

    try {
      // TODO: Implement actual data fetching
      emit(state.copyWith(
        status: PropertyAuctionStatus.loaded,
        properties: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertyAuctionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
