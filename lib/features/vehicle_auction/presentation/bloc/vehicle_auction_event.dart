part of 'vehicle_auction_bloc.dart';

abstract class VehicleAuctionEvent extends Equatable {
  const VehicleAuctionEvent();

  @override
  List<Object?> get props => [];
}

/// Load all auctions
class VehicleAuctionLoadRequested extends VehicleAuctionEvent {
  final String? statusFilter;

  const VehicleAuctionLoadRequested({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

/// Load single auction detail
class VehicleAuctionDetailRequested extends VehicleAuctionEvent {
  final String auctionId;

  const VehicleAuctionDetailRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Load vehicles for an auction
class VehicleItemsLoadRequested extends VehicleAuctionEvent {
  final String auctionId;

  const VehicleItemsLoadRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Start real-time stream for live auction updates
class VehicleAuctionStartRealtime extends VehicleAuctionEvent {
  final String auctionId;

  const VehicleAuctionStartRealtime(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Stop real-time stream
class VehicleAuctionStopRealtime extends VehicleAuctionEvent {
  const VehicleAuctionStopRealtime();
}

/// Search vehicles by query
class VehicleSearchRequested extends VehicleAuctionEvent {
  final String query;

  const VehicleSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Apply filters to vehicles
class VehicleFilterRequested extends VehicleAuctionEvent {
  final VehicleFilter filter;

  const VehicleFilterRequested(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Place a bid on a vehicle
class VehicleBidRequested extends VehicleAuctionEvent {
  final String vehicleId;
  final double amount;

  const VehicleBidRequested({
    required this.vehicleId,
    required this.amount,
  });

  @override
  List<Object?> get props => [vehicleId, amount];
}

/// Toggle vehicle in watchlist
class VehicleWatchlistToggled extends VehicleAuctionEvent {
  final String vehicleId;

  const VehicleWatchlistToggled(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Load bid history for a vehicle
class VehicleBidsHistoryRequested extends VehicleAuctionEvent {
  final String vehicleId;

  const VehicleBidsHistoryRequested(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Internal event: Vehicles updated via real-time stream
class VehiclesRealtimeUpdated extends VehicleAuctionEvent {
  final List<VehicleItem> vehicles;

  const VehiclesRealtimeUpdated(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

/// Internal event: Bids updated via real-time stream
class BidsRealtimeUpdated extends VehicleAuctionEvent {
  final List<Bid> bids;

  const BidsRealtimeUpdated(this.bids);

  @override
  List<Object?> get props => [bids];
}

/// Clear selected vehicle
class VehicleSelectionCleared extends VehicleAuctionEvent {
  const VehicleSelectionCleared();
}

/// Reset bid status after showing success/error message
class BidStatusReset extends VehicleAuctionEvent {
  const BidStatusReset();
}
