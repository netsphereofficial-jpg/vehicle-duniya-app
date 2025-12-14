import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/realtime_firebase_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/data/models/auction_model.dart';
import '../../../../shared/domain/entities/auction.dart';
import '../../../../shared/domain/entities/category.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Optimized HomeBloc with real-time streams for blazing fast updates
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RealtimeFirebaseService _realtimeService;

  // Stream subscriptions for real-time updates
  StreamSubscription? _liveAuctionsSubscription;
  StreamSubscription? _upcomingAuctionsSubscription;

  HomeBloc({required RealtimeFirebaseService realtimeService})
      : _realtimeService = realtimeService,
        super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeLiveAuctionsUpdated>(_onLiveAuctionsUpdated);
    on<HomeUpcomingAuctionsUpdated>(_onUpcomingAuctionsUpdated);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    AppLogger.blocEvent('HomeBloc', 'HomeLoadRequested');
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      // Subscribe to real-time live auctions stream
      _liveAuctionsSubscription?.cancel();
      _liveAuctionsSubscription = _realtimeService
          .getLiveAuctionsStream<AuctionModel>(
            fromFirestore: (doc) => AuctionModel.fromFirestore(doc),
            limit: 15,
          )
          .listen(
            (auctions) => add(HomeLiveAuctionsUpdated(auctions)),
            onError: (error) {
              AppLogger.error('HomeBloc', 'Live auctions stream error', error: error);
            },
          );

      // Subscribe to real-time upcoming auctions stream
      _upcomingAuctionsSubscription?.cancel();
      _upcomingAuctionsSubscription = _realtimeService
          .getUpcomingAuctionsStream<AuctionModel>(
            fromFirestore: (doc) => AuctionModel.fromFirestore(doc),
            limit: 15,
          )
          .listen(
            (auctions) => add(HomeUpcomingAuctionsUpdated(auctions)),
            onError: (error) {
              AppLogger.error('HomeBloc', 'Upcoming auctions stream error', error: error);
            },
          );

      // Prefetch data for faster subsequent loads
      _realtimeService.prefetchHomeData<AuctionModel>(
        fromFirestore: (doc) => AuctionModel.fromFirestore(doc),
      );

      emit(state.copyWith(status: HomeStatus.loaded));
    } catch (e) {
      AppLogger.error('HomeBloc', 'Load error', error: e);
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onLiveAuctionsUpdated(
    HomeLiveAuctionsUpdated event,
    Emitter<HomeState> emit,
  ) {
    AppLogger.blocEvent('HomeBloc', 'LiveAuctionsUpdated: ${event.auctions.length} items');
    emit(state.copyWith(
      status: HomeStatus.loaded,
      liveAuctions: event.auctions,
    ));
  }

  void _onUpcomingAuctionsUpdated(
    HomeUpcomingAuctionsUpdated event,
    Emitter<HomeState> emit,
  ) {
    AppLogger.blocEvent('HomeBloc', 'UpcomingAuctionsUpdated: ${event.auctions.length} items');
    emit(state.copyWith(
      status: HomeStatus.loaded,
      upcomingAuctions: event.auctions,
    ));
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    AppLogger.blocEvent('HomeBloc', 'HomeRefreshRequested');
    // Clear cache and reload
    _realtimeService.clearCache();
    add(const HomeLoadRequested());
  }

  @override
  Future<void> close() {
    _liveAuctionsSubscription?.cancel();
    _upcomingAuctionsSubscription?.cancel();
    return super.close();
  }
}
