part of 'vehicle_auction_bloc.dart';

enum VehicleAuctionStatus { initial, loading, loaded, error }

class VehicleAuctionState extends Equatable {
  final VehicleAuctionStatus status;
  final List<Auction> auctions;
  final Auction? selectedAuction;
  final List<VehicleItem> vehicles;
  final String? errorMessage;

  const VehicleAuctionState({
    this.status = VehicleAuctionStatus.initial,
    this.auctions = const [],
    this.selectedAuction,
    this.vehicles = const [],
    this.errorMessage,
  });

  bool get isLoading => status == VehicleAuctionStatus.loading;
  bool get hasError => status == VehicleAuctionStatus.error;

  VehicleAuctionState copyWith({
    VehicleAuctionStatus? status,
    List<Auction>? auctions,
    Auction? selectedAuction,
    List<VehicleItem>? vehicles,
    String? errorMessage,
  }) {
    return VehicleAuctionState(
      status: status ?? this.status,
      auctions: auctions ?? this.auctions,
      selectedAuction: selectedAuction ?? this.selectedAuction,
      vehicles: vehicles ?? this.vehicles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, auctions, selectedAuction, vehicles, errorMessage];
}
