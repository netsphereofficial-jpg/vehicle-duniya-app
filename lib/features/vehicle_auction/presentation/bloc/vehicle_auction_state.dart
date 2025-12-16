part of 'vehicle_auction_bloc.dart';

enum VehicleAuctionStatus {
  initial,
  loading,
  loaded,
  error,
  bidding,
  bidSuccess,
  bidError,
}

/// Filter options for vehicles
class VehicleFilter extends Equatable {
  final String? make;
  final double? minPrice;
  final double? maxPrice;
  final String? yardCity;
  final String? fuelType;

  const VehicleFilter({
    this.make,
    this.minPrice,
    this.maxPrice,
    this.yardCity,
    this.fuelType,
  });

  bool get isEmpty =>
      make == null &&
      minPrice == null &&
      maxPrice == null &&
      yardCity == null &&
      fuelType == null;

  VehicleFilter copyWith({
    String? make,
    double? minPrice,
    double? maxPrice,
    String? yardCity,
    String? fuelType,
    bool clearMake = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearYardCity = false,
    bool clearFuelType = false,
  }) {
    return VehicleFilter(
      make: clearMake ? null : (make ?? this.make),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      yardCity: clearYardCity ? null : (yardCity ?? this.yardCity),
      fuelType: clearFuelType ? null : (fuelType ?? this.fuelType),
    );
  }

  @override
  List<Object?> get props => [make, minPrice, maxPrice, yardCity, fuelType];
}

class VehicleAuctionState extends Equatable {
  // Existing fields
  final VehicleAuctionStatus status;
  final List<Auction> auctions;
  final Auction? selectedAuction;
  final List<VehicleItem> vehicles;
  final String? errorMessage;

  // New fields for search, filter, and bidding
  final String searchQuery;
  final VehicleFilter filter;
  final VehicleItem? selectedVehicle;
  final List<Bid> vehicleBids;
  final Set<String> watchlist;
  final bool isRealtimeActive;
  final String? bidSuccessMessage;

  const VehicleAuctionState({
    this.status = VehicleAuctionStatus.initial,
    this.auctions = const [],
    this.selectedAuction,
    this.vehicles = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.filter = const VehicleFilter(),
    this.selectedVehicle,
    this.vehicleBids = const [],
    this.watchlist = const {},
    this.isRealtimeActive = false,
    this.bidSuccessMessage,
  });

  // Status helpers
  bool get isLoading => status == VehicleAuctionStatus.loading;
  bool get hasError => status == VehicleAuctionStatus.error;
  bool get isBidding => status == VehicleAuctionStatus.bidding;
  bool get isBidSuccess => status == VehicleAuctionStatus.bidSuccess;
  bool get isBidError => status == VehicleAuctionStatus.bidError;

  // Filtered and searched vehicles
  List<VehicleItem> get displayVehicles {
    var result = vehicles;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((v) {
        final make = v.make?.toLowerCase() ?? '';
        final model = v.model?.toLowerCase() ?? '';
        final rcNo = v.rcNo?.toLowerCase() ?? '';
        final contractNo = v.contractNo?.toLowerCase() ?? '';
        final yardCity = v.yardCity?.toLowerCase() ?? '';

        return make.contains(query) ||
            model.contains(query) ||
            rcNo.contains(query) ||
            contractNo.contains(query) ||
            yardCity.contains(query);
      }).toList();
    }

    // Apply filters
    if (!filter.isEmpty) {
      if (filter.make != null) {
        result = result.where((v) => v.make == filter.make).toList();
      }
      if (filter.yardCity != null) {
        result = result.where((v) => v.yardCity == filter.yardCity).toList();
      }
      if (filter.fuelType != null) {
        result = result.where((v) => v.fuelType == filter.fuelType).toList();
      }
      if (filter.minPrice != null) {
        result = result.where((v) => v.basePrice >= filter.minPrice!).toList();
      }
      if (filter.maxPrice != null) {
        result = result.where((v) => v.basePrice <= filter.maxPrice!).toList();
      }
    }

    return result;
  }

  // Available filter options derived from vehicles
  List<String> get availableMakes => vehicles
      .map((v) => v.make ?? '')
      .where((m) => m.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get availableCities => vehicles
      .map((v) => v.yardCity ?? '')
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get availableFuelTypes => vehicles
      .map((v) => v.fuelType ?? '')
      .where((f) => f.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  // Check if a vehicle is in watchlist
  bool isInWatchlist(String vehicleId) => watchlist.contains(vehicleId);

  // Get vehicle count
  int get vehicleCount => vehicles.length;
  int get filteredVehicleCount => displayVehicles.length;

  VehicleAuctionState copyWith({
    VehicleAuctionStatus? status,
    List<Auction>? auctions,
    Auction? selectedAuction,
    bool clearSelectedAuction = false,
    List<VehicleItem>? vehicles,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    VehicleFilter? filter,
    VehicleItem? selectedVehicle,
    bool clearSelectedVehicle = false,
    List<Bid>? vehicleBids,
    Set<String>? watchlist,
    bool? isRealtimeActive,
    String? bidSuccessMessage,
    bool clearBidMessage = false,
  }) {
    return VehicleAuctionState(
      status: status ?? this.status,
      auctions: auctions ?? this.auctions,
      selectedAuction: clearSelectedAuction ? null : (selectedAuction ?? this.selectedAuction),
      vehicles: vehicles ?? this.vehicles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      selectedVehicle: clearSelectedVehicle ? null : (selectedVehicle ?? this.selectedVehicle),
      vehicleBids: vehicleBids ?? this.vehicleBids,
      watchlist: watchlist ?? this.watchlist,
      isRealtimeActive: isRealtimeActive ?? this.isRealtimeActive,
      bidSuccessMessage: clearBidMessage ? null : (bidSuccessMessage ?? this.bidSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        auctions,
        selectedAuction,
        vehicles,
        errorMessage,
        searchQuery,
        filter,
        selectedVehicle,
        vehicleBids,
        watchlist,
        isRealtimeActive,
        bidSuccessMessage,
      ];
}
