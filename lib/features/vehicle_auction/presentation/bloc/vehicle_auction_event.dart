part of 'vehicle_auction_bloc.dart';

abstract class VehicleAuctionEvent extends Equatable {
  const VehicleAuctionEvent();

  @override
  List<Object?> get props => [];
}

class VehicleAuctionLoadRequested extends VehicleAuctionEvent {
  final String? statusFilter;

  const VehicleAuctionLoadRequested({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class VehicleAuctionDetailRequested extends VehicleAuctionEvent {
  final String auctionId;

  const VehicleAuctionDetailRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

class VehicleItemsLoadRequested extends VehicleAuctionEvent {
  final String auctionId;

  const VehicleItemsLoadRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}
