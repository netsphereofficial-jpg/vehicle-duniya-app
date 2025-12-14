part of 'property_auction_bloc.dart';

abstract class PropertyAuctionEvent extends Equatable {
  const PropertyAuctionEvent();

  @override
  List<Object?> get props => [];
}

class PropertyAuctionLoadRequested extends PropertyAuctionEvent {
  const PropertyAuctionLoadRequested();
}
