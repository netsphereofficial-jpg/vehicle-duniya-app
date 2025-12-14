part of 'bidding_bloc.dart';

abstract class BiddingEvent extends Equatable {
  const BiddingEvent();

  @override
  List<Object?> get props => [];
}

class BiddingLoadRequested extends BiddingEvent {
  const BiddingLoadRequested();
}

class PlaceBidRequested extends BiddingEvent {
  final String auctionId;
  final String? vehicleId;
  final String? propertyId;
  final BidType type;
  final double amount;

  const PlaceBidRequested({
    required this.auctionId,
    this.vehicleId,
    this.propertyId,
    required this.type,
    required this.amount,
  });

  @override
  List<Object?> get props => [auctionId, vehicleId, propertyId, type, amount];
}
